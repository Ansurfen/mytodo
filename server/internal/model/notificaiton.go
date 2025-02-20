package model

// Notification represents the notification content such as title and text.
// This table stores the details of the notification (title, content).
type Notification struct {
	Model

	// Type of the notification action (e.g., Add Friend, Invite Friend)
	Type uint8 `gorm:"column:type"`

	// User ID of the creator of the notification
	Creator uint `json:"creator" gorm:"column:uid"`

	// Title of the notification
	Title string `json:"title" gorm:"column:title"`

	// Content of the notification
	Content string `json:"content" gorm:"column:content"`
}

// TableName overrides the default table name to "notify_text"
func (Notification) TableName() string {
	return "notification"
}

// Constants for notification type, which define the different actions that can trigger a notification.
const (
	// NotifyAction.Type - Types of notification actions

	NotificationTypeUnknown      = iota // Unknown type
	NotificationTypeAddFriend           // Type for adding a friend
	NotificationTypeInviteFriend        // Type for inviting a friend
	NotificationTypeSendText            // Type for sending a text message
)

// NotificationPublish represents the relationship between notifications and users who receive them.
// This table stores information about which user has been published which notification.
type NotificationPublish struct {
	Model

	// Notification ID
	NotifyID uint `json:"nid" gorm:"column:nid;uniqueIndex:nid_uid_idx"`

	// User ID who receives the notification
	UserID uint `json:"uid" gorm:"column:uid;uniqueIndex:nid_uid_idx"`
}

// TableName overrides the default table name to "notify_pub"
func (NotificationPublish) TableName() string {
	return "notification_publish"
}

// Constants for NotifyAction statuses, which define the different statuses of a notification action.
const (
	// NotifyAction.Status - States of the notification action

	NotifyStateUnknown   = iota // Unknown state
	NotifyStatePending          // Waiting for confirmation or processing
	NotifyStateConfirmed        // Action has been confirmed
	NotifyStateRejected         // Action has been rejected
)

// NotificationAction represents a record of a specific notification action between a sender and a receiver.
// This table stores the type of action, sender, receiver, and the current status of the action.
type NotificationAction struct {
	Model

	// Notification ID
	NotificationId uint `gorm:"column:nid"`

	// ID of the sender of the notification
	Sender uint `gorm:"column:sender"`

	// ID of the receiver of the notification
	Receiver uint `gorm:"column:receiver"`

	// Current status of the notification action (e.g., Pending, Confirmed, Rejected)
	Status uint8 `gorm:"column:status"`

	// Additional parameters or details related to the notification action
	Param string `gorm:"column:param"`
}

// TableName overrides the default table name to "notify_action"
func (NotificationAction) TableName() string {
	return "notification_action"
}
