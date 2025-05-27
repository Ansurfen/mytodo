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

// PostSearch godoc
// @Summary      Search posts
// @Description  Search posts by keywords
// @Tags         posts
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Success      200  {object}  map[string]interface{}
// @Failure      401  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Router       /post/search [get]
func PostSearch(ctx *gin.Context) {}

// PostNew godoc
// @Summary      Create a new post
// @Description  Create a new post with title, text and optional files
// @Tags         posts
// @Accept       multipart/form-data
// @Produce      json
// @Param        title  formData  string  true  "Post title"
// @Param        text   formData  string  true  "Post text in JSON format"
// @Param        files  formData  file    false  "Post files"
// @Param        indexs formData  []int   false  "File indexes"
// @Param        types  formData  []string false "File types"
// @Security     Bearer
// @Success      200  {object}  map[string]interface{}  "Post created successfully"
// @Failure      400  {object}  map[string]string       "Invalid request"
// @Failure      401  {object}  map[string]string       "Unauthorized"
// @Failure      500  {object}  map[string]string       "Internal server error"
// @Router       /post/new [post]
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

// PostEdit godoc
// @Summary      Edit a post
// @Description  Edit an existing post's title and/or text
// @Tags         posts
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        request body api.PostEditRequest true "Post edit details"
// @Success      200  {object}  map[string]string
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      403  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Router       /post/edit [post]
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

// PostDel godoc
// @Summary      Delete a post
// @Description  Delete a post by ID
// @Tags         posts
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        request body api.PostDelRequest true "Post ID"
// @Success      200  {object}  map[string]string
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      403  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Router       /post/del [post]
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

// PostGet godoc
// @Summary      Get a post by ID
// @Description  Get detailed information about a specific post including comments and like count
// @Tags         posts
// @Accept       json
// @Produce      json
// @Param        id   path      int  true  "Post ID"
// @Security     Bearer
// @Success      200  {object}  map[string]interface{}  "Post details"
// @Failure      400  {object}  map[string]string       "Invalid post ID"
// @Failure      401  {object}  map[string]string       "Unauthorized"
// @Failure      403  {object}  map[string]string       "Permission denied"
// @Failure      500  {object}  map[string]string       "Internal server error"
// @Router       /post/{id} [get]
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

// PostMe godoc
// @Summary      Get user's posts
// @Description  Get all posts created by the current user with pagination
// @Tags         posts
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        page query int false "Page number" default(1)
// @Param        limit query int false "Posts per page" default(10)
// @Param        created_at query string false "Filter by creation date" default(2000-01-01T00:00:00Z)
// @Success      200  {object}  map[string]interface{}
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Router       /post/me [get]
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
	err = db.SQL().Raw(`
		SELECT 
			p.*,
			COALESCE(pl.like_count, 0) as like_count,
			COALESCE(pc.comment_count, 0) as comment_count,
			COALESCE(pv.visit_count, 0) as visit_count,
			EXISTS(SELECT 1 FROM post_like WHERE post_id = p.id AND user_id = ? AND deleted_at IS NULL) as is_favorite
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
		WHERE p.user_id = ? AND p.created_at >= ?
		ORDER BY p.created_at DESC
		LIMIT ? OFFSET ?
	`, u.ID, u.ID, createdAt, limit, offset).Scan(&posts).Error

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
	IsMale       bool           `json:"is_male"`
}

// PostFriend godoc
// @Summary      Get friends' posts
// @Description  Get posts from friends with pagination
// @Tags         posts
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        page query int false "Page number" default(1)
// @Param        limit query int false "Posts per page" default(10)
// @Success      200  {object}  map[string]interface{}
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Router       /post/friend [get]
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
			u.name as username,
			u.is_male as is_male
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

// PostDetail godoc
// @Summary      Get post details
// @Description  Get detailed information about a specific post including author info and statistics
// @Tags         posts
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        id path int true "Post ID"
// @Success      200  {object}  map[string]interface{}
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      403  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Router       /post/detail/{id} [get]
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

// PostSource godoc
// @Summary      Get post file
// @Description  Get a file (image, video) from a post
// @Tags         posts
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        file path string true "File name"
// @Success      200  {file}  binary
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Router       /post/source/{file} [get]
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

