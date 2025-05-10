package handler

import (
	"bytes"
	"context"
	"crypto/md5"
	"errors"
	"fmt"
	"image/png"
	"io"
	"math/rand"
	"mytodo/internal/api"
	"mytodo/internal/db"
	"mytodo/internal/middleware"
	"mytodo/internal/model"
	"net/http"
	"strconv"
	"time"

	"github.com/brianvoe/gofakeit/v7"
	"github.com/caarlos0/log"
	"github.com/gin-gonic/gin"
	"github.com/minio/minio-go/v7"
	"github.com/o1egl/govatar"
	"gorm.io/gorm"
)

func UserSign(ctx *gin.Context) {
	var req api.UserLoginRequest
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
		user.Name = gofakeit.Username()
		user.Email = req.Email
		user.Password = MD5(req.Password)
		err = db.SQL().Table("user").Create(&user).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}

		img, err := govatar.Generate(govatar.Gender(user.ID % 2))
		if err != nil {
			log.WithError(err).Fatal("generating image")
			ctx.Abort()
			return
		}

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
		err = db.SQL().Table("user_relation").Create(&model.UserRelation{
			UserId:   user.ID,
			FriendId: user.ID,
		}).Error
		if err != nil {
			log.WithError(err).Error("creating user relation")
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

func UserLogin(ctx *gin.Context) {
	var req api.UserLoginRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		ctx.JSON(http.StatusBadRequest, gin.H{"msg": "fail to parse json"})
		return
	}
	var user model.User
	err = db.SQL().Table("user").Where("email = ?", req.Email).First(&user).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		if code, exists := errorCodeMap[err]; exists {
			ctx.JSON(code, gin.H{
				"msg": err.Error(),
			})
		} else {
			ctx.JSON(http.StatusInternalServerError, gin.H{
				"msg": "服务器内部错误",
			})
		}
		return
	}
	if user.ID == 0 {
		ctx.Abort()
		ctx.JSON(http.StatusNotFound, gin.H{"msg": "user not found"})
		return
	}
	if user.Password != MD5(req.Password) {
		log.Error("password not match")
		ctx.Abort()
		ctx.JSON(http.StatusUnauthorized, gin.H{"msg": "password mismatches"})
		return
	}
	var res api.UserSignResponse
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
	ctx.JSON(200, res)
}

var errorCodeMap = map[error]int{
	gorm.ErrDuplicatedKey:  http.StatusConflict,   // 409 用户已存在
	gorm.ErrInvalidData:    http.StatusBadRequest, // 400 请求数据无效
	gorm.ErrRecordNotFound: http.StatusNotFound,   // 404 记录不存在
}

func UserSignUp(ctx *gin.Context) {
	var req api.UserSignUpRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		ctx.Abort()
		log.WithError(err).Error("fail to parse json")
		ctx.JSON(http.StatusBadRequest, gin.H{})
		return
	}

	var user model.User
	err = db.SQL().Table("user").Where("email = ?", req.Email).First(&user).Error
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		ctx.Abort()
		ctx.JSON(http.StatusNotFound, gin.H{"msg": err.Error()})
		return
	}
	err = db.SQL().Table("user_relation").Create(&model.UserRelation{
		UserId:   user.ID,
		FriendId: user.ID,
	}).Error
	if err != nil {
		log.WithError(err).Error("creating user relation")
		ctx.Abort()
		ctx.JSON(http.StatusInternalServerError, gin.H{"msg": "服务器内部错误"})
		return
	}
	if user.ID != 0 {
		ctx.Abort()
		ctx.JSON(http.StatusConflict, gin.H{"msg": "user already exists"})
		return
	}
	key := fmt.Sprintf("otp_%s", req.Email)
	expected, err := db.Rdb().Get(context.TODO(), key).Result()
	if err != nil {
		ctx.Abort()
		ctx.JSON(http.StatusNotFound, gin.H{"msg": err.Error()})
		return
	}
	if req.OTP != expected {
		ctx.Abort()
		ctx.JSON(http.StatusUnauthorized, gin.H{"msg": "invalid OTP"})
		return
	}
	var res api.UserSignResponse

	log.Debugf("creating new user")
	if len(req.Username) == 0 {
		req.Username = gofakeit.Username()
	}
	user.Name = req.Username
	user.Email = req.Email
	user.Telephone = model.NullString{
		Valid:  true,
		String: req.Telephone,
	}
	user.Password = MD5(req.Password)
	user.IsMale = req.IsMale
	err = db.SQL().Table("user").Create(&user).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		if code, exists := errorCodeMap[err]; exists {
			ctx.JSON(code, gin.H{
				"message": err.Error(),
			})
		} else {
			ctx.JSON(http.StatusInternalServerError, gin.H{
				"message": "服务器内部错误",
			})
		}
		ctx.Abort()
		return
	}
	gender := govatar.FEMALE
	if req.IsMale {
		gender = govatar.MALE
	}
	img, err := govatar.Generate(gender)
	if err != nil {
		log.WithError(err).Fatal("generating image")
		ctx.Abort()
		return
	}

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

	ctx.JSON(http.StatusOK, res)
}

