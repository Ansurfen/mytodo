package api

type NotificationNewRequest struct {
	Type        uint8  `json:"type"`
	Name        string `json:"name"`
	Description string `json:"description"`
}

type NotificationDelRequest struct {
	NotificationId uint `json:"notification_id"`
}

type NotificationPublishNewRequest struct {
	NotificationId uint   `json:"notification_id"`
	UsersId        []uint `json:"users_id"`
}
