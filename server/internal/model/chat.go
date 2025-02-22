package model

type MessageTopic struct {
	Message
	TopicId uint `gorm:"column:topic_id;" json:"topic_id"`
}

func (MessageTopic) TableName() string {
	return "message_topic"
}

type MessageFriend struct {
	Message
	FriendId uint `gorm:"column:friend_id;" json:"friend_id"`
}

func (MessageFriend) TableName() string {
	return "message_friend"
}

type Message struct {
	Model
	Message       string      `gorm:"type:text" json:"message"`
	SentBy        uint        `gorm:"type:int" json:"sentBy"`
	MessageType   MessageType `gorm:"type:tinyint;default:0" json:"message_type"`
	VoiceDuration uint        `json:"voice_message_duration"`
	Status        string      `gorm:"size:50" json:"status"`
	ReplyId       uint        `gorm:"type:int" json:"reply_id"`

	ReplyMessage *MessageReply     `json:"reply_message,omitempty"`
	Reactions    []MessageReaction `json:"reaction,omitempty"`
}

type MessageReply struct {
	Model
	MessageId uint `gorm:"type:int" json:"messageId"`
	ReplyBy   uint `gorm:"type:int" json:"replyBy"`
	ReplyTo   uint `gorm:"type:int" json:"replyTo"`

	Message       string      `gorm:"type:text" json:"message"`
	MessageType   MessageType `gorm:"type:tinyint;default:0" json:"message_type"`
	VoiceDuration uint        `json:"voice_message_duration"`
}

func (MessageReply) TableName() string {
	return "message_reply"
}

type MessageReaction struct {
	Model
	MessageId     uint   `gorm:"type:int" json:"messageId"`
	Reaction      string `gorm:"size:50" json:"reaction"`
	ReactedUserId uint   `gorm:"type:int" json:"reactedUserId"`
}

func (MessageReaction) TableName() string {
	return "message_reaction"
}

type MessageType uint8

const (
	MessageTypeText MessageType = iota
	MessageTypeImage
	MessageTypeVoice
	MessageTypeCustom
)

func (t MessageType) String() string {
	return []string{"text", "iamge", "voice", "custom"}[t]
}
