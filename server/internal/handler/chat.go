package handler

import (
	"context"
	"fmt"
	"io"
	"mytodo/internal/api"
	"mytodo/internal/db"
	"mytodo/internal/model"
	"net/http"

	"github.com/caarlos0/log"
	"github.com/gin-gonic/gin"
	"github.com/minio/minio-go/v7"
	"gorm.io/gorm"
)

func ChatTopicNew(ctx *gin.Context) {
	var req api.ChatTopicNewRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	user, ok := getUser(ctx)
	if !ok {
		return
	}

	if req.ReplyId != 0 {
		reply := model.MessageReply{
			MessageId: req.ReplyId,
			ReplyBy:   req.ReplyBy,
			ReplyTo:   req.ReplyTo,
		}
		tx := db.SQL().Begin()
		err = tx.Table("message_reply").Create(&reply).Error
		if err != nil {
			tx.Rollback()
			ctx.Abort()
			log.WithError(err).Error("fail to create message_reply")
			return
		}
		msg := model.MessageTopic{
			TopicId: req.TopicId,
			Message: model.Message{
				SentBy:        user.ID,
				Message:       req.Message,
				MessageType:   convertMessageType(req.MessageType),
				VoiceDuration: req.VoiceDuration,
				ReplyId:       reply.ID,
			},
		}

		err = tx.Table("message_topic").Create(&msg).Error
		if err != nil {
			tx.Rollback()
			ctx.Abort()
			log.WithError(err).Error("fail to create message_reply")
			return
		}

		if err = tx.Commit().Error; err != nil {
			log.WithError(err).Error("fail to commit tx")
			ctx.Abort()
			return
		}
	} else {
		msg := model.MessageTopic{
			TopicId: req.TopicId,
			Message: model.Message{
				SentBy:        user.ID,
				Message:       req.Message,
				MessageType:   convertMessageType(req.MessageType),
				VoiceDuration: req.VoiceDuration,
			},
		}

		err = db.SQL().Table("message_topic").Create(&msg).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
	}
}

func convertMessageType(t string) model.MessageType {
	switch t {
	case "text":
		return model.MessageTypeText
	case "image":
		return model.MessageTypeImage
	case "voice":
		return model.MessageTypeVoice
	case "custom":
		return model.MessageTypeCustom
	}
	return 0
}

func ChatTopicGet(ctx *gin.Context) {
	var req api.ChatTopicGetRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	user, ok := getUser(ctx)
	if !ok {
		return
	}
	fmt.Println("check user in topic", user.ID)
	var messages []model.Message
	err = db.SQL().Table("message_topic").
		Where("topic_id = ?", req.TopicId).
		Offset((req.Page - 1) * req.PageSize).
		Limit(req.PageSize).
		Find(&messages).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	for i, m := range messages {
		if m.ReplyId != 0 {
			reply := &model.MessageReply{}
			err = db.SQL().Table("message_reply").Where("id = ?", m.ReplyId).First(reply).Error
			if err != nil {
				log.WithError(err).Error("running sql")
				ctx.Abort()
				return
			}
			messages[i].ReplyMessage = reply
			var msg model.Message
			err = db.SQL().Table("message_topic").Where("id = ?", reply.MessageId).First(&msg).Error
			if err != nil {
				log.WithError(err).Error("running sql")
				ctx.Abort()
				return
			}
			reply.Message = msg.Message
			reply.MessageType = msg.MessageType
			reply.VoiceDuration = msg.VoiceDuration
		}
		var reactions []model.MessageReaction
		err = db.SQL().Table("message_reaction").Where("message_id = ?", m.ID).Find(&reactions).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		if len(reactions) != 0 {
			messages[i].Reactions = reactions
		}
	}

	ctx.JSON(200, gin.H{"code": 200, "msg": "", "data": messages})
}

func ChatTopicDel(ctx *gin.Context) {

}

func ChatTopicReaction(ctx *gin.Context) {
	var req api.ChatTopicReactionRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	user, ok := getUser(ctx)
	if !ok {
		return
	}
	var react model.MessageReaction
	err = db.SQL().Table("message_reaction").Where("message_id = ?", req.MessageId).First(&react).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			react.MessageId = req.MessageId
			react.Reaction = req.Emoji
			react.ReactedUserId = user.ID
			err = db.SQL().Create(&react).Error
			if err != nil {
				log.WithError(err).Error("running sql")
				ctx.Abort()
				return
			}
			return
		}
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	err = db.SQL().Delete(&react).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
}

func ChatTopicUpload(ctx *gin.Context) {
	file, err := ctx.FormFile("file")
	if err != nil {
		log.WithError(err).Error("fail to read formFile")
		ctx.Abort()
		return
	}
	data, err := file.Open()
	if err != nil {
		log.WithError(err).Error("fail to open file")
		ctx.Abort()
		return
	}
	defer data.Close()
	// _, err = db.OSS().PutObject(context.TODO(), "chat", fmt.Sprintf("/topic/%s%s", uuid.New(), filepath.Ext(file.Filename)), data, file.Size, minio.PutObjectOptions{})
	_, err = db.OSS().PutObject(context.TODO(), "chat", fmt.Sprintf("/topic/%s", file.Filename), data, file.Size, minio.PutObjectOptions{})
	if err != nil {
		log.WithError(err).Error("fail to upload file")
		ctx.Abort()
		return
	}
}

func ChatTopicImage(ctx *gin.Context) {
	filename := ctx.Param("filename")

	obj, err := db.OSS().GetObject(context.TODO(), "chat", fmt.Sprintf("/topic/%s.png", filename), minio.GetObjectOptions{})
	if err != nil {
		log.WithError(err).Debug("getting profile")
	}
	defer obj.Close()

	ctx.Header("Content-Type", "image/png")
	ctx.Header("Content-Disposition", "inline; filename=profile.png")

	_, err = io.Copy(ctx.Writer, obj)
	if err != nil {
		log.WithError(err).Error("writing image to response")
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Error while sending profile image"})
		return
	}
}
