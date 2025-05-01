package handler

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"math"
	"mytodo/internal/api"
	"mytodo/internal/db"
	"mytodo/internal/model"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/caarlos0/log"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt"
	"github.com/minio/minio-go/v7"
)

func TaskNew(ctx *gin.Context) {
	var req api.TaskNewRequest
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
	task := model.Task{
		TopicId:     req.TopicId,
		Icon:        req.Icon,
		Creator:     u.ID,
		Name:        req.Name,
		Description: req.Description,
		StartAt:     req.StartAt.Time,
		EndAt:       req.EndAt.Time,
	}
	err = tx.Table("task").Create(&task).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	var conds []model.TaskCondition
	for _, cond := range req.Conditions {
		switch cond.Type {
		case "click":
			conds = append(conds, model.TaskCondition{
				Type:   model.TaskTypeClick,
				TaskId: task.ID,
			})
		case "locate":
			conds = append(conds, model.TaskCondition{
				Type:   model.TaskTypeLocate,
				Param:  cond.Param,
				TaskId: task.ID,
			})
		case "file":
			conds = append(conds, model.TaskCondition{
				Type:   model.TaskTypeFile,
				TaskId: task.ID,
			})
		case "text":
			conds = append(conds, model.TaskCondition{
				Type:   model.TaskTypeText,
				TaskId: task.ID,
			})
		}
	}
	err = tx.Table("task_condition").CreateInBatches(&conds, len(conds)).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	if err = tx.Commit().Error; err != nil {
		log.WithError(err).Error("fail to commit tx")
		ctx.Abort()
		return
	}
	ctx.JSON(200, gin.H{
		"msg": "successfully create task",
	})
}

func TaskDel(ctx *gin.Context) {
	var req api.TaskDelRequest
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
	var task model.Task
	err = db.SQL().Table("task").Where("id = ?", req.TaskId).First(&task).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	if task.Creator != u.ID {
		log.WithError(err).Error("permission denied")
		ctx.Abort()
		return
	}
	err = db.SQL().Table("task").Delete(&task).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
}

func TaskEdit(ctx *gin.Context) {
	var req api.TaskEditRequest
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
	var task model.Task
	err = db.SQL().Table("task").Where("id = ?", req.TaskId).First(&task).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	if task.Creator != u.ID {
		log.WithError(err).Error("permission denied")
		ctx.Abort()
		return
	}
	if len(req.Name) > 0 {
		task.Name = req.Name
	}
	if len(req.Description) > 0 {
		task.Description = req.Description
	}
	if !req.StartAt.IsZero() {
		task.StartAt = req.StartAt.Time
	}
	if !req.EndAt.IsZero() {
		task.EndAt = req.EndAt.Time
	}
	// TODO
	// var conds []model.TaskCondition
	// for _, c := range req.Conditions {
	// 	switch c.Type {

	// 	}
	// }

}

func TaskQR(ctx *gin.Context) {
	taskId := ctx.Param("task")
	u, ok := getUser(ctx)
	if !ok {
		return
	}
	var task model.Task
	err := db.SQL().Table("task").Where("id = ?", taskId).First(&task).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	policy, err := loadTopicPolicy(task.TopicId, u.ID)
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
	if !policy.Role.GE(model.TopicRoleAdmin) {
		ctx.Abort()
		log.WithError(err).Error("permission denied")
		ctx.JSON(200, gin.H{"msg": "permission denied"})
		return
	}

	now := time.Now()
	expirationTime := now.Add(30 * time.Second)
	claims := jwt.StandardClaims{
		Id:        taskId,
		ExpiresAt: expirationTime.Unix(),
		IssuedAt:  now.Unix(),
		Issuer:    "org.my_todo",
		Subject:   "qr token",
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenStr, err := token.SignedString(jwtKey)
	if err != nil {
		log.WithError(err).Error("fail to generate token")
		ctx.Abort()
		return
	}
	ctx.JSON(200, gin.H{
		"msg":  "",
		"data": tokenStr,
	})
}

var jwtKey = []byte("my_todo_qr")

func TaskCommit(ctx *gin.Context) {
	var req api.TaskCommitRequest
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

	var cond model.TaskCondition
	err = db.SQL().Table("task_condition").Where("id = ?", req.ConditionId).First(&cond).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	var argument map[string]any
	switch cond.Type {
	case model.TaskTypeClick:
		argument = map[string]any{
			"create_at": time.Now().Unix(),
		}
	case model.TaskTypeText:
		argument = req.Argument
	case model.TaskTypeFile:

	case model.TaskTypeQR:
		tokenString := req.Argument["token"].(string)
		claims := jwt.StandardClaims{}
		token, err := jwt.ParseWithClaims(tokenString, &claims, func(token *jwt.Token) (i interface{}, err error) {
			return jwtKey, nil
		})
		if err != nil {

		}
		if claims, ok := token.Claims.(*jwt.StandardClaims); ok && token.Valid {
			// timeout
			if claims.ExpiresAt < time.Now().Unix() {
				ctx.Abort()
				return
			}
		}
	case model.TaskTypeLocate:
		locale := req.Argument["locate"].(string)
		res := strings.Split(locale, "---data:image/png;base64,")
		latLng := strings.Split(res[0], ",")

		img, err := base64.StdEncoding.DecodeString(res[1])
		if err != nil {
			log.WithError(err).Error("fail to parse base64")
			ctx.Abort()
			return
		}
		reader := bytes.NewReader(img)
		db.OSS().PutObject(context.Background(), "task", fmt.Sprintf("/locate/%d.png", cond.ID), reader, int64(len(img)), minio.PutObjectOptions{})
		lat, err := strconv.ParseFloat(latLng[0], 64)
		if err != nil {
			log.WithError(err).Error("无法解析纬度")
			ctx.Abort()
			return
		}

		lng, err := strconv.ParseFloat(latLng[1], 64)
		if err != nil {
			log.WithError(err).Error("无法解析经度")
			ctx.Abort()
			return
		}
		argument = map[string]any{
			"latitude":  lat,
			"longitude": lng,
		}
	}

	commit := model.TaskCommit{
		TaskId:      req.TaskId,
		UserId:      u.ID,
		ConditionId: req.ConditionId,
		Argument:    argument,
	}
	err = db.SQL().Table("task_commit").Create(&commit).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}
}

