package handler

import (
	"mytodo/internal/api"
	"mytodo/internal/db"
	"mytodo/internal/model"
	"strconv"

	"github.com/caarlos0/log"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func PostSearch(ctx *gin.Context) {

}

func PostNew(ctx *gin.Context) {
	var req api.PostNewRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	post := model.Post{
		Title:  req.Title,
		Text:   req.Text,
		UserId: u.ID,
	}
	err = db.SQL().Table("post").Create(&post).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	ctx.JSON(200, gin.H{
		"data": post.ID,
	})
}

func PostEdit(ctx *gin.Context) {
	var req api.PostEditRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	var post model.Post
	err = db.SQL().Table("post").Where("post_id = ?", req.ID).First(&post).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	if post.ID == 0 {
		log.WithError(err).Error("invalid post id")
		ctx.Abort()
		return
	}
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	if u.ID != post.UserId {
		log.WithError(err).Error("permission denied")
		ctx.Abort()
		return
	}
	if len(req.Title) > 0 {
		post.Title = req.Title
	}
	if len(req.Text) > 0 {
		post.Text = req.Text
	}
	err = db.SQL().Table("post").Save(&post).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
}

func PostDel(ctx *gin.Context) {
	var req api.PostDelRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	var post model.Post
	err = db.SQL().Table("post").Where("post_id = ?", req.PostId).First(&post).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	if u.ID != post.UserId {
		log.WithError(err).Error("permission denied")
		ctx.Abort()
		return
	}
	err = db.SQL().Table("post").Delete(&post).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
}

func PostGet(ctx *gin.Context) {
	id, _ := strconv.Atoi(ctx.Param("id"))
	if post, ok := hasPermissionToReadPost(ctx, uint(id)); ok {
		var comments []model.PostComment
		err := db.SQL().Table("post_comment").Where("post_id = ?", post.ID).Find(&comments).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		var likeCount int64
		err = db.SQL().Table("post_like").Where("post_id = ?", post.ID).Count(&likeCount).Error
		if err != nil {
			log.WithError(err).Error("Error counting likes")
			ctx.JSON(500, gin.H{"error": "Failed to count likes"})
			return
		}

		// Return post details along with comments and like count
		ctx.JSON(200, gin.H{
			"post":       post,
			"comments":   comments,
			"like_count": likeCount,
		})
	}
}

func PostSnapshot(ctx *gin.Context) {
	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(ctx.DefaultQuery("limit", "10"))
	offset := (page - 1) * limit
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	var relations []model.UserRelation
	err := db.SQL().Table("user_relation").Where("user_id = ? OR friend_id = ?", u.ID, u.ID).Find(&relations).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	var friendIds []uint
	for _, relation := range relations {
		if relation.UserId != u.ID {
			friendIds = append(friendIds, relation.UserId)
		}
		if relation.FriendId != u.ID {
			friendIds = append(friendIds, relation.FriendId)
		}
	}

	var posts []postSnapshot
	err = db.SQL().Table("post").
		Select("post.*, "+
			"COALESCE((SELECT COUNT(*) FROM post_like WHERE post_like.post_id = post.id), 0) AS like_count, "+
			"COALESCE((SELECT COUNT(*) FROM post_comment WHERE post_comment.post_id = post.id), 0) AS comment_count").
		Where("post.user_id IN ?", friendIds).
		Limit(limit).
		Offset(offset).
		Find(&posts).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	ctx.JSON(200, gin.H{
		"msg":  "",
		"data": posts,
	})
}

type postSnapshot struct {
	model.Post
	LikeCount    int64 `json:"like_count"`
	CommentCount int64 `json:"comment_count"`
}

func hasPermissionToReadPost(ctx *gin.Context, postId uint) (post model.Post, ok bool) {
	ok = false
	u, ok := getUser(ctx)
	if !ok {
		return
	}

	// Check if the user is the post author

	err := db.SQL().Table("post").Where("id = ?", postId).First(&post).Error
	if err != nil {
		log.WithError(err).Error("Error fetching post")
		return
	}

	// If the user is the author of the post, they can read it
	if post.UserId == u.ID {
		ok = true
		return
	}

	// Otherwise, check if the user is friends with the post's author
	var relationCount int64
	err = db.SQL().Table("user_relation").
		Where("(user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)", u.ID, post.UserId, post.UserId, u.ID).
		Count(&relationCount).Error
	if err != nil {
		log.WithError(err).Error("Error checking user relation")
		return
	}

	// If the user has a relationship with the post author (i.e., they are friends), they can read it
	return post, relationCount > 0
}

func PostLike(ctx *gin.Context) {
	var req api.PostLikeRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	// Get the current user from the context
	u, ok := getUser(ctx)
	if !ok {
		ctx.JSON(403, gin.H{"error": "User not authenticated"})
		return
	}

	// Check if the user has already liked this post
	var existingLike model.PostLike
	err = db.SQL().Table("post_like").
		Where("post_id = ? AND user_id = ?", req.PostId, u.ID).
		First(&existingLike).Error

	if err == nil {
		// If an existing like is found, the user has already liked this post
		// ctx.JSON(400, gin.H{"error": "You have already liked this post"})
		err = db.SQL().Delete(&existingLike).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		return
	} else if err != gorm.ErrRecordNotFound {
		// If an error other than "record not found" occurred
		log.WithError(err).Error("Error checking for existing like")
		ctx.JSON(500, gin.H{"error": "Failed to check like status"})
		return
	}

	// Insert a new like record into the database
	newLike := model.PostLike{
		PostId: req.PostId,
		UserId: u.ID,
	}

	err = db.SQL().Table("post_like").Create(&newLike).Error
	if err != nil {
		log.WithError(err).Error("Failed to create like")
		ctx.JSON(500, gin.H{"error": "Failed to like the post"})
		return
	}

	// Return success response
	ctx.JSON(200, gin.H{"message": "Post liked successfully"})
}

func PostCommentGet(ctx *gin.Context) {
	postId, _ := strconv.Atoi(ctx.Param("post_id"))
	if _, ok := hasPermissionToReadPost(ctx, uint(postId)); ok {
		var comments []model.PostComment
		err := db.SQL().Table("post_comment").Where("post_id = ?", postId).Find(&comments).Error
		if err != nil {

		}
	}
}

func PostCommentNew(ctx *gin.Context) {
	var req api.PostCommentNewRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	if post, ok := hasPermissionToReadPost(ctx, req.PostId); ok {
		comment := model.PostComment{
			UserId:  u.ID,
			PostId:  post.ID,
			ReplyId: req.ReplyId,
			Text:    req.Text,
		}
		err := db.SQL().Table("post_comment").Create(&comment).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
	}
}

func PostCommentEdit(ctx *gin.Context) {
	var req api.PostCommentEditRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	var comment model.PostComment
	err = db.SQL().Table("post_comment").Where("id = ?", req.CommentId).First(&comment).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	if comment.ID == 0 || comment.UserId != u.ID {
		log.WithError(err).Error("permission denied")
		ctx.Abort()
		return
	}
	if len(req.Text) > 0 {
		comment.Text = req.Text
		err = db.SQL().Save(&comment).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
	}
}

func PostCommentDel(ctx *gin.Context) {
	var req api.PostCommentDelRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	var comment model.PostComment
	err = db.SQL().Table("post_comment").Where("id = ?", req.CommentId).First(&comment).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	if comment.ID == 0 || comment.UserId != u.ID {
		log.WithError(err).Error("permission denied")
		ctx.Abort()
		return
	}
	err = db.SQL().Delete(&comment).Error
	if comment.ID == 0 || comment.UserId != u.ID {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
}

func PostCommentLike(ctx *gin.Context) {
	var req api.PostCommentLikeRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	if _, ok := hasPermissionToReadPost(ctx, req.PostId); ok {
		// Check if the user has already liked this post
		var existingLike model.PostCommentLike
		err = db.SQL().Table("post_comment_like").
			Where("comment_id = ? AND user_id = ?", req.CommentId, u.ID).
			First(&existingLike).Error

		if err == nil {
			// If an existing like is found, the user has already liked this post
			// ctx.JSON(400, gin.H{"error": "You have already liked this comment"})
			err = db.SQL().Delete(&existingLike).Error
			if err != nil {
				log.WithError(err).Error("running sql")
				ctx.Abort()
				return
			}
			return
		} else if err != gorm.ErrRecordNotFound {
			// If an error other than "record not found" occurred
			log.WithError(err).Error("Error checking for existing like")
			ctx.JSON(500, gin.H{"error": "Failed to check like status"})
			return
		}

		// Insert a new like record into the database
		newLike := model.PostCommentLike{
			CommentId: req.CommentId,
			UserId:    u.ID,
		}

		err = db.SQL().Table("post_comment_like").Create(&newLike).Error
		if err != nil {
			log.WithError(err).Error("Failed to create like")
			ctx.JSON(500, gin.H{"error": "Failed to like the comment"})
			return
		}

		// Return success response
		ctx.JSON(200, gin.H{"message": "Comment liked successfully"})
	}
}