func UserRecover(ctx *gin.Context) {
	var req api.UserRecoverRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	var user model.User
	err = db.SQL().Table("user").Where("email = ?", req.Email).First(&user).Error
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		ctx.Abort()
		ctx.JSON(http.StatusNotFound, gin.H{"msg": err.Error()})
		return
	}
	if user.ID == 0 {
		ctx.Abort()
		ctx.JSON(http.StatusNotFound, gin.H{"msg": "user not found"})
		return
	}
	key := fmt.Sprintf("otp_%s", req.Email)
	expected, err := db.Rdb().Get(context.TODO(), key).Result()
	if err != nil {
		ctx.Abort()
		ctx.JSON(http.StatusNotFound, gin.H{"msg": err.Error()})
		return
	}
	if req.OTP != expected {
		ctx.Abort()
		ctx.JSON(http.StatusUnauthorized, gin.H{"msg": "invalid OTP"})
		return
	}
	user.Password = MD5(req.Password)
	err = db.SQL().Table("user").Save(&user).Error
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"msg": err.Error()})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{"msg": "successfully recover password"})
}

const otpTTL = 5 * time.Minute

func generateOTP() string {
	return fmt.Sprintf("%06d", rand.Intn(1000000))
}

func UserVerifyOTP(ctx *gin.Context) {
	var req api.UserVerifyOTPRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}
	// TODO 用户存在不必在发
	key := fmt.Sprintf("otp_%s", req.Email)
	existingOTP, err := db.Rdb().Get(context.TODO(), key).Result()
	if err == nil {
		ctx.JSON(200, api.UserVerifyOTPResponse{
			OTP: existingOTP,
		})
		return
	}
	newOTP := generateOTP()
	err = db.Rdb().Set(context.TODO(), key, newOTP, otpTTL).Err()
	if err != nil {
		ctx.JSON(200, api.UserVerifyOTPResponse{
			OTP: "",
		})
		ctx.Abort()
		return
	}
	ctx.JSON(200, api.UserVerifyOTPResponse{
		OTP: newOTP,
	})
}

func UserDetail(ctx *gin.Context) {
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	ctx.JSON(http.StatusOK, gin.H{"msg": "successfully to get user's detail", "user": gin.H{
		"id":        u.ID,
		"is_male":   u.IsMale,
		"email":     u.Email,
		"telephone": u.Telephone.String,
		"name":      u.Name,
		"about":     u.About,
	}})
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
		ctx.JSON(http.StatusInternalServerError, gin.H{"msg": "Error while sending profile image"})
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

func UserEdit(ctx *gin.Context) {
	var req api.UserEditRequest
	err := ctx.Bind(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse formData")
		ctx.Abort()
		return
	}
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	if req.IsMale == "1" {
		u.IsMale = true
	} else {
		u.IsMale = false
	}
	u.Email = req.Email
	u.Name = req.Name
	u.Telephone = model.NullString{
		Valid:  true,
		String: req.Telephone,
	}
	if req.Profile != nil {
		data, err := req.Profile.Open()
		if err != nil {
			log.WithError(err).Error("fail to open file")
			ctx.Abort()
			return
		}
		defer data.Close()
		buf := new(bytes.Buffer)
		_, err = io.Copy(buf, data)
		if err != nil {
			log.WithError(err).Error("fail to copy file")
			ctx.Abort()
			return
		}
		_, err = db.OSS().PutObject(context.TODO(), "user", fmt.Sprintf("/profile/%d.png", u.ID), buf, int64(buf.Len()), minio.PutObjectOptions{})
		if err != nil {
			log.WithError(err).Error("fail to upload file")
			ctx.Abort()
			return
		}
	}
	err = db.SQL().Table("user").Save(&u).Error
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"msg": err.Error()})
		return
	}
	ctx.JSON(http.StatusOK, gin.H{"msg": "successfully edit user"})
}

