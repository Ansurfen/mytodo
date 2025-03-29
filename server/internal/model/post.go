package model

import "gorm.io/datatypes"

type Post struct {
	Model
	UserId uint                                   `json:"user_id"`
	Title  string                                 `json:"title"`
	Text   datatypes.JSONSlice[datatypes.JSONMap] `json:"text" gorm:"type:json"`
}

func (Post) TableName() string {
	return "post"
}

type PostLike struct {
	Model
	PostId uint `json:"post_id" gorm:"column:post_id;uniqueIndex:pid_uid_idx"`
	UserId uint `json:"user_id" gorm:"column:user_id;uniqueIndex:pid_uid_idx"`
}

func (PostLike) TableName() string {
	return "post_like"
}

type PostComment struct {
	Model
	UserId  uint   `json:"user_id"`
	PostId  uint   `json:"post_id"`
	Text    string `json:"text"`
	ReplyId uint   `json:"reply_id"`
}

func (PostComment) TableName() string {
	return "post_comment"
}

type PostCommentLike struct {
	Model
	UserId    uint `json:"user_id"`
	CommentId uint `json:"comment_id"`
}

func (PostCommentLike) TableName() string {
	return "post_comment_like"
}
