package handler

import (
	"bytes"
	"context"
	"fmt"
	"image/color"
	"image/png"
	"mytodo/internal/api"
	"mytodo/internal/db"
	"mytodo/internal/model"

	"github.com/caarlos0/log"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/issue9/identicon/v2"
	"github.com/minio/minio-go/v7"
	"gorm.io/gorm"
)

var topicProfile = identicon.New(identicon.Style2, 128, color.RGBA{R: 255, G: 0, B: 0, A: 100}, color.RGBA{R: 0, G: 255, B: 255, A: 100})

func TopicNew(ctx *gin.Context) {
	var req api.TopicNewRequest
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
	tx := db.SQL().Begin()
	topic := model.Topic{
		Creator:     u.ID,
		Name:        req.Name,
		Description: req.Description,
		IsPublic:    req.IsPublic,
		Tags:        req.Tags,
		InviteCode:  uuid.NewString(),
	}
	err = tx.Create(&topic).Error
	if err != nil {
		tx.Rollback()
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	topicJoin := model.TopicJoin{
		TopicId: topic.ID,
		UserId:  u.ID,
	}
	err = tx.Create(&topicJoin).Error
	if err != nil {
		tx.Rollback()
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	topicPolicy := model.TopicPolicy{
		TopicId: topic.ID,
		UserId:  u.ID,
		Role:    model.TopicRoleOwner,
	}
	err = tx.Create(&topicPolicy).Error
	if err != nil {
		tx.Rollback()
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	if err := tx.Commit().Error; err != nil {
		log.WithError(err).Error("fail to commit tx")
		ctx.Abort()
		return
	}
	img := topicProfile.Make([]byte(fmt.Sprintf("topic_%d", topic.ID)))
	var buf bytes.Buffer
	err = png.Encode(&buf, img)
	if err != nil {
		log.WithError(err).Fatal("generating image")
		ctx.Abort()
		return
	}
	_, err = db.OSS().PutObject(context.TODO(), "topic", fmt.Sprintf("/profile/%d.png", topic.ID), &buf, int64(buf.Len()), minio.PutObjectOptions{})
	if err != nil {
		log.WithError(err).Fatal("fail to upload image")
		ctx.Abort()
		return
	}
	ctx.JSON(200, gin.H{
		"msg": "successfully creates topic",
	})
}

func TopicGet(ctx *gin.Context) {
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	var topicJoins []model.TopicJoin
	err := db.SQL().Table("topic_join").Where("user_id = ?", u.ID).Find(&topicJoins).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	var topics []model.Topic
	for _, join := range topicJoins {
		var topic model.Topic
		err = db.SQL().Table("topic").Where("id = ?", join.TopicId).First(&topic).Error
		if err != nil && err != gorm.ErrRecordNotFound {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		if err == nil {
			topics = append(topics, topic)
		}
	}
	ctx.JSON(200, gin.H{
		"msg":  "successfully gets topics",
		"data": topics,
	})
}

func TopicEdit(ctx *gin.Context) {
	// profile
}

func TopicDel(ctx *gin.Context) {

}

func TopicJoin(ctx *gin.Context) {
	var req api.TopicJoinRequest
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
	var topic model.Topic
	err = db.SQL().Table("topic").Where("invite_code = ?", req.InviteCode).First(&topic).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	tx := db.SQL().Begin()
	topicJoin := model.TopicJoin{
		TopicId: topic.ID,
		UserId:  u.ID,
	}
	err = tx.Table("topic_join").Create(&topicJoin).Error
	if err != nil {
		tx.Rollback()
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	topicPolicy := model.TopicPolicy{
		TopicId: topic.ID,
		UserId:  u.ID,
		Role:    model.TopicRoleMember,
	}
	err = tx.Table("topic_policy").Create(&topicPolicy).Error
	if err != nil {
		tx.Rollback()
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	if err := tx.Commit().Error; err != nil {
		log.WithError(err).Error("fail to commit tx")
		ctx.Abort()
		return
	}
	ctx.JSON(200, gin.H{
		"msg": "successfully joins topic",
	})
}

func TopicMemberGet(ctx *gin.Context) {
	var req api.TopicMemberGetRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	var topicJoins []model.TopicJoin
	err = db.SQL().Table("topic_join").Where("topic_id = ?", req.TopicId).Find(&topicJoins).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	var users []topicUser
	for _, join := range topicJoins {
		var user model.User
		err = db.SQL().Table("user").Where("id = ?", join.UserId).First(&user).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		var policy model.TopicPolicy
		err = db.SQL().Table("topic_policy").Where("topic_id = ? AND user_id = ?", req.TopicId, join.UserId).First(&policy).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		users = append(users, topicUser{
			Role: policy.Role,
			User: user,
		})
	}
	ctx.JSON(200, gin.H{
		"msg":  "successfully gets members",
		"data": users,
	})
}

type topicUser struct {
	model.User
	Role model.TopicRole `json:"role"`
}

func TopicMemberDel(ctx *gin.Context) {
	var req api.TopicMemberDelRequest
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
	if u.ID == req.UserId {
		log.Error("you cannot delete yourself")
		ctx.Abort()
		return
	}
	policy, err := loadTopicPolicy(req.TopicId, u.ID)
	if err != nil {
		log.WithError(err).Error("fail to read policy")
		ctx.Abort()
		return
	}
	if policy.Role.GE(model.TopicRoleAdmin) {
		var join model.TopicJoin
		err = db.SQL().Table("topic_join").Where("user_id = ?", req.UserId).First(&join).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		err = db.SQL().Table("topic_join").Delete(&join).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		ctx.JSON(200, gin.H{
			"msg": "successfully deletes",
		})
	} else {
		ctx.JSON(200, gin.H{
			"msg": "permission denied",
		})
	}
}

func TopicMemberInvite(ctx *gin.Context) {
	var req api.TopicMemberInviteRequest
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
	metadata := fmt.Sprintf("%d;%d", u.ID, req.TopicId)
	notification := model.Notification{
		Type:        model.NotificationTypeTopicInvite,
		Creator:     u.ID,
		Name:        "Topic invitation",
		Description: fmt.Sprintf("%d;%d", u.ID, req.TopicId),
	}
	tx := db.SQL().Begin()

	var exist model.Notification
	tx.Table("notification").Where("type = ? AND description = ?", model.NotificationTypeTopicInvite, metadata).First(&exist)
	if exist.ID != 0 {
		notification = exist
	} else {
		err = tx.Table("notification").Create(&notification).Error
		if err != nil {
			tx.Rollback()
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
	}

	var publishes []model.NotificationPublish
	for _, uid := range req.UsersId {
		if uid == notification.Creator {
			continue
		}

		var existingRecord model.NotificationPublish
		if err := db.SQL().Table("notification_publish").
			Where("notification_id = ? AND user_id = ?", notification.ID, uid).
			First(&existingRecord).Error; err != nil && err != gorm.ErrRecordNotFound {
			tx.Rollback()
			log.WithError(err).Error("check if record exists")
			ctx.Abort()
			return
		}

		if existingRecord.ID == 0 {
			publishes = append(publishes, model.NotificationPublish{
				NotificationId: notification.ID,
				UserID:         uid,
			})
		}
	}

	if len(publishes) > 0 {
		err = tx.Table("notification_publish").CreateInBatches(&publishes, len(publishes)).Error
		if err != nil {
			tx.Rollback()
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
	}
	if err := tx.Commit().Error; err != nil {
		log.WithError(err).Error("fail to commit tx")
		ctx.Abort()
		return
	}
	ctx.JSON(200, gin.H{
		"msg": "successfully send invitation",
	})
}

func TopicExit(ctx *gin.Context) {
	var req api.TopicExitRequest
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
	policy, err := loadTopicPolicy(req.TopicId, u.ID)
	if err != nil {
		log.WithError(err).Error("fail to read policy")
		ctx.Abort()
		return
	}
	if policy.Role.EQ(model.TopicRoleOwner) {
		var topic model.Topic
		err = db.SQL().Table("topic").Where("id = ?", req.TopicId).First(&topic).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		err = db.SQL().Table("topic").Delete(&topic).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
	} else {
		var topicJoin model.TopicJoin
		err = db.SQL().Table("topic_join").Where("topic_id = ? AND user_id = ?", req.TopicId, u.ID).First(&topicJoin).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
	}
}

func loadTopicPolicy(tid, uid uint) (policy model.TopicPolicy, err error) {
	err = db.SQL().Table("topic_policy").
		Where("topic_id = ? AND user_id = ?", tid, uid).First(&policy).Error
	return
}
