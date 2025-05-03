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
	"net/http"
	"strconv"
	"strings"

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
		Icon:        req.Icon,
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

func TopicFind(ctx *gin.Context) {
	var req api.TopicFindRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	limit := req.PageSize
	offest := (req.Page - 1) * req.PageSize
	var topic []topicFind
	err = db.SQL().Raw(`SELECT 
    t.id,
    t.icon,
    t.creator,
    t.name,
    t.description,
    t.is_public,
    t.tags,
    t.invite_code,
    COUNT(tj.user_id) AS member_count
FROM 
    topic t
LEFT JOIN 
    topic_join tj ON t.id = tj.topic_id
WHERE 
    t.is_public = 1
GROUP BY 
    t.id
ORDER BY 
    t.created_at DESC
LIMIT %d OFFSET %d;
`, limit, offest).Find(&topic).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	var cnt int64
	err = db.SQL().Table("topic").Where("is_public = 1").Count(&cnt).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"msg": "successfully gets topics",
		"data": gin.H{
			"topic": topic,
			"total": cnt,
		},
	})
}

func TopicApplyNew(ctx *gin.Context) {
	var req api.TopicApplyNewRequest
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

	var topicJoin model.TopicJoin
	err = db.SQL().Table("topic_join").Where("topic_id = ? AND user_id = ?", req.TopicId, u.ID).First(&topicJoin).Error
	if err != nil && err != gorm.ErrRecordNotFound {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	if topicJoin.ID != 0 {
		ctx.JSON(http.StatusOK, gin.H{
			"msg":  "already joined",
			"data": nil,
		})
		ctx.Abort()
		return
	}
	var exist model.Notification
	err = db.SQL().Table("notification").Where("type = ? AND creator = ? AND description = ?", model.NotificationTypeTopicApply, u.ID, req.TopicId).First(&exist).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			tx := db.SQL().Begin()
			notification := model.Notification{
				Type:        model.NotificationTypeTopicApply,
				Creator:     u.ID,
				Name:        "Topic Apply",
				Description: fmt.Sprintf("%d", req.TopicId),
			}
			err = tx.Create(&notification).Error
			if err != nil {
				tx.Rollback()
				log.WithError(err).Error("running sql")
				ctx.Abort()
				return
			}
			var topic model.Topic
			err = db.SQL().Table("topic").Where("id = ?", req.TopicId).First(&topic).Error
			if err != nil {
				tx.Rollback()
				log.WithError(err).Error("running sql")
				ctx.Abort()
				return
			}
			notificationPub := model.NotificationPublish{
				NotificationId: notification.ID,
				UserID:         topic.Creator,
			}
			err = tx.Table("notification_publish").Create(&notificationPub).Error
			if err != nil {
				tx.Rollback()
				log.WithError(err).Error("running sql")
				ctx.Abort()
				return
			}
			notificationAction := model.NotificationAction{
				NotificationId: notification.ID,
				Receiver:       topic.Creator,
				Status:         model.NotifyStatePending,
			}
			err = tx.Table("notification_action").Create(&notificationAction).Error
			if err != nil {
				tx.Rollback()
				log.WithError(err).Error("running sql")
				ctx.Abort()
				return
			}
			tx.Commit()
		} else {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
	}
	ctx.JSON(200, gin.H{
		"msg": "successfully sent application",
	})
}

