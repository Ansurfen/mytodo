package main

import (
	"context"
	"mytodo/internal/conf"
	"mytodo/internal/db"
	"mytodo/internal/middleware"
	"mytodo/internal/model"
	"mytodo/internal/routes"

	"github.com/caarlos0/log"
	"github.com/gin-gonic/gin"
	"github.com/minio/minio-go/v7"
)

func init() {
	log.SetLevel(log.DebugLevel)
	cfg := conf.New()
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
	db.SQL().AutoMigrate(
		model.User{},
		model.UserRelation{},
		model.Notification{},
		model.NotificationPublish{},
		model.NotificationAction{})
}

func main() {
	r := gin.Default()
	r.Use(middleware.CORS())
	routes.InstallUserRoute(r)
	r.Run()
}