func UserContacts(ctx *gin.Context) {
	u, ok := getUser(ctx)
	if !ok {
		return
	}

	var contacts []contact
	err := db.SQL().Rawf(`SELECT u.id, u.name, u.about
FROM user_relation ur
JOIN user u ON u.id = ur.friend_id
WHERE ur.user_id = %d;
`, u.ID).Find(&contacts).Error
	if err != nil {
		log.WithError(err).Error("fail to get contacts")
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, gin.H{"msg": "successfully get contacts", "data": contacts})
}

type contact struct {
	Id    uint   `json:"id"`
	Name  string `json:"name"`
	About string `json:"about"`
}

func FriendNew(ctx *gin.Context) {
	var req api.FriendNewRequest
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
	if u.ID == req.FriendId {
		log.Error("you cannot add yourself")
		ctx.Abort()
		ctx.JSON(http.StatusOK, gin.H{
			"msg": "you cannot add yourself",
		})
		return
	}
	var old model.Notification
	err = db.SQL().Table("notification").Where("creator = ? AND description = ?", u.ID, req.FriendId).First(&old).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			tx := db.SQL().Begin()
			notifiction := model.Notification{
				Type:        model.NotificationTypeAddFriend,
				Creator:     u.ID,
				Name:        "Make Friend",
				Description: fmt.Sprintf("%d", req.FriendId),
			}
			err = tx.Table("notification").Create(&notifiction).Error
			if err != nil {
				tx.Rollback()
				log.WithError(err).Error("running sql")
				ctx.Abort()
				return
			}
			notificationPub := model.NotificationPublish{
				NotificationId: notifiction.ID,
				UserID:         req.FriendId,
			}
			err = tx.Table("notification_publish").Create(&notificationPub).Error
			if err != nil {
				tx.Rollback()
				log.WithError(err).Error("running sql")
				ctx.Abort()
				return
			}
			notificationAction := model.NotificationAction{
				NotificationId: notifiction.ID,
				Receiver:       req.FriendId,
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
			ctx.JSON(http.StatusOK, gin.H{
				"msg": "successfully sends friend request",
			})
			return
		} else {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			ctx.JSON(http.StatusInternalServerError, gin.H{
				"msg": "fail to create notification",
			})
			return
		}
	}

	ctx.JSON(http.StatusOK, gin.H{
		"msg": "duplicate request",
	})
}

