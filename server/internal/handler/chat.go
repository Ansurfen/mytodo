package handler

import (
	"context"
	"fmt"
	"io"
	"mytodo/internal/api"
	"mytodo/internal/db"
	"mytodo/internal/model"
	"net/http"
	"path/filepath"
	"sort"
	"strconv"
	"time"

	"github.com/caarlos0/log"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
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

	var msg model.MessageTopic
	if req.ReplyId != 0 {
		reply := model.MessageReply{
			MessageId: req.ReplyId,
			ReplyBy:   req.ReplyTo,
			ReplyTo:   req.ReplyTo,
		}
		tx := db.SQL().Begin()
		err = tx.Table("message_topic_reply").Create(&reply).Error
		if err != nil {
			tx.Rollback()
			ctx.Abort()
			log.WithError(err).Error("fail to create message_reply")
			return
		}
		msg = model.MessageTopic{
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
		msg = model.MessageTopic{
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

	// 获取发送者信息
	var sender model.User
	err = db.SQL().Table("user").Where("id = ?", user.ID).First(&sender).Error
	if err != nil {
		log.WithError(err).Error("fail to get sender info")
		return
	}

	// 获取群组所有成员
	var members []model.TopicJoin
	err = db.SQL().Table("topic_join").Where("topic_id = ?", req.TopicId).Find(&members).Error
	if err != nil {
		log.WithError(err).Error("fail to get topic members")
		return
	}

	// 构建WebSocket消息
	wsMsg := map[string]interface{}{
		"type": "topic",
		"message": map[string]interface{}{
			"topic_id":    req.TopicId,
			"message":     req.Message,
			"sender_name": sender.Name,
			"created_at":  msg.CreatedAt.Format(time.RFC3339),
		},
	}

	// 广播消息给所有群组成员
	for _, member := range members {
		db.WS().Send(fmt.Sprintf("user_%d", member.UserId), wsMsg)
	}
}

func ChatFriendNew(ctx *gin.Context) {
	var req api.ChatFriendNewRequest
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

	var msg model.MessageFriend
	if req.ReplyId != 0 {
		reply := model.MessageReply{
			MessageId: req.ReplyId,
			ReplyBy:   req.ReplyTo,
			ReplyTo:   req.ReplyTo,
		}
		tx := db.SQL().Begin()
		err = tx.Table("message_friend_reply").Create(&reply).Error
		if err != nil {
			tx.Rollback()
			ctx.Abort()
			log.WithError(err).Error("fail to create message_reply")
			return
		}
		msg = model.MessageFriend{
			FriendId: req.FriendId,
			Message: model.Message{
				SentBy:        user.ID,
				Message:       req.Message,
				MessageType:   convertMessageType(req.MessageType),
				VoiceDuration: req.VoiceDuration,
				ReplyId:       reply.ID,
			},
		}

		err = tx.Table("message_friend").Create(&msg).Error
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
		msg = model.MessageFriend{
			FriendId: req.FriendId,
			Message: model.Message{
				SentBy:        user.ID,
				Message:       req.Message,
				MessageType:   convertMessageType(req.MessageType),
				VoiceDuration: req.VoiceDuration,
			},
		}

		err = db.SQL().Table("message_friend").Create(&msg).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
	}

	// 获取发送者信息
	var sender model.User
	err = db.SQL().Table("user").Where("id = ?", user.ID).First(&sender).Error
	if err != nil {
		log.WithError(err).Error("fail to get sender info")
		return
	}

	// 构建WebSocket消息
	wsMsg := map[string]interface{}{
		"type": "friend",
		"message": map[string]interface{}{
			"friend_id":   req.FriendId,
			"message":     req.Message,
			"sender_name": sender.Name,
			"created_at":  msg.CreatedAt.Format(time.RFC3339),
		},
	}

	// 发送消息给接收者
	db.WS().Send(fmt.Sprintf("user_%d", req.FriendId), wsMsg)
	// 发送消息给发送者（用于同步）
	db.WS().Send(fmt.Sprintf("user_%d", user.ID), wsMsg)
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
			err = db.SQL().Table("message_topic_reply").Where("id = ?", m.ReplyId).First(reply).Error
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
		err = db.SQL().Table("message_topic_reaction").Where("message_id = ?", m.ID).Find(&reactions).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		if len(reactions) != 0 {
			messages[i].Reactions = reactions
		}
	}

	ctx.JSON(http.StatusOK, gin.H{"code": 200, "msg": "", "data": messages})
}

func ChatFriendGet(ctx *gin.Context) {
	var req api.ChatFriendGetRequest
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
	err = db.SQL().Table("message_friend").
		Where("(friend_id = ? AND sent_by = ?) OR (friend_id = ? AND sent_by = ?)",
			req.FriendId, user.ID, user.ID, req.FriendId).
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
			err = db.SQL().Table("message_friend_reply").Where("id = ?", m.ReplyId).First(reply).Error
			if err != nil {
				log.WithError(err).Error("running sql")
				ctx.Abort()
				return
			}
			messages[i].ReplyMessage = reply
			var msg model.Message
			err = db.SQL().Table("message_friend").Where("id = ?", reply.MessageId).First(&msg).Error
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
		err = db.SQL().Table("message_friend_reaction").Where("message_id = ?", m.ID).Find(&reactions).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		if len(reactions) != 0 {
			messages[i].Reactions = reactions
		}
	}
	ctx.JSON(http.StatusOK, gin.H{"msg": "", "data": messages})
}

func ChatSnap(ctx *gin.Context) {
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	var messageTopic []messageSnap
	err := db.SQL().Rawf(`SELECT 
    tj.topic_id AS Id,
    lm.id AS last_message_id,
    lm.message AS last_message,
    u.name AS last_sender_name,
    lm.created_at,
    COUNT(mt.id) AS unread_count,
    t.name AS name,
	t.icon AS icon
FROM 
    topic_join tj
LEFT JOIN message_topic_unread mtu
    ON tj.topic_id = mtu.topic_id AND tj.user_id = mtu.user_id
JOIN (
    SELECT 
        topic_id,
        MAX(id) AS last_message_id
    FROM 
        message_topic
    GROUP BY topic_id
) last_msg_ids ON tj.topic_id = last_msg_ids.topic_id
JOIN message_topic lm ON lm.id = last_msg_ids.last_message_id
JOIN user u ON lm.sent_by = u.id
LEFT JOIN message_topic mt
    ON mt.topic_id = tj.topic_id
   AND mt.id > COALESCE(mtu.last_read_message_id, 0)
JOIN topic t ON tj.topic_id = t.id
WHERE 
    tj.user_id = %d
GROUP BY 
    tj.topic_id, lm.id, lm.message, u.name, lm.created_at, t.name
ORDER BY 
    lm.created_at DESC;
`, u.ID).Find(&messageTopic).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	var messageFriend []messageSnap
	err = db.SQL().Rawf(`SELECT
	u.name AS name,
    ur.friend_id AS Id,
    lm.id AS last_message_id,
    lm.message AS last_message,
    u.name AS last_sender_name,
    lm.created_at,
    COUNT(m.id) AS unread_count
FROM 
    user_relation ur
LEFT JOIN message_friend_unread mfu
    ON ur.friend_id = mfu.friend_id AND ur.user_id = mfu.user_id
JOIN (
    SELECT 
        friend_id,
        MAX(id) AS last_message_id
    FROM 
        message_friend
    GROUP BY friend_id
) last_msg_ids ON ur.friend_id = last_msg_ids.friend_id
JOIN message_friend lm ON lm.id = last_msg_ids.last_message_id
JOIN user u ON lm.sent_by = u.id
LEFT JOIN message_friend m
    ON m.friend_id = ur.friend_id
   AND m.id > COALESCE(mfu.last_read_message_id, 0)
WHERE 
    ur.user_id = %d
GROUP BY 
    ur.friend_id, lm.id, lm.message, u.name, lm.created_at
ORDER BY 
    lm.created_at DESC;`, u.ID).Find(&messageFriend).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	for i := 0; i < len(messageTopic); i++ {
		messageTopic[i].IsTopic = true
	}
	for i := 0; i < len(messageFriend); i++ {
		_, _, err = db.Rdb().Scan(context.TODO(), 100, fmt.Sprintf("*user_%d*", messageFriend[i].Id), 1).Result()
		if err == nil {
			messageFriend[i].Online = true
		}
	}
	combined := append(messageTopic, messageFriend...)

	sort.Slice(combined, func(i, j int) bool {
		return combined[i].CreatedAt.After(combined[j].CreatedAt)
	})

	ctx.JSON(http.StatusOK, gin.H{"msg": "", "data": combined})
}

type messageSnap struct {
	IsTopic        bool      `json:"is_topic"`
	Online         bool      `json:"is_online"`
	Name           string    `json:"name"`
	Id             uint      `json:"id"`
	Icon           string    `json:"icon"`
	LastMessageId  uint      `json:"last_message_id"`
	LastMessage    string    `json:"last_message"`
	LastSenderName string    `json:"last_sender_name"`
	CreatedAt      time.Time `json:"last_at"`
	UnreadCount    uint      `json:"unreaded"`
}

func ChatTopicReaction(ctx *gin.Context) {
	var req api.ChatReactionRequest
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
	var react model.MessageTopicReaction
	err = db.SQL().Table("message_topic_reaction").Where("message_id = ?", req.MessageId).First(&react).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			react.MessageId = req.MessageId
			react.Reaction = req.Emoji
			react.ReactedUserId = user.ID
			err = db.SQL().Table("message_topic_reaction").Create(&react).Error
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
	if react.Reaction == req.Emoji {
		err = db.SQL().Table("message_topic_reaction").Delete(&react).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
	} else {
		react.Reaction = req.Emoji
		err = db.SQL().Table("message_topic_reaction").Save(&react).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
	}
}

func ChatFriendReaction(ctx *gin.Context) {
	var req api.ChatReactionRequest
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
	var react model.MessageFriendReaction
	err = db.SQL().Table("message_friend_reaction").Where("message_id = ?", req.MessageId).First(&react).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			react.MessageId = req.MessageId
			react.Reaction = req.Emoji
			react.ReactedUserId = user.ID
			err = db.SQL().Table("message_friend_reaction").Create(&react).Error
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
	if react.Reaction == req.Emoji {
		err = db.SQL().Table("message_friend_reaction").Delete(&react).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
	} else {
		react.Reaction = req.Emoji
		err = db.SQL().Table("message_friend_reaction").Save(&react).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
	}
}

func getAudioDuration(data io.ReadSeeker) (uint, error) {
	// 获取文件大小
	size, err := data.Seek(0, io.SeekEnd)
	if err != nil {
		return 0, err
	}

	// 重置文件指针到开始位置
	_, err = data.Seek(0, io.SeekStart)
	if err != nil {
		return 0, err
	}

	// 估算音频时长（假设 m4a 文件的平均比特率为 128kbps）
	// 时长（秒）= 文件大小（字节）* 8 / 比特率（bps）
	bitrate := 128 * 1024 // 128kbps
	duration := float64(size) * 8 / float64(bitrate)

	return uint(duration), nil
}

func ChatTopicUpload(ctx *gin.Context) {
	var req api.ChatTopicUploadRequest
	err := ctx.Bind(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse formdata")
		ctx.Abort()
		return
	}

	data, err := req.File.Open()
	if err != nil {
		log.WithError(err).Error("fail to open file")
		ctx.Abort()
		return
	}
	defer data.Close()

	// 如果是语音文件，获取时长
	voiceDuration := req.VoiceDuration
	if req.File.Filename == "voice.m4a" {
		duration, err := getAudioDuration(data)
		if err != nil {
			log.WithError(err).Error("fail to get audio duration")
			ctx.Abort()
			return
		}
		voiceDuration = duration
		// 重置文件指针到开始位置
		data.Seek(0, io.SeekStart)
	}

	filename := uuid.New().String() + filepath.Ext(req.File.Filename)
	_, err = db.OSS().PutObject(context.TODO(), "chat", fmt.Sprintf("/topic/%s", filename), data, req.File.Size, minio.PutObjectOptions{})
	if err != nil {
		log.WithError(err).Error("fail to upload file")
		ctx.Abort()
		return
	}

	u, ok := getUser(ctx)
	if !ok {
		return
	}
	topicId, err := strconv.Atoi(req.TopicId)
	if err != nil {
		log.WithError(err).Error("fail to parse topic id")
		ctx.Abort()
		return
	}
	replyId, _ := strconv.Atoi(req.ReplyId)

	messageType := model.MessageTypeImage
	if req.File.Filename == "voice.m4a" {
		messageType = model.MessageTypeVoice
	}

	msg := model.MessageTopic{
		TopicId: uint(topicId),
		Message: model.Message{
			SentBy:        u.ID,
			Message:       filename,
			MessageType:   messageType,
			VoiceDuration: voiceDuration,
			ReplyId:       uint(replyId),
		},
	}

	err = db.SQL().Table("message_topic").Create(&msg).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	// 获取发送者信息
	var sender model.User
	err = db.SQL().Table("user").Where("id = ?", u.ID).First(&sender).Error
	if err != nil {
		log.WithError(err).Error("fail to get sender info")
		return
	}

	// 获取群组所有成员
	var members []model.TopicJoin
	err = db.SQL().Table("topic_join").Where("topic_id = ?", req.TopicId).Find(&members).Error
	if err != nil {
		log.WithError(err).Error("fail to get topic members")
		return
	}

	// 构建WebSocket消息
	wsMsg := map[string]interface{}{
		"type": "topic",
		"message": map[string]interface{}{
			"topic_id":               req.TopicId,
			"message":                filename,
			"sender_name":            sender.Name,
			"created_at":             msg.CreatedAt.Format(time.RFC3339),
			"message_type":           messageType,
			"voice_message_duration": voiceDuration,
		},
	}

	// 广播消息给所有群组成员
	for _, member := range members {
		db.WS().Send(fmt.Sprintf("user_%d", member.UserId), wsMsg)
	}

	ctx.JSON(http.StatusOK, gin.H{"msg": ""})
}

func ChatFriendUpload(ctx *gin.Context) {
	var req api.ChatFriendUploadRequest
	err := ctx.Bind(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse formdata")
		ctx.Abort()
		return
	}

	data, err := req.File.Open()
	if err != nil {
		log.WithError(err).Error("fail to open file")
		ctx.Abort()
		return
	}
	defer data.Close()

	// 如果是语音文件，获取时长
	voiceDuration := req.VoiceDuration
	if req.File.Filename == "voice.m4a" {
		duration, err := getAudioDuration(data)
		if err != nil {
			log.WithError(err).Error("fail to get audio duration")
			ctx.Abort()
			return
		}
		voiceDuration = duration
		// 重置文件指针到开始位置
		data.Seek(0, io.SeekStart)
	}

	filename := uuid.New().String() + filepath.Ext(req.File.Filename)
	_, err = db.OSS().PutObject(context.TODO(), "chat", fmt.Sprintf("/friend/%s", filename), data, req.File.Size, minio.PutObjectOptions{})
	if err != nil {
		log.WithError(err).Error("fail to upload file")
		ctx.Abort()
		return
	}

	u, ok := getUser(ctx)
	if !ok {
		return
	}
	friendId, err := strconv.Atoi(req.FriendId)
	if err != nil {
		log.WithError(err).Error("fail to parse friend id")
		ctx.Abort()
		return
	}
	replyId, _ := strconv.Atoi(req.ReplyId)

	messageType := model.MessageTypeImage
	if req.File.Filename == "voice.m4a" {
		messageType = model.MessageTypeVoice
	}

	msg := model.MessageFriend{
		FriendId: uint(friendId),
		Message: model.Message{
			SentBy:        u.ID,
			Message:       filename,
			MessageType:   messageType,
			VoiceDuration: voiceDuration,
			ReplyId:       uint(replyId),
		},
	}

	err = db.SQL().Table("message_friend").Create(&msg).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	// 获取发送者信息
	var sender model.User
	err = db.SQL().Table("user").Where("id = ?", u.ID).First(&sender).Error
	if err != nil {
		log.WithError(err).Error("fail to get sender info")
		return
	}

	// 构建WebSocket消息
	wsMsg := map[string]interface{}{
		"type": "friend",
		"message": map[string]interface{}{
			"friend_id":              req.FriendId,
			"message":                filename,
			"sender_name":            sender.Name,
			"created_at":             msg.CreatedAt.Format(time.RFC3339),
			"message_type":           messageType,
			"voice_message_duration": voiceDuration,
		},
	}

	// 发送消息给接收者
	db.WS().Send(fmt.Sprintf("user_%s", req.FriendId), wsMsg)
	// 发送消息给发送者（用于同步）
	db.WS().Send(fmt.Sprintf("user_%d", u.ID), wsMsg)

	ctx.JSON(http.StatusOK, gin.H{"msg": ""})
}

func ChatTopicFile(ctx *gin.Context) {
	filename := ctx.Param("filename")

	obj, err := db.OSS().GetObject(context.TODO(), "chat", fmt.Sprintf("/topic/%s", filename), minio.GetObjectOptions{})
	if err != nil {
		log.WithError(err).Debug("getting profile")
	}
	defer obj.Close()

	if filepath.Ext(filename) == ".m4a" {
		ctx.Header("Content-Type", "audio/m4a")
		ctx.Header("Content-Disposition", "inline; filename=profile.m4a")
	} else {
		ctx.Header("Content-Type", "image/png")
		ctx.Header("Content-Disposition", "inline; filename=profile.png")
	}

	_, err = io.Copy(ctx.Writer, obj)
	if err != nil {
		log.WithError(err).Error("writing image to response")
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Error while sending profile image"})
		return
	}
}

func ChatFriendFile(ctx *gin.Context) {
	filename := ctx.Param("filename")

	obj, err := db.OSS().GetObject(context.TODO(), "chat", fmt.Sprintf("/friend/%s", filename), minio.GetObjectOptions{})
	if err != nil {
		log.WithError(err).Debug("getting profile")
	}
	defer obj.Close()

	if filepath.Ext(filename) == ".m4a" {
		ctx.Header("Content-Type", "audio/m4a")
		ctx.Header("Content-Disposition", "inline; filename=profile.m4a")
	} else {
		ctx.Header("Content-Type", "image/png")
		ctx.Header("Content-Disposition", "inline; filename=profile.png")
	}

	_, err = io.Copy(ctx.Writer, obj)
	if err != nil {
		log.WithError(err).Error("writing image to response")
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Error while sending profile image"})
		return
	}
}

func ChatTopicRead(ctx *gin.Context) {
	var req api.ChatTopicReadRequest
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

	var readed model.MessageTopicUnread
	err = db.SQL().Table("message_topic_unread").Where("topic_id = ? AND user_id = ?", req.TopicId, u.ID).First(&readed).Error
	if err != nil && err != gorm.ErrRecordNotFound {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	if err == nil {
		if readed.LastReadMessageId < req.LastMessageId {
			readed.LastReadMessageId = req.LastMessageId
			err = db.SQL().Table("message_topic_unread").Save(&readed).Error
			if err != nil {
				log.WithError(err).Error("running sql")
				ctx.Abort()
				return
			}
		}
	} else {
		readed = model.MessageTopicUnread{
			TopicId:           req.TopicId,
			UserId:            u.ID,
			LastReadMessageId: req.LastMessageId,
		}
		err = db.SQL().Table("message_topic_unread").Create(&readed).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
	}
}

func ChatFriendRead(ctx *gin.Context) {
	var req api.ChatFriendReadRequest
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

	var readed model.MessageFriendUnread
	err = db.SQL().Table("message_friend_unread").Where("friend_id = ? AND user_id = ?", req.FriendId, u.ID).First(&readed).Error
	if err != nil && err != gorm.ErrRecordNotFound {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	if err == nil {
		if readed.LastReadMessageId < req.LastMessageId {
			readed.LastReadMessageId = req.LastMessageId
			err = db.SQL().Table("message_friend_unread").Save(&readed).Error
			if err != nil {
				log.WithError(err).Error("running sql")
				ctx.Abort()
				return
			}
		}
	} else {
		readed = model.MessageFriendUnread{
			FriendId:          req.FriendId,
			UserId:            u.ID,
			LastReadMessageId: req.LastMessageId,
		}
		err = db.SQL().Table("message_friend_unread").Create(&readed).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
	}
}