// PostSnapshot godoc
// @Summary      Get posts snapshot
// @Description  Get a snapshot of posts from friends with pagination
// @Tags         posts
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        page query int false "Page number" default(1)
// @Param        limit query int false "Posts per page" default(10)
// @Success      200  {object}  map[string]interface{}
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Router       /post/snapshot [get]
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

// PostLike godoc
// @Summary      Like/Unlike a post
// @Description  Toggle like status for a post
// @Tags         posts
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        request body api.PostLikeRequest true "Post like details"
// @Success      200  {object}  map[string]interface{}
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Router       /post/like [post]
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

type postComment struct {
	model.PostComment
	CreatedAt  time.Time `json:"created_at"`
	Username   string    `json:"username"`
	ReplyName  string    `json:"reply_name"`
	ReplyCount int64     `json:"reply_count"`
	LikeCount  int64     `json:"like_count"`
	IsFavorite bool      `json:"is_favorite"`
}

// PostCommentGet godoc
// @Summary      Get post comments
// @Description  Get comments for a post with pagination
// @Tags         posts
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        request body api.PostCommentGetRequest true "Comment request details"
// @Success      200  {object}  map[string]interface{}
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Router       /post/comment/get [post]
func PostCommentGet(ctx *gin.Context) {
	var req api.PostCommentGetRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	limit := req.PageSize
	offset := (req.Page - 1) * limit
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	if _, ok := hasPermissionToReadPost(ctx, req.PostId); ok {
		var comments []postComment
		err := db.SQL().Raw(`SELECT 
    pc.id,
    pc.user_id,
    u.name AS username,
    pc.post_id,
    pc.text,
    pc.reply_id,
    pc.created_at,
    pc.updated_at, 
    -- 当前用户是否点赞了该评论
    CASE 
        WHEN pcl.id IS NOT NULL THEN TRUE 
        ELSE FALSE 
    END AS is_favorite,
    -- 当前评论的点赞数
    (
        SELECT COUNT(*) 
        FROM post_comment_like 
        WHERE comment_id = pc.id AND deleted_at IS NULL
    ) AS like_count,
    -- 当前评论的回复数
    (
        SELECT COUNT(*) 
        FROM post_comment 
        WHERE reply_id = pc.id
    ) AS reply_count
FROM 
    post_comment pc
JOIN 
    user u ON pc.user_id = u.id
LEFT JOIN 
    post_comment_like pcl 
    ON pcl.comment_id = pc.id AND pcl.user_id = ?
WHERE 
    pc.post_id = ?
    AND pc.reply_id = 0  -- 只查顶级评论
ORDER BY 
    pc.created_at ASC
LIMIT ? OFFSET ?; `, u.ID, req.PostId, limit, offset).Scan(&comments).Error

		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}

		var total int64
		err = db.SQL().Table("post_comment").Where("post_id = ?", req.PostId).Count(&total).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}

		ctx.JSON(http.StatusOK, gin.H{
			"msg": "success",
			"data": gin.H{
				"comments": comments,
				"total":    total,
			},
		})
	}
}

