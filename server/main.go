package main

import (
	"context"
	"fmt"
	"mytodo/internal/conf"
	"mytodo/internal/db"
	"mytodo/internal/middleware"
	"mytodo/internal/model"
	"mytodo/internal/routes"

	_ "mytodo/docs" // 这里会导入swagger文档

	"github.com/caarlos0/log"
	"github.com/gin-gonic/gin"
	"github.com/minio/minio-go/v7"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

// @title           MyTodo API
// @version         1.0
// @description     A todo list service API in Go using Gin framework.
// @termsOfService  http://swagger.io/terms/

// @contact.name   API Support
// @contact.url    http://www.swagger.io/support
// @contact.email  support@swagger.io

// @license.name  Apache 2.0
// @license.url   http://www.apache.org/licenses/LICENSE-2.0.html

// @host      192.168.240.42:8080

// @securityDefinitions.apikey Bearer
// @in header
// @name Authorization

var cfg conf.TodoConf

func init() {
	log.SetLevel(log.DebugLevel)
	cfg = conf.New()
	db.SetSQL(db.NewSQL(cfg.SQL))
	db.SetRdb(db.NewRdb(cfg.Redis))
	db.SetOSS(db.NewOSS(cfg.Minio))
	err := db.OSS().MakeBuckets("user", "chat", "topic", "post", "task")
	if err != nil {
		panic(err)
	}

	db.SQL().AutoMigrate(
		model.User{},
		model.UserRelation{},
		model.Notification{},
		model.NotificationPublish{},
		model.NotificationAction{},
		model.MessageTopic{},
		model.MessageFriend{},
		model.MessageTopicReply{},
		model.MessageFriendReply{},
		model.MessageTopicReaction{},
		model.MessageFriendReaction{},
		model.MessageFriendUnread{},
		model.MessageTopicUnread{},
		model.Topic{},
		model.TopicJoin{},
		model.TopicPolicy{},
		model.Task{},
		model.TaskCommit{},
		model.TaskCondition{},
		model.Post{},
		model.PostLike{},
		model.PostVisit{},
		model.PostComment{},
		model.PostCommentLike{})
}

func main() {
	gin.SetMode(gin.ReleaseMode)
	r := gin.Default()
	r.Use(middleware.CORS())
	r.Use(middleware.Prometheus())

	// 先注册 metrics 端点
	r.GET("/internal/metrics", func(c *gin.Context) {
		promhttp.Handler().ServeHTTP(c.Writer, c.Request)
	})

	// Swagger API文档路由
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	routes.InstallUserRoute(r)
	routes.InstallChatRoute(r)
	routes.InstallTopicRoute(r)
	routes.InstallNotificationRoute(r)
	routes.InstallTaskRoute(r)
	routes.InstallPostRoute(r)
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
