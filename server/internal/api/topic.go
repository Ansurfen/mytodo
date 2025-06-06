package api

type TopicNewRequest struct {
	Icon        string   `json:"icon"`
	Name        string   `json:"name"`
	Description string   `json:"description"`
	IsPublic    bool     `json:"is_public"`
	Tags        []string `json:"tags"`
}

type TopicJoinRequest struct {
	InviteCode string `json:"invite_code"`
}

type TopicEditRequest struct {
	TopicId     uint   `json:"topic_id"`
	Name        string `json:"name"`
	Description string `json:"description"`
	Profile     string `json:"profile"`
}

type TopicDelRequest struct {
	TopicId uint `json:"topic_id"`
}

type TopicSubscribeRequest struct {
	InviteCode string `json:"invite_code"`
}

type TopicMemberGetRequest struct {
	TopicId uint `json:"topic_id"`
}

type TopicMemberDelRequest struct {
	TopicId uint `json:"topic_id"`
	UserId  uint `json:"user_id"`
}

type TopicMemberInviteRequest struct {
	TopicId uint   `json:"topic_id"`
	UsersId []uint `json:"users_id"`
}

type TopicExitRequest struct {
	TopicId uint `json:"topic_id"`
}

type TopicCalendarRequest struct {
	TopicId uint `json:"topic_id"`
}

type TopicFindRequest struct {
	Page     uint `json:"page"`
	PageSize uint `json:"page_size"`
}

type TopicApplyNewRequest struct {
	TopicId uint `json:"topic_id"`
}

type TopicApplyCommitRequest struct {
	NotificationId uint `json:"notification_id"`
	Pass           bool `json:"pass"`
}

type TopicMemberCommitRequest struct {
	NotificationId uint `json:"notification_id"`
	Pass           bool `json:"pass"`
}
