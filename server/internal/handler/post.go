package handler

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"mime/multipart"
	"mytodo/internal/api"
	"mytodo/internal/db"
	"mytodo/internal/model"
	"net/http"
	"path/filepath"
	"strconv"
	"sync"
	"time"

	"github.com/caarlos0/log"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/minio/minio-go/v7"
	"gorm.io/datatypes"
	"gorm.io/gorm"
)

func PostSearch(ctx *gin.Context) {}

func PostNew(ctx *gin.Context) {
	var req api.PostNewRequest
	err := ctx.Bind(&req)
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
		UserId: u.ID,
	}

	err = json.Unmarshal([]byte(req.Text), &post.Text)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}

	form, err := ctx.MultipartForm()
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"msg": ""})
		return
	}
	files := form.File["files"]
	var wg sync.WaitGroup
	for i, f := range files {
		wg.Add(1)
		go func(f *multipart.FileHeader) {
			defer wg.Done()
			var buf []byte
			filename := fmt.Sprintf("%s%s", uuid.New(), filepath.Base(f.Filename))
			src, err := f.Open()
			if err != nil {
				ctx.JSON(400, gin.H{"error": "文件打开失败"})
				return
			}
			defer src.Close()

			buf, err = io.ReadAll(src)
			if err != nil {
				ctx.JSON(400, gin.H{"error": "文件读取失败"})
				return
			}
			_, err = db.OSS().PutObject(
				context.TODO(),
				"post",
				filename,
				bytes.NewReader(buf),
				int64(len(buf)),
				minio.PutObjectOptions{},
			)
			if err != nil {
				ctx.JSON(500, gin.H{"error": "文件上传失败"})
				return
			}
			if v, ok := post.Text[req.Indexs[i]]["insert"].(map[string]any); ok {
				v[req.Types[i]] = filename
				post.Text[req.Indexs[i]]["insert"] = v
			}
		}(f)
	}
	wg.Wait()
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
		u, ok := getUser(ctx)
		if !ok {
			return
		}
		db.SQL().Table("post_visit").Create(&model.PostVisit{
			UserId: u.ID,
			PostId: post.ID,
		})

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

func PostMe(ctx *gin.Context) {
	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(ctx.DefaultQuery("limit", "10"))
	offset := (page - 1) * limit
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	createdAtStr := ctx.DefaultQuery("created_at", "2000-01-01T00:00:00Z")
	createdAt, err := time.Parse(time.RFC3339, createdAtStr)
	if err != nil {
		ctx.JSON(400, gin.H{"error": "invalid created_at format"})
		return
	}

	var posts []postSnapshot
	err = db.SQL().Table("post").
		Select("post.*, "+
			"COALESCE((SELECT COUNT(*) FROM post_like WHERE post_like.post_id = post.id), 0) AS like_count, "+
			"COALESCE((SELECT COUNT(*) FROM post_comment WHERE post_comment.post_id = post.id), 0) AS comment_count, "+
			"COALESCE((SELECT COUNT(*) FROM post_visit WHERE post_visit.post_id = post.id), 0) AS visit_count, "+
			"EXISTS(SELECT 1 FROM post_like WHERE post_like.post_id = post.id AND post_like.user_id = ? AND post_like.deleted_at IS NULL) AS is_favorite", u.ID).
		Where("post.user_id = ? AND post.created_at >= ?", u.ID, createdAt).
		Limit(limit).
		Offset(offset).
		Find(&posts).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"msg":  "",
		"data": posts,
	})
}