func TopicApplyCommit(ctx *gin.Context) {
	var req api.TopicApplyCommitRequest
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
	topicId, err := strconv.Atoi(notification.Description)
	if err != nil {
		log.WithError(err).Error("fail to parse topic id")
		ctx.Abort()
		return
	}
	var topic model.Topic
	err = db.SQL().Table("topic").Where("id = ?", topicId).First(&topic).Error

	u, ok := getUser(ctx)
	if !ok {
		return
	}
	if topic.Creator != u.ID {
		log.WithError(err).Error("permission denied")
		ctx.Abort()
		return
	}

	if req.Pass {
		tx := db.SQL().Begin()
		err = tx.Table("topic_join").Create(&model.TopicJoin{
			TopicId: topic.ID,
			UserId:  notification.Creator,
		}).Error
		if err != nil {
			tx.Rollback()
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		err = tx.Table("topic_policy").Create(&model.TopicPolicy{
			TopicId: topic.ID,
			UserId:  notification.Creator,
			Role:    model.TopicRoleMember,
		}).Error
		if err != nil {
			tx.Rollback()
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		var action model.NotificationAction
		err = tx.Table("notification_action").Where("nid = ?", notification.ID).First(&action).Error
		if err != nil {
			tx.Rollback()
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		if req.Pass {
			action.Status = model.NotifyStateConfirmed
		} else {
			action.Status = model.NotifyStateRejected
		}
		err = tx.Table("notification_action").Save(&action).Error
		if err != nil {
			tx.Rollback()
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		tx.Commit()
	} else {
		tx := db.SQL().Begin()
		err = tx.Table("notification").Where("id = ?", notification.ID).Delete(&model.Notification{}).Error
		if err != nil {
			tx.Rollback()
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		err = tx.Table("notification_publish").Where("notification_id = ? AND user_id = ?", notification.ID, u.ID).Delete(&model.NotificationPublish{}).Error
		if err != nil {
			tx.Rollback()
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		err = tx.Table("notification_action").Create(&model.NotificationAction{
			NotificationId: notification.ID,
			Status:         model.NotifyStateRejected,
			Receiver:       u.ID,
		}).Error
		if err != nil {
			tx.Rollback()
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		tx.Commit()
	}
}

type topicFind struct {
	model.Topic
	MemberCount uint `json:"member_count"`
}

func TopicGetSelectable(ctx *gin.Context) {
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
		var policy model.TopicPolicy
		err = db.SQL().Table("topic_policy").Where("user_id = ? AND topic_id = ?", u.ID, join.TopicId).First(&policy).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		if policy.Role.GE(model.TopicRoleAdmin) {
			var topic model.Topic
			err = db.SQL().Table("topic").Where("id = ?", join.TopicId).First(&topic).Error
			if err != nil {
				log.WithError(err).Error("running sql")
				ctx.Abort()
				return
			}
			topics = append(topics, topic)
		}
	}
	ctx.JSON(http.StatusOK, gin.H{
		"topic": topics,
	})
}

func TopicEdit(ctx *gin.Context) {
	// profile
}

func TopicDel(ctx *gin.Context) {
	var req api.TopicDelRequest
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
	err = db.SQL().Table("topic").Where("id = ?", req.TopicId).First(&topic).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	if topic.Creator != u.ID {
		log.WithError(err).Error("permission denied")
		ctx.Abort()
		return
	}
	tx := db.SQL().Begin()
	err = tx.Table("topic").Delete(&topic).Error
	if err != nil {
		tx.Rollback()
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	err = tx.Table("topic_join").Delete(&model.TopicJoin{TopicId: req.TopicId}).Error
	if err != nil {
		tx.Rollback()
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	err = tx.Table("topic_policy").Delete(&model.TopicPolicy{TopicId: req.TopicId}).Error
	if err != nil {
		tx.Rollback()
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	tx.Commit()
	ctx.JSON(http.StatusOK, gin.H{"msg": ""})
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

	// 检查用户是否有权限邀请成员
	policy, err := loadTopicPolicy(req.TopicId, u.ID)
	if err != nil {
		log.WithError(err).Error("fail to read policy")
		ctx.Abort()
		return
	}
	if !policy.Role.GE(model.TopicRoleAdmin) {
		ctx.JSON(http.StatusOK, gin.H{
			"msg": "permission denied",
		})
		ctx.Abort()
		return
	}

	// 检查用户是否已经加入话题
	for _, uid := range req.UsersId {
		var topicJoin model.TopicJoin
		err = db.SQL().Table("topic_join").Where("topic_id = ? AND user_id = ?", req.TopicId, uid).First(&topicJoin).Error
		if err != nil && err != gorm.ErrRecordNotFound {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		if topicJoin.ID != 0 {
			ctx.JSON(http.StatusOK, gin.H{
				"msg":  "user already joined",
				"data": uid,
			})
			ctx.Abort()
			return
		}
	}

	// 创建邀请通知
	tx := db.SQL().Begin()
	for _, uid := range req.UsersId {
		// 检查是否已经存在邀请
		var exist model.Notification
		metadata := fmt.Sprintf("%d;%d", req.TopicId, uid)
		err = db.SQL().Table("notification").Where("type = ? AND description = ?", model.NotificationTypeTopicInvite, metadata).First(&exist).Error
		if err != nil {
			if err == gorm.ErrRecordNotFound {
				notification := model.Notification{
					Type:        model.NotificationTypeTopicInvite,
					Creator:     u.ID,
					Name:        "Topic Invitation",
					Description: metadata,
				}
				err = tx.Create(&notification).Error
				if err != nil {
					tx.Rollback()
					log.WithError(err).Error("running sql")
					ctx.Abort()
					return
				}

				notificationPub := model.NotificationPublish{
					NotificationId: notification.ID,
					UserID:         uid,
				}
				err = tx.Table("notification_publish").Create(&notificationPub).Error
				if err != nil {
					tx.Rollback()
					log.WithError(err).Error("running sql")
					ctx.Abort()
					return
				}

				notificationAction := model.NotificationAction{
					NotificationId: notification.ID,
					Receiver:       uid,
					Status:         model.NotifyStatePending,
				}
				err = tx.Table("notification_action").Create(&notificationAction).Error
				if err != nil {
					tx.Rollback()
					log.WithError(err).Error("running sql")
					ctx.Abort()
					return
				}
			} else {
				tx.Rollback()
				log.WithError(err).Error("running sql")
				ctx.Abort()
				return
			}
		}
	}

	if err := tx.Commit().Error; err != nil {
		log.WithError(err).Error("fail to commit tx")
		ctx.Abort()
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"msg": "successfully sent invitation",
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

func TopicCalendar(ctx *gin.Context) {
	var req api.TopicCalendarRequest
	err := ctx.Bind(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	_, err = loadTopicPolicy(req.TopicId, u.ID)
	if err != nil {
		log.WithError(err).Error("fail to read policy")
		ctx.Abort()
		return
	}
	var tasks []model.Task
	err = db.SQL().Table("task").Where("topic_id = ?", req.TopicId).Find(&tasks).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, gin.H{"data": tasks})
}

func loadTopicPolicy(tid, uid uint) (policy model.TopicPolicy, err error) {
	err = db.SQL().Table("topic_policy").
		Where("topic_id = ? AND user_id = ?", tid, uid).First(&policy).Error
	return
}

func TopicMemberCommit(ctx *gin.Context) {
	var req api.TopicMemberCommitRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}

	// 获取通知信息
	var notification model.Notification
	err = db.SQL().Table("notification").Where("id = ?", req.NotificationId).First(&notification).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	// 解析话题ID和用户ID
	parts := strings.Split(notification.Description, ";")
	if len(parts) != 2 {
		log.Error("invalid notification description")
		ctx.Abort()
		return
	}
	topicId, err := strconv.Atoi(parts[0])
	if err != nil {
		log.WithError(err).Error("fail to parse topic id")
		ctx.Abort()
		return
	}
	userId, err := strconv.Atoi(parts[1])
	if err != nil {
		log.WithError(err).Error("fail to parse user id")
		ctx.Abort()
		return
	}

	// 获取当前用户
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	if uint(userId) != u.ID {
		log.Error("permission denied")
		ctx.Abort()
		return
	}

	if req.Pass {
		// 接受邀请
		tx := db.SQL().Begin()

		// 创建话题加入记录
		err = tx.Table("topic_join").Create(&model.TopicJoin{
			TopicId: uint(topicId),
			UserId:  u.ID,
		}).Error
		if err != nil {
			tx.Rollback()
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}

		// 创建话题权限记录
		err = tx.Table("topic_policy").Create(&model.TopicPolicy{
			TopicId: uint(topicId),
			UserId:  u.ID,
			Role:    model.TopicRoleMember,
		}).Error
		if err != nil {
			tx.Rollback()
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}

		// 更新通知状态
		var action model.NotificationAction
		err = tx.Table("notification_action").Where("nid = ? AND receiver = ?", notification.ID, u.ID).First(&action).Error
		if err != nil {
			tx.Rollback()
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		action.Status = model.NotifyStateConfirmed
		err = tx.Table("notification_action").Save(&action).Error
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
	} else {
		// 拒绝邀请
		tx := db.SQL().Begin()

		// 更新通知状态
		var action model.NotificationAction
		err = tx.Table("notification_action").Where("nid = ? AND receiver = ?", notification.ID, u.ID).First(&action).Error
		if err != nil {
			tx.Rollback()
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		action.Status = model.NotifyStateRejected
		err = tx.Table("notification_action").Save(&action).Error
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
	}

	ctx.JSON(http.StatusOK, gin.H{
		"msg": "successfully processed invitation",
	})
}
