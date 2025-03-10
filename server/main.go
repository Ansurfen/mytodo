package main

import (
	"context"
	"encoding/json"
	"fmt"
	"mytodo/internal/conf"
	"mytodo/internal/db"
	"mytodo/internal/middleware"
	"mytodo/internal/model"
	"mytodo/internal/routes"

	"github.com/caarlos0/log"
	"github.com/gin-gonic/gin"
	"github.com/minio/minio-go/v7"
	"gorm.io/datatypes"
)

var cfg conf.TodoConf

func init() {
	log.SetLevel(log.DebugLevel)
	cfg = conf.New()
	db.SetSQL(db.NewSQL(cfg.SQL))
	db.SetRdb(db.NewRdb(cfg.Redis))
	db.SetOSS(db.NewOSS(cfg.Minio))
	exist, err := db.OSS().BucketExists(context.TODO(), "user")
	if err != nil {
		log.WithError(err).Fatal("verifying bucket")
	}
	if !exist {
		err = db.OSS().MakeBucket(context.TODO(), "user", minio.MakeBucketOptions{})
		if err != nil {
			log.WithError(err).Fatal("fail to create bucket")
		}
	}

	exist, err = db.OSS().BucketExists(context.TODO(), "chat")
	if err != nil {
		log.WithError(err).Fatal("verifying bucket")
	}
	if !exist {
		err = db.OSS().MakeBucket(context.TODO(), "chat", minio.MakeBucketOptions{})
		if err != nil {
			log.WithError(err).Fatal("fail to create bucket")
		}
	}

	exist, err = db.OSS().BucketExists(context.TODO(), "topic")
	if err != nil {
		log.WithError(err).Fatal("verifying bucket")
	}
	if !exist {
		err = db.OSS().MakeBucket(context.TODO(), "topic", minio.MakeBucketOptions{})
		if err != nil {
			log.WithError(err).Fatal("fail to create bucket")
		}
	}
	db.SQL().AutoMigrate(
		model.User{},
		model.UserRelation{},
		model.Notification{},
		model.NotificationPublish{},
		model.NotificationAction{},
		model.MessageTopic{},
		model.MessageFriend{},
		model.MessageReply{},
		model.MessageReaction{},
		model.Topic{},
		model.TopicJoin{},
		model.TopicPolicy{},
		model.Task{},
		model.TaskCommit{},
		model.TaskCondition{},
		model.Post{})
}

func main() {
	r := gin.Default()
	r.Use(middleware.CORS())
	routes.InstallUserRoute(r)
	routes.InstallChatRoute(r)
	routes.InstallTopicRoute(r)
	routes.InstallNotificationRoute(r)
	routes.InstallTaskRoute(r)
	jsonData := `[
		{ 
			"insert": { "image": "kScreenshot2" },
			"attributes": { "width": "100", "height": "100", "style": "width:500px; height:350px;" } 
		},
		{ "insert": "Flutter Quill" },
		{ "insert": { "video": "https://www.youtube.com/watch?v=V4hgdKhIqtc" } },
		{ "insert": "Rich text editor for Flutter" },
		{ "insert": "Quill component for Flutter" },
		{ "insert": { "link": "https://bulletjournal.us/home/index.html" } }
	]`

	var data []datatypes.JSONMap
	if err := json.Unmarshal([]byte(jsonData), &data); err != nil {
		panic(err)
	}
	db.SQL().Table("post").Create(&model.Post{
		Title: "t1",
		Text:  datatypes.JSONSlice[datatypes.JSONMap](data),
	})
	db.SQL().Table("post").Create(&model.Post{
		Title: "t2",
		Text:  datatypes.JSONSlice[datatypes.JSONMap](data),
	})
	var results []model.Post
	db.SQL().Table("post").Where("MATCH(extracted_text) AGAINST(? IN NATURAL LANGUAGE MODE)", "Flutter").Find(&results)
	fmt.Println(results)
	r.POST("/upload", func(ctx *gin.Context) {
		file, err := ctx.FormFile("file")
		if err != nil {
			panic(err)
		}
		src, err := file.Open()
		if err != nil {
			ctx.Abort()
			return
		}
		defer src.Close()

		db.OSS().PutObject(context.TODO(), "chat", file.Filename, src, file.Size, minio.PutObjectOptions{})
	})
	r.Run(fmt.Sprintf("%s:%s", cfg.Server.Host, cfg.Server.Port))
}

type Message struct {
	Id           string `json:"id"`
	Message      string `json:"message"`
	CreatedAt    string `json:"createdAt"`
	SentBy       string `json:"sentBy"`
	ReplyMessage struct {
		Message       string `json:"message"`
		ReplyBy       string `json:"replyBy"`
		ReplyTo       string `json:"replyTo"`
		MessageType   string `json:"message_type"`
		Id            string `json:"messageId"`
		VoiceDuration uint   `json:"voiceMessageDuration"`
	} `json:"reply_message"`
	Reaction struct {
		Reactions      []string `json:"reactions"`
		ReactedUserIds []string `json:"reactedUserIds"`
	}
	MessageType   string `json:"message_type"`
	VoiceDuration uint   `json:"voice_message_duration"`
	Status        string `json:"status"`
}