type postFriendSnapshot struct {
	ID           uint           `json:"id"`
	UserID       uint           `json:"user_id"`
	Title        string         `json:"title"`
	Text         datatypes.JSON `json:"text"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	LikeCount    int64          `json:"like_count"`
	CommentCount int64          `json:"comment_count"`
	VisitCount   int64          `json:"visit_count"`
	Username     string         `json:"username"`
}

func PostFriend(ctx *gin.Context) {
	page, err := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	if err != nil {
		ctx.JSON(400, gin.H{"msg": "invalid page"})
		return
	}
	limit, err := strconv.Atoi(ctx.DefaultQuery("limit", "10"))
	if err != nil {
		ctx.JSON(400, gin.H{"msg": "invalid limit"})
		return
	}
	offset := (page - 1) * limit
	u, ok := getUser(ctx)
	if !ok {
		return
	}

	var relations []model.UserRelation
	err = db.SQL().Table("user_relation").Where("user_id = ? OR friend_id = ?", u.ID, u.ID).Find(&relations).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	var friendSet = make(map[uint]bool)
	var friendIds []uint
	for _, relation := range relations {
		if relation.UserId != u.ID {
			friendSet[relation.UserId] = true
		}
		if relation.FriendId != u.ID {
			friendSet[relation.FriendId] = true
		}
	}
	for k := range friendSet {
		friendIds = append(friendIds, k)
	}

	var posts []postFriendSnapshot
	err = db.SQL().Raw(`
		SELECT 
			p.id,
			p.user_id,
			p.title,
			p.text,
			p.created_at,
			p.updated_at,
			COALESCE(pl.like_count, 0) as like_count,
			COALESCE(pc.comment_count, 0) as comment_count,
			COALESCE(pv.visit_count, 0) as visit_count,
			u.name as username
		FROM post p
		LEFT JOIN (
			SELECT post_id, COUNT(*) as like_count 
			FROM post_like 
			WHERE deleted_at IS NULL
			GROUP BY post_id
		) pl ON p.id = pl.post_id
		LEFT JOIN (
			SELECT post_id, COUNT(*) as comment_count 
			FROM post_comment 
			GROUP BY post_id
		) pc ON p.id = pc.post_id
		LEFT JOIN (
			SELECT post_id, COUNT(*) as visit_count 
			FROM post_visit 
			GROUP BY post_id
		) pv ON p.id = pv.post_id
		LEFT JOIN user u ON p.user_id = u.id
		WHERE p.user_id IN ?
		ORDER BY p.created_at DESC
		LIMIT ? OFFSET ?
	`, friendIds, limit, offset).Scan(&posts).Error

	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"msg":  "success",
		"data": posts,
	})
}

type postDetail struct {
	model.Post
	CreatedAt  time.Time `json:"created_at"`
	IsMale     bool      `json:"is_male"`
	About      string    `json:"about"`
	LikeCount  int64     `json:"like_count"`
	VisitCount int64     `json:"visit_count"`
	Username   string    `json:"username"`
	Uid        uint      `json:"uid"`
	IsFavorite bool      `json:"is_favorite"`
}

func PostDetail(ctx *gin.Context) {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctx.JSON(400, gin.H{"msg": "invalid id"})
		return
	}
	if post, ok := hasPermissionToReadPost(ctx, uint(id)); ok {
		u, ok := getUser(ctx)
		if !ok {
			return
		}
		db.SQL().Table("post_visit").Create(&model.PostVisit{
			UserId: u.ID,
			PostId: post.ID,
		})
		var postDetail postDetail = postDetail{
			Post:      post,
			CreatedAt: post.CreatedAt,
		}
		var likeCount int64
		err = db.SQL().Table("post_like").Where("post_id = ? AND deleted_at IS NULL", post.ID).Count(&likeCount).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		postDetail.LikeCount = likeCount
		var visitCount int64
		err = db.SQL().Table("post_visit").Where("post_id = ?", post.ID).Count(&visitCount).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		postDetail.VisitCount = visitCount
		var user model.User
		err = db.SQL().Table("user").Where("id = ?", post.UserId).First(&user).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		postDetail.Username = user.Name
		postDetail.IsMale = user.IsMale
		postDetail.About = user.About
		postDetail.Uid = user.ID
		var isFavorite int64
		err = db.SQL().Table("post_like").Where("post_id = ? AND user_id = ? AND deleted_at IS NULL", post.ID, u.ID).Count(&isFavorite).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		postDetail.IsFavorite = isFavorite > 0
		ctx.JSON(200, gin.H{"data": postDetail})
	} else {
		ctx.JSON(403, gin.H{"msg": "permission denied"})
	}
}

func PostSource(ctx *gin.Context) {
	file := ctx.Param("file")

	obj, err := db.OSS().GetObject(context.TODO(), "post", file, minio.GetObjectOptions{})
	if err != nil {
		log.WithError(err).Debug("")
	}
	defer obj.Close()

	if filepath.Base(file) == ".mp4" {
		ctx.Header("Content-Type", "video/mp4")
	} else {
		ctx.Header("Content-Type", "image/png")
	}
	ctx.Header("Content-Disposition", fmt.Sprintf("inline; filename=%s", file))

	_, err = io.Copy(ctx.Writer, obj)
	if err != nil {
		log.WithError(err).Error("writing source to response")
		ctx.JSON(http.StatusInternalServerError, gin.H{"msg": "Error while sending profile image"})
		return
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
			"COALESCE((SELECT COUNT(*) FROM post_comment WHERE post_comment.post_id = post.id), 0) AS comment_count, "+
			"COALESCE((SELECT COUNT(*) FROM post_visit WHERE post_visit.post_id = post.id), 0) AS visit_count").
		Where("post.user_id IN ?", friendIds).
		Limit(limit).
		Offset(offset).
		Find(&posts).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"msg":  "",
		"data": posts,
	})
}

type postSnapshot struct {
	model.Post
	CreatedAt    time.Time `json:"created_at"`
	LikeCount    int64     `json:"like_count"`
	CommentCount int64     `json:"comment_count"`
	VisitCount   int64     `json:"visit_count"`
	IsFavorite   bool      `json:"is_favorite"`
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
		ctx.JSON(403, gin.H{"msg": "User not authenticated"})
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
		err = db.SQL().Table("post_like").Delete(&existingLike).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		ctx.JSON(http.StatusOK, gin.H{"msg": "successfully delete like", "data": false})
		return
	} else if err != gorm.ErrRecordNotFound {
		// If an error other than "record not found" occurred
		log.WithError(err).Error("Error checking for existing like")
		ctx.JSON(500, gin.H{"msg": "Failed to check like status"})
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
		ctx.JSON(500, gin.H{"msg": "Failed to like the post"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"msg": "Post liked successfully", "data": true})
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

type visitorInfo struct {
	UserID    uint      `json:"user_id"`
	Username  string    `json:"username"`
	VisitTime time.Time `json:"visit_time"`
}

type historyInfo struct {
	PostID    uint      `json:"post_id"`
	UserID    uint      `json:"user_id"`
	Username  string    `json:"username"`
	VisitTime time.Time `json:"visit_time"`
}

func PostVisitors(ctx *gin.Context) {
	u, ok := getUser(ctx)
	if !ok {
		return
	}

	// 获取当前用户的所有帖子ID
	var postIDs []uint
	err := db.SQL().Table("post").
		Select("id").
		Where("user_id = ?", u.ID).
		Find(&postIDs).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	if len(postIDs) == 0 {
		ctx.JSON(200, gin.H{
			"msg":  "success",
			"data": []visitorInfo{},
		})
		return
	}

	// 查询访问记录，排除自己
	var visitors []visitorInfo
	err = db.SQL().Raw(`
		SELECT DISTINCT 
			v.user_id,
			u.name as username,
			v.created_at as visit_time
		FROM post_visit v
		JOIN user u ON v.user_id = u.id
		WHERE v.post_id IN ? 
		AND v.user_id != ?
		ORDER BY v.created_at DESC
	`, postIDs, u.ID).Scan(&visitors).Error

	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	ctx.JSON(200, gin.H{
		"msg":  "success",
		"data": visitors,
	})
}

func PostHistory(ctx *gin.Context) {
	u, ok := getUser(ctx)
	if !ok {
		return
	}

	var history []historyInfo
	err := db.SQL().Raw(`
		SELECT DISTINCT 
			v.post_id,
			p.user_id,
			u.name as username,
			v.created_at as visit_time
		FROM post_visit v
		JOIN post p ON v.post_id = p.id
		JOIN user u ON p.user_id = u.id
		WHERE v.user_id = ? 
		AND p.user_id != ?
		ORDER BY v.created_at DESC
	`, u.ID, u.ID).Scan(&history).Error

	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	ctx.JSON(200, gin.H{
		"msg":  "success",
		"data": history,
	})
}
