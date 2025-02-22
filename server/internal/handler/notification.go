package handler

import (
	"mytodo/internal/api"
	"mytodo/internal/db"
	"mytodo/internal/model"

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
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	var publishes []model.NotificationPublish
	err := db.SQL().Table("notification_publish").Where("user_id = ?", u.ID).Find(&publishes).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	var notifications []model.Notification
	for _, pub := range publishes {
		var notification model.Notification
		err = db.SQL().Table("notification").Where("id = ?", pub.NotificationId).First(&notification).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		notifications = append(notifications, notification)
	}
	ctx.JSON(200, gin.H{
		"msg":  "successfully gets notficaiton publishes",
		"data": notifications,
	})
}