// PostCommentReplyGet godoc
// @Summary      Get comment replies
// @Description  Get replies to a specific comment with pagination
// @Tags         posts
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        request body api.PostCommentReplyGetRequest true "Reply request details"
// @Success      200  {object}  map[string]interface{}
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Router       /post/comment/reply/get [post]
func PostCommentReplyGet(ctx *gin.Context) {
	var req api.PostCommentReplyGetRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	limit := req.PageSize
	offset := (req.Page - 1) * limit
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	if _, ok := hasPermissionToReadPost(ctx, req.PostId); ok {
		var replies []postComment
		err := db.SQL().Raw(`
WITH RECURSIVE comment_tree AS (
    -- 基础层：找到指定评论的直接回复
    SELECT 
        c.id,
        c.user_id,
        c.post_id,
        c.text,
        c.reply_id,
        c.created_at,
        c.updated_at,
        u.name AS username,
        ru.name AS reply_name,
        COALESCE(lc.like_count, 0) AS like_count,
        EXISTS (
            SELECT 1 
            FROM post_comment_like 
            WHERE comment_id = c.id 
              AND user_id = ? 
              AND deleted_at IS NULL
        ) AS is_favorite,
        c.id AS root_reply_id, -- 初始根回复 ID 就是自己
        1 AS level
    FROM post_comment c
    LEFT JOIN user u ON c.user_id = u.id
    LEFT JOIN post_comment rc ON c.reply_id = rc.id
    LEFT JOIN user ru ON rc.user_id = ru.id
    LEFT JOIN (
        SELECT comment_id, COUNT(*) AS like_count 
        FROM post_comment_like 
        WHERE deleted_at IS NULL 
        GROUP BY comment_id
    ) lc ON c.id = lc.comment_id
    WHERE c.post_id = ? AND c.reply_id = ?

    UNION ALL

    -- 递归层：查找所有子评论
    SELECT 
        c.id,
        c.user_id,
        c.post_id,
        c.text,
        c.reply_id,
        c.created_at,
        c.updated_at,
        u.name AS username,
        ru.name AS reply_name,
        COALESCE(lc.like_count, 0) AS like_count,
        EXISTS (
            SELECT 1 
            FROM post_comment_like 
            WHERE comment_id = c.id 
              AND user_id = ? 
              AND deleted_at IS NULL
        ) AS is_favorite,
        ct.root_reply_id,
        ct.level + 1
    FROM post_comment c
    JOIN comment_tree ct ON c.reply_id = ct.id
    LEFT JOIN user u ON c.user_id = u.id
    LEFT JOIN post_comment rc ON c.reply_id = rc.id
    LEFT JOIN user ru ON rc.user_id = ru.id
    LEFT JOIN (
        SELECT comment_id, COUNT(*) AS like_count 
        FROM post_comment_like 
        WHERE deleted_at IS NULL 
        GROUP BY comment_id
    ) lc ON c.id = lc.comment_id
    WHERE c.post_id = ?
)
SELECT *
FROM comment_tree
ORDER BY root_reply_id, level, created_at ASC
LIMIT ? OFFSET ?;
		`, u.ID, req.PostId, req.CommentId, u.ID, req.PostId, limit, offset).Scan(&replies).Error

		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}

		var total int64
		err = db.SQL().Table("post_comment").Where("post_id = ? AND reply_id = ?", req.PostId, req.CommentId).Count(&total).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		ctx.JSON(http.StatusOK, gin.H{
			"msg": "success",
			"data": gin.H{
				"replies": replies,
				"total":   total,
			},
		})
	} else {
		ctx.JSON(500, gin.H{
			"msg": "error",
		})
	}
}

// PostCommentNew godoc
// @Summary      Create new comment
// @Description  Create a new comment on a post or reply to an existing comment
// @Tags         posts
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        request body api.PostCommentNewRequest true "Comment details"
// @Success      200  {object}  map[string]interface{}
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Router       /post/comment/new [post]
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
		// 如果是回复评论，验证被回复的评论是否存在且属于同一个帖子
		if req.ReplyId != 0 {
			var replyComment model.PostComment
			err = db.SQL().Table("post_comment").
				Where("id = ? AND post_id = ?", req.ReplyId, req.PostId).
				First(&replyComment).Error
			if err != nil {
				log.WithError(err).Error("reply comment not found")
				ctx.JSON(400, gin.H{"msg": "reply comment not found"})
				return
			}
		}

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

		// 获取新创建的评论的完整信息
		var newComment postComment
		err = db.SQL().Raw(`
			SELECT 
				c.*,
				u.name as username,
				ru.name as reply_name,
				COALESCE(lc.like_count, 0) as like_count,
				EXISTS(SELECT 1 FROM post_comment_like WHERE comment_id = c.id AND user_id = ? AND deleted_at IS NULL) as is_favorite
			FROM post_comment c
			LEFT JOIN user u ON c.user_id = u.id
			LEFT JOIN post_comment rc ON c.reply_id = rc.id
			LEFT JOIN user ru ON rc.user_id = ru.id
			LEFT JOIN (
				SELECT comment_id, COUNT(*) as like_count 
				FROM post_comment_like 
				WHERE deleted_at IS NULL
				GROUP BY comment_id
			) lc ON c.id = lc.comment_id
			WHERE c.id = ?
		`, u.ID, comment.ID).Scan(&newComment).Error

		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}

		ctx.JSON(200, gin.H{
			"msg":  "success",
			"data": newComment,
		})
	}
}