func FriendCommit(ctx *gin.Context) {
	var req api.FriendCommitRequest
	err := ctx.BindJSON(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}

	var status uint8 = model.NotifyStateUnknown
	if req.Pass {
		status = model.NotifyStateConfirmed
	} else {
		status = model.NotifyStateRejected
	}
	if status == model.NotifyStateUnknown {
		log.WithError(err).Error("invalid status")
		ctx.Abort()
		return
	}

	u, ok := getUser(ctx)
	if !ok {
		return
	}
	var action model.NotificationAction
	err = db.SQL().Table("notification_action").Where("nid = ?", req.NotificationId).First(&action).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	if u.ID != action.Receiver {
		log.WithError(err).Error("invalid request")
		ctx.Abort()
		return
	}

	action.Status = status
	tx := db.SQL().Begin()
	err = tx.Table("notification_action").Save(&action).Error
	if err != nil {
		tx.Rollback()
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	if status == model.NotifyStateConfirmed {
		var n model.Notification
		err = tx.Table("notification").Where("id = ?", req.NotificationId).First(&n).Error
		if err != nil {
			tx.Rollback()
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		err = tx.Table("user_relation").Create(&model.UserRelation{
			UserId:   u.ID,
			FriendId: n.Creator,
		}).Error
		if err != nil {
			tx.Rollback()
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
	}

	tx.Commit()
}

func FriendGet(ctx *gin.Context) {
	friendId, _ := strconv.Atoi(ctx.Param("friend_id"))
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	var (
		friend     model.User
		follower   int64
		topicCnt   int64
		postCnt    int64
		commentCnt int64
		online     bool
	)

	_, _, err := db.Rdb().Scan(context.TODO(), 100, fmt.Sprintf("*user_%d*", friendId), 1).Result()
	if err == nil {
		online = true
	}

	err = db.SQL().Table("user").Where("id", friendId).First(&friend).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	err = db.SQL().Table("user_relation").Where("user_id = ?", friendId).Count(&follower).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	err = db.SQL().Table("topic_join").Where("user_id = ?", friendId).Count(&topicCnt).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	err = db.SQL().Table("post").Where("user_id = ?", friendId).Count(&postCnt).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	// err = db.SQL().Table("comment").Where("user_id = ?", friendId).Count(&commentCnt).Error
	// if err != nil {
	// 	log.WithError(err).Error("running sql")
	// 	ctx.Abort()
	// 	return
	// }
	data := map[string]any{
		"id":             friend.ID,
		"name":           friend.Name,
		"description":    friend.About,
		"is_male":        friend.IsMale,
		"is_online":      online,
		"page":           1,
		"page_size":      10,
		"follower_count": follower,
		"topic_count":    topicCnt,
		"post_count":     postCnt,
		"comment_count":  commentCnt,
	}
	var relation model.UserRelation
	err = db.SQL().Table("user_relation").Where("(user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)", u.ID, friendId, friendId, u.ID).First(&relation).Error
	if err != nil && err != gorm.ErrRecordNotFound {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	if u.ID != uint(friendId) && relation.ID == 0 {
		ctx.JSON(200, gin.H{
			"data": data,
		})
		log.Error("permission denied")
		ctx.Abort()
		return
	}

	page := 1
	limit := 10
	offset := (page - 1) * limit

	var posts []model.Post
	err = db.SQL().Table("post").Where("user_id = ?", friendId).
		Limit(limit).
		Offset(offset).Find(&posts).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	data["post"] = posts
	ctx.JSON(http.StatusOK, gin.H{"data": data})
}

func FriendPostGet(ctx *gin.Context) {
	var req api.FriendPostGetRequest
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

	page := req.Page
	limit := req.Limit
	offset := (page - 1) * limit

	_, ok = isFriend(ctx, u.ID, req.FriendId)
	if !ok {
		return
	}

	var posts []model.Post
	err = db.SQL().Table("post").Where("user_id = ?", req.FriendId).
		Limit(limit).
		Offset(offset).Find(&posts).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	ctx.JSON(http.StatusOK, gin.H{
		"data": posts,
	})
}

func isFriend(ctx *gin.Context, uid, fid uint) (rel model.UserRelation, ok bool) {
	ok = false
	err := db.SQL().Table("user_relation").Where("(user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)", uid, fid, fid, uid).First(&rel).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	if rel.ID == 0 {
		log.Error("permission denied")
		ctx.Abort()
		return
	}
	ok = true
	return
}

func FriendSnapshot(ctx *gin.Context) {
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	var relations []model.UserRelation
	err := db.SQL().Table("user_relation").Where("user_id = ? OR friend_id = ?", u.ID, u.ID).Find(&relations).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	friendsId := []uint{}
	friends := []string{}
	for _, r := range relations {
		if r.UserId == u.ID {
			friends = append(friends, fmt.Sprintf("user_%d", r.FriendId))
			friendsId = append(friendsId, r.FriendId)
		} else {
			friends = append(friends, fmt.Sprintf("user_%d", r.UserId))
			friendsId = append(friendsId, r.UserId)
		}
	}

	var users []friend
	err = db.SQL().Table("user").Where("user_id IN ?", users).Find(&users).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	values, err := db.Rdb().MGet(context.Background(), friends...).Result()
	if err != nil {
		log.WithError(err).Error("searching online")
		ctx.Abort()
		return
	}

	onlineStatusMap := make(map[uint]bool)
	for i, v := range values {
		friendId := friendsId[i]
		if v == nil {
			onlineStatusMap[friendId] = false // Offline
		} else {
			onlineStatusMap[friendId] = v.(string) == "true" // Online if "true"
		}
	}

	// Now, update the users' online status by matching user IDs with the onlineStatusMap
	for i := range users {
		if status, exists := onlineStatusMap[users[i].ID]; exists {
			users[i].Online = status // Set the user's online status
		} else {
			users[i].Online = false // Default to offline if status doesn't exist
		}
	}

	// Return the updated list of users with their online status
	ctx.JSON(http.StatusOK, gin.H{
		"data": users,
	})
}

type friend struct {
	model.User
	Online bool `json:"online"`
}

func FriendDel(ctx *gin.Context) {}

func MD5(str string) string {
	return fmt.Sprintf("%x", md5.Sum([]byte(str)))
}

func getUser(ctx *gin.Context) (model.User, bool) {
	val, ok := ctx.Get("user")
	if !ok {
		log.Error("invalid user")
		ctx.Abort()
		return model.User{}, false
	}
	user := val.(model.User)
	return user, true
}
