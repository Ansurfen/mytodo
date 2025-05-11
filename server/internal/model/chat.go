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
	VoiceDuration uint        `gorm:"type:int" json:"voice_duration"`
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
	VoiceDuration uint        `gorm:"type:int" json:"voice_duration"`
}

type MessageTopicReply struct {
	MessageReply
}

func (MessageTopicReply) TableName() string {
	return "message_topic_reply"
}

type MessageFriendReply struct {
	MessageReply
}

func (MessageFriendReply) TableName() string {
	return "message_friend_reply"
}

type MessageReaction struct {
	Model
	MessageId     uint   `gorm:"type:int" json:"messageId"`
	Reaction      string `gorm:"size:50" json:"reaction"`
	ReactedUserId uint   `gorm:"type:int" json:"reactedUserId"`
}

type MessageTopicReaction struct {
	MessageReaction
}

func (MessageTopicReaction) TableName() string {
	return "message_topic_reaction"
}

type MessageFriendReaction struct {
	MessageReaction
}

func (MessageFriendReaction) TableName() string {
	return "message_friend_reaction"
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

type MessageTopicUnread struct {
	Model
	UserId            uint `gorm:"index;not null" json:"user_id"`
	TopicId           uint `gorm:"index;not null" json:"topic_id"`
	LastReadMessageId uint `gorm:"not null;default:0" json:"last_read_message_id"`
}

func (t MessageTopicUnread) TableName() string {
	return "message_topic_unread"
}

type MessageFriendUnread struct {
	Model
	UserId            uint `gorm:"index;not null" json:"user_id"`
	FriendId          uint `gorm:"index;not null" json:"friend_id"`
	LastReadMessageId uint `gorm:"not null;default:0" json:"last_read_message_id"`
}

func (t MessageFriendUnread) TableName() string {
	return "message_friend_unread"
}
