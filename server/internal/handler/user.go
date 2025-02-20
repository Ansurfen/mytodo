package handler

import (
	"bytes"
	"context"
	"crypto/md5"
	"fmt"
	"image/color"
	"image/png"
	"io"
	"mytodo/internal/api"
	"mytodo/internal/db"
	"mytodo/internal/middleware"
	"mytodo/internal/model"
	"net/http"
	"strconv"
	"time"

	"github.com/caarlos0/log"
	"github.com/gin-gonic/gin"
	"github.com/issue9/identicon/v2"
	"github.com/minio/minio-go/v7"
	"gorm.io/gorm"
)

var profiler = identicon.New(identicon.Style2, 128, color.RGBA{R: 255, G: 0, B: 0, A: 100}, color.RGBA{R: 0, G: 255, B: 255, A: 100})

func UserSign(ctx *gin.Context) {
	var req api.UserSignRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}

	// validates email

	var user model.User
	err = db.SQL().Table("user").Where("email = ?", req.Email).First(&user).Error
	if err != nil && err != gorm.ErrRecordNotFound {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	var res api.UserSignResponse

	if user.ID == 0 {
		log.Debugf("creating new user")
		user.Email = req.Email
		user.Password = MD5(req.Password)
		err = db.SQL().Table("user").Create(&user).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}

		img := profiler.Make([]byte(fmt.Sprintf("user_%d", user.ID)))
		var buf bytes.Buffer
		err = png.Encode(&buf, img)
		if err != nil {
			log.WithError(err).Fatal("generating image")
			ctx.Abort()
			return
		}
		_, err = db.OSS().PutObject(context.TODO(), "user", fmt.Sprintf("/profile/%d.png", user.ID), &buf, int64(buf.Len()), minio.PutObjectOptions{})
		if err != nil {
			log.WithError(err).Fatal("fail to upload image")
			ctx.Abort()
			return
		}

		res.JWT, err = middleware.ReleaseToken(user.ID)
		if err != nil {
			log.WithError(err).Error("releasing token")
			ctx.Abort()
			return
		}
		err = db.Rdb().Set(context.TODO(), fmt.Sprintf("user_%d", user.ID), res.JWT, 7*24*time.Hour).Err()
		if err != nil {
			log.WithError(err).Error("setting cache")
			ctx.Abort()
			return
		}
	} else {
		if user.Password != MD5(req.Password) {
			log.Error("password not match")
			ctx.Abort()
			return
		}
		val, err := db.Rdb().Get(context.TODO(), fmt.Sprintf("user_%d", user.ID)).Result()
		if err != nil {
			res.JWT, err = middleware.ReleaseToken(user.ID)
			if err != nil {
				log.WithError(err).Error("releasing token")
				ctx.Abort()
				return
			}
			err = db.Rdb().Set(context.TODO(), fmt.Sprintf("user_%d", user.ID), res.JWT, 7*24*time.Hour).Err()
			if err != nil {
				log.WithError(err).Error("setting cache")
				ctx.Abort()
				return
			}
		} else {
			res.JWT = val
		}
	}

	ctx.JSON(200, res)
}

func UserGet(ctx *gin.Context) {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		log.WithError(err).Error("parsing id")
		ctx.Abort()
		return
	}
	var user model.User
	err = db.SQL().Table("user").Where("id = ?", id).First(&user).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	ctx.JSON(200, api.UserGetResponse{User: user})
}

func UserProfile(ctx *gin.Context) {
	id, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		log.WithError(err).Error("parsing id")
		ctx.Abort()
		return
	}
	obj, err := db.OSS().GetObject(context.TODO(), "user", fmt.Sprintf("/profile/%d.png", id), minio.GetObjectOptions{})
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

func UserOnline(ctx *gin.Context) {
	keys, _, err := db.Rdb().Scan(context.TODO(), 100, "*user_*", 100).Result()
	if err != nil {
		log.WithError(err).Error("fail to get online users")
		ctx.Abort()
		return
	}
	ctx.JSON(200, api.UserOnlineResponse{Users: keys})
}

func FriendNew(ctx *gin.Context) {
	var req api.FriendNewRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	val, ok := ctx.Get("user")
	if !ok {
		log.Error("invalid user")
		ctx.Abort()
		return
	}
	user := val.(model.User)
	rel := model.UserRelation{
		UserId:   user.ID,
		FriendId: req.FriendId,
	}
	err = db.SQL().Table("user_relation").Create(&rel).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	ctx.JSON(200, gin.H{})
}

func FriendGet(ctx *gin.Context) {}

func FriendDel(ctx *gin.Context) {}

func MD5(str string) string {
	return fmt.Sprintf("%x", md5.Sum([]byte(str)))
}
