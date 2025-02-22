package api

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

type ChatTopicGetRequest struct {
	TopicId  uint `json:"topic_id"`
	Page     int  `json:"page"`
	PageSize int  `json:"page_size"`
}

type ChatTopicReactionRequest struct {
	MessageId uint   `json:"message_id"`
	Emoji     string `json:"emoji"`
}
