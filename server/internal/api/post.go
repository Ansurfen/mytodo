package api

import "mytodo/internal/model"

type PostNewRequest struct {
	model.Post
}

type PostEditRequest struct {
	model.Post
}

type PostDelRequest struct {
	PostId uint `json:"post_id"`
}

type PostLikeRequest struct {
	PostId uint `json:"post_id"`
}

type PostCommentNewRequest struct {
	PostId  uint   `json:"post_id"`
	ReplyId uint   `json:"reply_id"`
	Text    string `json:"text"`
}

type PostCommentDelRequest struct {
	CommentId uint `json:"post_id"`
}

type PostCommentEditRequest struct {
	CommentId uint   `json:"post_id"`
	Text      string `json:"text"`
}

type PostCommentLikeRequest struct {
	PostId    uint `json:"post_id"`
	CommentId uint `json:"comment_id"`
}