func TaskGet(ctx *gin.Context) {
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

	var tasks []model.Task
	for _, join := range topicJoins {
		var topicTasks []model.Task
		err = db.SQL().Table("task").Where("topic_id = ?", join.TopicId).Find(&topicTasks).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		tasks = append(tasks, topicTasks...)
	}

	var detailedTasks []detailedTask
	for _, task := range tasks {
		var conds []model.TaskCondition
		err = db.SQL().Table("task_condition").Where("task_id = ?", task.ID).Find(&conds).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}

		var commits []model.TaskCommit
		err = db.SQL().Table("task_commit").Where("task_id = ?", task.ID).Find(&commits).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}

		gots := map[uint]model.TaskCommit{}
		for _, commit := range commits {
			gots[commit.ConditionId] = commit
		}

		finished := 0
		var taskConds []taskCond
		for _, require := range conds {
			if got, ok := gots[require.ID]; ok {
				switch require.Type {
				case model.TaskTypeClick, model.TaskTypeImage, model.TaskTypeFile, model.TaskTypeText:
					taskConds = append(taskConds, taskCond{
						Want:  &require,
						Got:   &got,
						Valid: true,
					})
					finished++
				case model.TaskTypeLocate:
					tc := taskCond{Valid: false, Got: &got}
					for _, v := range require.Param {
						v := v.(map[string]any)
						wantLat := v["latitude"].(json.Number)
						wantLng := v["longitude"].(json.Number)
						radius := v["radius"].(json.Number)
						gotLat := got.Argument["latitude"].(json.Number)
						gotLng := got.Argument["longitude"].(json.Number)

						wLat, _ := wantLat.Float64()
						wLng, _ := wantLng.Float64()
						wRadius, _ := radius.Float64()
						gLat, _ := gotLat.Float64()
						gLng, _ := gotLng.Float64()
						distance := haversine(wLat, wLng, gLat, gLng)
						tc.Want = &require

						if distance <= wRadius/1000 {
							finished++
							tc.Valid = true
							break
						}
					}
					taskConds = append(taskConds, tc)
				}
			} else {
				taskConds = append(taskConds, taskCond{
					Want:  &require,
					Valid: false,
				})
			}
		}

		detailedTasks = append(detailedTasks, detailedTask{
			Task:   task,
			Total:  uint(len(conds)),
			Finish: uint(finished),
			Conds:  taskConds,
		})
	}
	ctx.JSON(http.StatusOK, gin.H{"data": detailedTasks})
}

type taskCond struct {
	Want  *model.TaskCondition `json:"want"`
	Got   *model.TaskCommit    `json:"got"`
	Valid bool                 `json:"valid"`
}

type detailedTask struct {
	model.Task
	Conds  []taskCond `json:"conds"`
	Finish uint       `json:"finish"`
	Total  uint       `json:"total"`
}

// Haversine formula to calculate the distance between two coordinates
func haversine(lat1, lon1, lat2, lon2 float64) float64 {
	// Radius of Earth in kilometers
	const R = 6371

	// Convert degrees to radians
	lat1 = lat1 * math.Pi / 180
	lon1 = lon1 * math.Pi / 180
	lat2 = lat2 * math.Pi / 180
	lon2 = lon2 * math.Pi / 180

	// Haversine formula
	dlat := lat2 - lat1
	dlon := lon2 - lon1
	a := math.Sin(dlat/2)*math.Sin(dlat/2) +
		math.Cos(lat1)*math.Cos(lat2)*math.Sin(dlon/2)*math.Sin(dlon/2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

	// Distance in kilometers
	return R * c
}