// PostCommentEdit godoc
// @Summary      Edit comment
// @Description  Edit an existing comment
// @Tags         posts
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        request body api.PostCommentEditRequest true "Comment edit details"
// @Success      200  {object}  map[string]string
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      403  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Router       /post/comment/edit [post]
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

// PostCommentDel godoc
// @Summary      Delete comment
// @Description  Delete a comment and optionally its replies
// @Tags         posts
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        request body api.PostCommentDelRequest true "Comment delete details"
// @Success      200  {object}  map[string]interface{}
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      403  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Router       /post/comment/del [post]
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

	// 开始事务
	tx := db.SQL().Begin()
	if tx.Error != nil {
		log.WithError(tx.Error).Error("start transaction failed")
		ctx.Abort()
		return
	}

	// 获取评论信息
	var comment model.PostComment
	err = tx.Table("post_comment").Where("id = ?", req.CommentId).First(&comment).Error
	if err != nil {
		tx.Rollback()
		log.WithError(err).Error("comment not found")
		ctx.JSON(400, gin.H{"msg": "comment not found"})
		return
	}

	// 验证权限
	if comment.UserId != u.ID {
		tx.Rollback()
		log.WithError(err).Error("permission denied")
		ctx.JSON(403, gin.H{"msg": "permission denied"})
		return
	}

	// 如果是主评论且需要删除回复
	if comment.ReplyId == 0 && req.DeleteReplies {
		// 删除所有回复
		err = tx.Table("post_comment").Where("reply_id = ?", comment.ID).Delete(&model.PostComment{}).Error
		if err != nil {
			tx.Rollback()
			log.WithError(err).Error("delete replies failed")
			ctx.Abort()
			return
		}
	}

	// 删除评论
	err = tx.Table("post_comment").Delete(&comment).Error
	if err != nil {
		tx.Rollback()
		log.WithError(err).Error("delete comment failed")
		ctx.Abort()
		return
	}

	// 删除相关的点赞记录
	err = tx.Table("post_comment_like").Where("comment_id = ?", comment.ID).Delete(&model.PostCommentLike{}).Error
	if err != nil {
		tx.Rollback()
		log.WithError(err).Error("delete likes failed")
		ctx.Abort()
		return
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		log.WithError(err).Error("commit transaction failed")
		ctx.Abort()
		return
	}

	ctx.JSON(200, gin.H{
		"msg": "success",
		"data": gin.H{
			"comment_id":      comment.ID,
			"is_main_comment": comment.ReplyId == 0,
		},
	})
}

// PostCommentLike godoc
// @Summary      Like/Unlike comment
// @Description  Toggle like status for a comment
// @Tags         posts
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Param        request body api.PostCommentLikeRequest true "Comment like details"
// @Success      200  {object}  map[string]interface{}
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Router       /post/comment/like [post]
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
			err = db.SQL().Table("post_comment_like").Delete(&existingLike).Error
			if err != nil {
				log.WithError(err).Error("running sql")
				ctx.Abort()
				return
			}
			ctx.JSON(http.StatusOK, gin.H{"msg": "success", "data": false})
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
		ctx.JSON(http.StatusOK, gin.H{"msg": "success", "data": true})
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

// PostVisitors godoc
// @Summary      Get post visitors
// @Description  Get list of users who visited the current user's posts
// @Tags         posts
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Success      200  {object}  map[string]interface{}
// @Failure      401  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Router       /post/visitors [get]
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

// PostHistory godoc
// @Summary      Get visit history
// @Description  Get history of posts visited by the current user
// @Tags         posts
// @Accept       json
// @Produce      json
// @Security     Bearer
// @Success      200  {object}  map[string]interface{}
// @Failure      401  {object}  map[string]string
// @Failure      500  {object}  map[string]string
// @Router       /post/history [get]
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
