package api

import "mime/multipart"

type ChatTopicNewRequest struct {
	TopicId       uint   `json:"topic_id"`
	Message       string `json:"message"`
	MessageType   string `json:"message_type"`
	VoiceDuration uint   `json:"voice_duration"`
	ReplyId       uint   `json:"reply_id"`
	ReplyBy       uint   `json:"reply_by"`
	ReplyTo       uint   `json:"reply_to"`
	ReplyType     string `json:"reply_type"`
}

type ChatFriendNewRequest struct {
	FriendId      uint   `json:"friend_id"`
	Message       string `json:"message"`
	MessageType   string `json:"message_type"`
	VoiceDuration uint   `json:"voice_duration"`
	ReplyId       uint   `json:"reply_id"`
	ReplyBy       uint   `json:"reply_by"`
	ReplyTo       uint   `json:"reply_to"`
	ReplyType     string `json:"reply_type"`
}

type ChatTopicGetRequest struct {
	TopicId  uint `json:"topic_id"`
	Page     int  `json:"page"`
	PageSize int  `json:"page_size"`
}

type ChatFriendGetRequest struct {
	FriendId uint `json:"friend_id"`
	Page     int  `json:"page"`
	PageSize int  `json:"page_size"`
}

type ChatReactionRequest struct {
	MessageId uint   `json:"message_id"`
	Emoji     string `json:"emoji"`
}

type ChatTopicUploadRequest struct {
	Image     *multipart.FileHeader `form:"image"`
	TopicId   string                `form:"topic_id"`
	ReplyId   string                `form:"reply_id"`
	ReplyBy   string                `form:"reply_by"`
	ReplyTo   string                `form:"reply_to"`
	ReplyType string                `form:"reply_type"`
}

type ChatFriendUploadRequest struct {
	Image     *multipart.FileHeader `form:"image"`
	FriendId  string                `form:"friend_id"`
	ReplyId   string                `form:"reply_id"`
	ReplyBy   string                `form:"reply_by"`
	ReplyTo   string                `form:"reply_to"`
	ReplyType string                `form:"reply_type"`
}

type ChatTopicReadRequest struct {
	TopicId       uint `json:"topic_id"`
	LastMessageId uint `json:"last_message_id"`
}

type ChatFriendReadRequest struct {
	FriendId      uint `json:"friend_id"`
	LastMessageId uint `json:"last_message_id"`
}
