package handler

import (
	"mytodo/internal/api"
	"mytodo/internal/db"
	"mytodo/internal/model"
	"net/http"
	"strconv"
	"time"

	"github.com/caarlos0/log"
	"github.com/gin-gonic/gin"
)

func NotificationNew(ctx *gin.Context) {
	var req api.NotificationNewRequest
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
	notification := model.Notification{
		Type:        req.Type,
		Creator:     u.ID,
		Name:        req.Name,
		Description: req.Description,
	}
	err = db.SQL().Table("notification").Create(&notification).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	ctx.JSON(200, gin.H{
		"msg": "successfully creates notification",
	})
}

func NotificationGet(ctx *gin.Context) {
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	var notifications []model.Notification
	err := db.SQL().Table("notification").Where("creator = ?", u.ID).Find(&notifications).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	ctx.JSON(200, gin.H{
		"msg":  "successfully gets notification",
		"data": notifications,
	})
}

func NotificationDel(ctx *gin.Context) {
	var req api.NotificationDelRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	var notification model.Notification
	err = db.SQL().Table("notification").Where("id = ?", req.NotificationId).First(&notification).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	if u.ID != notification.Creator {
		log.WithError(err).Error("permission denied")
		ctx.Abort()
		return
	}
	err = db.SQL().Table("notification").Delete(&notification).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
}

func NotificationPublishNew(ctx *gin.Context) {
	var req api.NotificationPublishNewRequest
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
	var notification model.Notification
	err = db.SQL().Table("notification").Where("id = ?", req.NotificationId).First(&notification).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	if u.ID != notification.Creator {
		log.WithError(err).Error("permission denied")
		ctx.Abort()
		return
	}
	var publishes []model.NotificationPublish
	for _, uid := range req.UsersId {
		if uid == u.ID {
			continue
		}
		publishes = append(publishes, model.NotificationPublish{
			NotificationId: req.NotificationId,
			UserID:         uid,
		})
	}
	err = db.SQL().Table("notification_publish").CreateInBatches(&publishes, len(publishes)).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
}

func NotificationPublishGet(ctx *gin.Context) {
	var req api.NotificationPublishGetRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}

	limit := req.PageSize
	offset := (req.Page - 1) * req.PageSize

	u, ok := getUser(ctx)
	if !ok {
		return
	}
	var notifications []notificationSnapshot
	err = db.SQL().Raw(`SELECT
    n.id AS id,
    n.type AS type,
    COALESCE(na.status, 0) AS status,
    np.created_at AS created_at,
    n.name AS title,
    n.description AS content,
    u.name AS sender,
	u.id AS uid
FROM
    notification_publish np
JOIN
    notification n ON np.notification_id = n.id
LEFT JOIN
    notification_action na ON na.nid = np.notification_id AND na.receiver = np.user_id
LEFT JOIN
    user u ON n.creator = u.id
WHERE
    np.user_id = %d
    AND np.deleted_at IS NULL
    AND n.deleted_at IS NULL
ORDER BY
    np.created_at DESC
LIMIT %d OFFSET %d`, u.ID, limit, offset).Find(&notifications).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	for i, n := range notifications {
		switch n.Type {
		case model.NotificationTypeTopicApply:
			topicId, err := strconv.Atoi(n.Content)
			if err != nil {
				log.WithError(err).Error("fail to parse topic id")
				ctx.Abort()
				return
			}
			var topic model.Topic
			err = db.SQL().Table("topic").Where("id = ?", topicId).First(&topic).Error
			if err != nil {
				log.WithError(err).Error("fail to get topic")
				ctx.Abort()
				return
			}
			notifications[i].Content = topic.Name
		}
	}
	var total int64
	err = db.SQL().Unscoped().Table("notification_publish").Where("user_id = ?", u.ID).Count(&total).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"msg": "successfully gets notficaiton publishes",
		"data": gin.H{
			"total":         total,
			"notifications": notifications,
		},
	})
}

type notificationSnapshot struct {
	Id        uint      `json:"id"`
	Type      uint      `json:"type"`
	Status    uint      `json:"status"`
	CreatedAt time.Time `json:"created_at"`
	Title     string    `json:"title"`
	Content   string    `json:"content"`
	Sender    string    `json:"sender"`
	Uid       uint      `json:"uid"`
}

func NotificationUnreadCount(c *gin.Context) {
	u, ok := getUser(c)
	if !ok {
		return
	}

	var count int64
	err := db.SQL().Raw(`
		SELECT COUNT(DISTINCT np.id)
		FROM notification_publish np
		JOIN notification n ON np.notification_id = n.id
		LEFT JOIN notification_action na ON na.nid = np.notification_id AND na.receiver = np.user_id
		WHERE np.user_id = %d
		AND np.deleted_at IS NULL
		AND n.deleted_at IS NULL
		AND (na.id IS NULL OR na.status = %d)
	`, u.ID, model.NotifyStatePending).Count(&count).Error

	if err != nil {
		log.WithError(err).Error("failed to get unread count")
		c.JSON(500, gin.H{"msg": "failed to get unread count"})
		return
	}

	c.JSON(200, gin.H{
		"msg":  "successfully gets unread count",
		"data": count,
	})
}
