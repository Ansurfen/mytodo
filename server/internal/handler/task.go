package handler

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"math"
	"mytodo/internal/api"
	"mytodo/internal/db"
	"mytodo/internal/model"
	"net/http"
	"path"
	"strconv"
	"strings"
	"time"

	"github.com/caarlos0/log"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt"
	"github.com/google/uuid"
	"github.com/minio/minio-go/v7"
	"gorm.io/gorm"
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

	// 更新任务基本信息
	err = db.SQL().Table("task").Save(&task).Error
	if err != nil {
		log.WithError(err).Error("fail to update task")
		ctx.Abort()
		return
	}

	// 处理任务条件的更新
	if len(req.Conditions) > 0 {
		// 删除所有现有条件
		err = db.SQL().Table("task_condition").Where("task_id = ?", task.ID).Delete(&model.TaskCondition{}).Error
		if err != nil {
			log.WithError(err).Error("fail to delete existing conditions")
			ctx.Abort()
			return
		}

		// 创建新的条件
		var conds []model.TaskCondition
		for _, cond := range req.Conditions {
			var taskType model.TaskType
			switch cond.Type {
			case "click":
				taskType = model.TaskTypeClick
			case "locate":
				taskType = model.TaskTypeLocate
			case "file":
				taskType = model.TaskTypeFile
			case "text":
				taskType = model.TaskTypeText
			case "qr":
				taskType = model.TaskTypeQR
			case "image":
				taskType = model.TaskTypeImage
			case "timer":
				taskType = model.TaskTypeTimer
			default:
				log.WithError(err).Error("unknown task type")
				ctx.Abort()
				return
			}

			conds = append(conds, model.TaskCondition{
				TaskId: task.ID,
				Type:   taskType,
				Param:  cond.Param,
			})
		}

		// 批量创建新条件
		err = db.SQL().Table("task_condition").CreateInBatches(&conds, len(conds)).Error
		if err != nil {
			log.WithError(err).Error("fail to create new conditions")
			ctx.Abort()
			return
		}
	}

	ctx.JSON(http.StatusOK, gin.H{
		"msg": "successfully updated task",
	})
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
	ctx.JSON(http.StatusOK, gin.H{
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
		argument["create_at"] = time.Now().Unix()
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
		filename := uuid.New().String()
		reader := bytes.NewReader(img)
		db.OSS().PutObject(context.Background(), "task", fmt.Sprintf("/locate/%s.png", filename), reader, int64(len(img)), minio.PutObjectOptions{})
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
			"image":     filename,
			"create_at": time.Now().Unix(),
		}
	}

	commit := model.TaskCommit{
		TaskId:      req.TaskId,
		UserId:      u.ID,
		ConditionId: req.ConditionId,
		Argument:    argument,
	}
	var old model.TaskCommit
	db.SQL().Table("task_commit").Where("task_id = ? AND user_id = ? AND cond_id = ?", req.TaskId, u.ID, req.ConditionId).First(&old)
	if old.ID != 0 && (cond.Type == model.TaskTypeLocate || cond.Type == model.TaskTypeText) {
		old.Argument = argument
		if err = db.SQL().Table("task_commit").Save(&old).Error; err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
		ctx.JSON(200, gin.H{
			"msg": "successfully update task commit",
		})
		return
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
		err = db.SQL().Table("task_commit").Where("task_id = ? AND user_id = ?", task.ID, u.ID).Find(&commits).Error
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
				case model.TaskTypeClick, model.TaskTypeImage, model.TaskTypeText:
					taskConds = append(taskConds, taskCond{
						Want:  &require,
						Got:   &got,
						Valid: true,
					})
					finished++
				case model.TaskTypeFile:
					if _, ok := got.Argument["files"].([]interface{}); ok {
						taskConds = append(taskConds, taskCond{
							Want:  &require,
							Got:   &got,
							Valid: true,
						})
						finished++
					} else {
						taskConds = append(taskConds, taskCond{
							Want:  &require,
							Got:   &got,
							Valid: false,
						})
					}
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

func TaskDashboard(ctx *gin.Context) {
	u, ok := getUser(ctx)
	if !ok {
		return
	}

	// 获取用户加入的所有话题
	var topicJoins []model.TopicJoin
	err := db.SQL().Table("topic_join").Where("user_id = ?", u.ID).Find(&topicJoins).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	// 获取所有相关任务
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

	now := time.Now()
	stats := struct {
		Completed       int `json:"completed"`
		Overdue         int `json:"overdue"`
		InProgress      int `json:"in_progress"`
		DailyTotal      int `json:"daily_total"`
		DailyFinished   int `json:"daily_finished"`
		MonthlyTotal    int `json:"monthly_total"`
		MonthlyFinished int `json:"monthly_finished"`
		YearlyTotal     int `json:"yearly_total"`
		YearlyFinished  int `json:"yearly_finished"`
	}{}

	// 批量获取所有任务的条件和提交记录
	var taskIDs []uint
	for _, task := range tasks {
		taskIDs = append(taskIDs, task.ID)
	}

	// 获取所有任务的条件
	var allConds []model.TaskCondition
	if len(taskIDs) > 0 {
		err = db.SQL().Table("task_condition").Where("task_id IN ?", taskIDs).Find(&allConds).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
	}

	// 获取所有任务的提交记录
	var allCommits []model.TaskCommit
	if len(taskIDs) > 0 {
		err = db.SQL().Table("task_commit").Where("task_id IN ? AND user_id = ?", taskIDs, u.ID).Find(&allCommits).Error
		if err != nil {
			log.WithError(err).Error("running sql")
			ctx.Abort()
			return
		}
	}

	// 按任务ID组织条件和提交记录
	condsByTask := make(map[uint][]model.TaskCondition)
	commitsByTask := make(map[uint][]model.TaskCommit)

	for _, cond := range allConds {
		condsByTask[cond.TaskId] = append(condsByTask[cond.TaskId], cond)
	}

	for _, commit := range allCommits {
		commitsByTask[commit.TaskId] = append(commitsByTask[commit.TaskId], commit)
	}

	// 统计任务状态
	for _, task := range tasks {
		conds := condsByTask[task.ID]
		commits := commitsByTask[task.ID]

		// 计算完成的条件数量
		completedConds := 0
		condMap := make(map[uint]bool)
		for _, commit := range commits {
			condMap[commit.ConditionId] = true
		}
		for _, cond := range conds {
			if condMap[cond.ID] {
				completedConds++
			}
		}

		// 更新任务状态统计
		if completedConds == len(conds) {
			stats.Completed++
		} else if task.EndAt.Before(now) {
			stats.Overdue++
		} else {
			stats.InProgress++
		}

		// 更新任务周期统计
		duration := task.EndAt.Sub(task.StartAt)
		if duration <= 24*time.Hour {
			stats.DailyTotal++
			if completedConds == len(conds) {
				stats.DailyFinished++
			}
		} else if duration <= 30*24*time.Hour {
			stats.MonthlyTotal++
			if completedConds == len(conds) {
				stats.MonthlyFinished++
			}
		} else {
			stats.YearlyTotal++
			if completedConds == len(conds) {
				stats.YearlyFinished++
			}
		}
	}

	ctx.JSON(http.StatusOK, gin.H{
		"data": stats,
	})
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

func TaskHeatMap(ctx *gin.Context) {
	u, ok := getUser(ctx)
	if !ok {
		return
	}

	// 查询用户最近一年的任务提交记录
	oneYearAgo := time.Now().AddDate(-1, 0, 0)
	var commits []model.TaskCommit
	err := db.SQL().Table("task_commit").
		Where("user_id = ? AND created_at >= ?", u.ID, oneYearAgo).
		Find(&commits).Error
	if err != nil {
		log.WithError(err).Error("running sql")
		ctx.Abort()
		return
	}

	// 按日期统计提交次数
	heatmap := make(map[string]int)
	for _, commit := range commits {
		date := commit.CreatedAt.Format("2006-01-02")
		heatmap[date]++
	}

	ctx.JSON(http.StatusOK, gin.H{
		"data": heatmap,
	})
}

func TaskLocate(ctx *gin.Context) {
	filename := ctx.Param("filename")

	obj, err := db.OSS().GetObject(context.TODO(), "task", fmt.Sprintf("/locate/%s.png", filename), minio.GetObjectOptions{})
	if err != nil {
		log.WithError(err).Debug("getting profile")
	}
	defer obj.Close()

	ctx.Header("Content-Type", "image/png")
	ctx.Header("Content-Disposition", fmt.Sprintf("inline; filename=%s.png", filename))

	_, err = io.Copy(ctx.Writer, obj)
	if err != nil {
		log.WithError(err).Error("writing image to response")
		ctx.JSON(http.StatusInternalServerError, gin.H{"msg": "Error while sending profile image"})
		return
	}
}

func TaskFileUpload(ctx *gin.Context) {
	// 获取用户信息
	u, ok := getUser(ctx)
	if !ok {
		return
	}

	// 解析请求
	var req api.TaskFileUploadRequest
	err := ctx.Bind(&req)
	if err != nil {
		log.WithError(err).Error("fail to parse json")
		ctx.Abort()
		return
	}

	// 生成唯一文件名
	filename := uuid.New().String() + path.Ext(req.File.Filename)

	// 打开上传的文件
	src, err := req.File.Open()
	if err != nil {
		log.WithError(err).Error("fail to open uploaded file")
		ctx.Abort()
		return
	}
	defer src.Close()

	// 上传到 MinIO
	_, err = db.OSS().PutObject(
		context.Background(),
		"task",
		fmt.Sprintf("/file/%s", filename),
		src,
		req.File.Size,
		minio.PutObjectOptions{ContentType: req.File.Header.Get("Content-Type")},
	)
	if err != nil {
		log.WithError(err).Error("fail to upload file to minio")
		ctx.Abort()
		return
	}

	// 获取现有的任务提交记录
	var commit model.TaskCommit
	err = db.SQL().Table("task_commit").
		Where("task_id = ? AND user_id = ? AND cond_id = ?", req.TaskId, u.ID, req.ConditionId).
		First(&commit).Error
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		log.WithError(err).Error("fail to get task commit")
		ctx.Abort()
		return
	}

	// 准备文件信息
	fileInfo := map[string]interface{}{
		"filename":      filename,
		"original_name": req.File.Filename,
		"size":          req.File.Size,
		"content_type":  req.File.Header.Get("Content-Type"),
	}

	// 获取现有的文件列表
	var files []map[string]interface{}
	if commit.ID != 0 {
		argument := commit.Argument
		if existingFiles, ok := argument["files"].([]interface{}); ok {
			for _, f := range existingFiles {
				if file, ok := f.(map[string]interface{}); ok {
					files = append(files, file)
				}
			}
		}
	}

	// 添加新文件到列表
	files = append(files, fileInfo)

	// 更新或创建任务提交记录
	argument := map[string]interface{}{
		"files":     files,
		"create_at": time.Now().Unix(),
	}

	if commit.ID != 0 {
		// 更新现有记录
		commit.Argument = argument
		err = db.SQL().Table("task_commit").Save(&commit).Error
	} else {
		// 创建新记录
		commit = model.TaskCommit{
			TaskId:      req.TaskId,
			UserId:      u.ID,
			ConditionId: req.ConditionId,
			Argument:    argument,
		}
		err = db.SQL().Table("task_commit").Create(&commit).Error
	}

	if err != nil {
		log.WithError(err).Error("fail to save task commit")
		ctx.Abort()
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"msg":  "successfully uploaded file",
		"data": fileInfo,
	})
}

func TaskFileDownload(ctx *gin.Context) {
	filename := ctx.Param("filename")

	// 从 MinIO 获取文件
	obj, err := db.OSS().GetObject(
		context.Background(),
		"task",
		fmt.Sprintf("/file/%s", filename),
		minio.GetObjectOptions{},
	)
	if err != nil {
		log.WithError(err).Error("fail to get file from minio")
		ctx.Abort()
		return
	}
	defer obj.Close()

	// 获取文件信息
	stat, err := obj.Stat()
	if err != nil {
		log.WithError(err).Error("fail to get file stat")
		ctx.Abort()
		return
	}

	// 设置响应头
	ctx.Header("Content-Type", stat.ContentType)
	ctx.Header("Content-Disposition", fmt.Sprintf("attachment; filename=%s", filename))
	ctx.Header("Content-Length", strconv.FormatInt(stat.Size, 10))

	// 发送文件内容
	_, err = io.Copy(ctx.Writer, obj)
	if err != nil {
		log.WithError(err).Error("fail to send file")
		ctx.Abort()
		return
	}
}

func TaskFileDelete(ctx *gin.Context) {
	// 获取用户信息
	u, ok := getUser(ctx)
	if !ok {
		return
	}

	// 获取文件名
	filename := ctx.Param("filename")

	// 从 MinIO 删除文件
	err := db.OSS().RemoveObject(
		context.Background(),
		"task",
		fmt.Sprintf("/file/%s", filename),
		minio.RemoveObjectOptions{},
	)
	if err != nil {
		log.WithError(err).Error("fail to delete file from minio")
		ctx.Abort()
		return
	}

	// 从数据库中的任务提交记录中删除文件信息
	var commit model.TaskCommit
	err = db.SQL().Table("task_commit").
		Where("user_id = ? AND argument->>'$.files[*].filename' LIKE ?", u.ID, "%"+filename+"%").
		First(&commit).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			ctx.JSON(http.StatusOK, gin.H{
				"msg": "file not found in database",
			})
			return
		}
		log.WithError(err).Error("fail to get task commit")
		ctx.Abort()
		return
	}

	// 更新文件列表
	argument := commit.Argument
	if files, ok := argument["files"].([]interface{}); ok {
		var updatedFiles []map[string]interface{}
		for _, f := range files {
			if file, ok := f.(map[string]interface{}); ok {
				if file["filename"] != filename {
					updatedFiles = append(updatedFiles, file)
				}
			}
		}
		argument["files"] = updatedFiles
	}

	// 更新数据库记录
	commit.Argument = argument
	err = db.SQL().Table("task_commit").Save(&commit).Error
	if err != nil {
		log.WithError(err).Error("fail to update task commit")
		ctx.Abort()
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"msg": "successfully deleted file",
	})
}

func TaskDetail(ctx *gin.Context) {
	// 获取用户信息
	u, ok := getUser(ctx)
	if !ok {
		return
	}

	// 获取任务ID
	taskId := ctx.Param("taskId")
	if taskId == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"msg": "task id is required",
		})
		return
	}

	// 查询任务信息
	var task model.Task
	err := db.SQL().Table("task").
		Where("id = ? AND creator = ?", taskId, u.ID).
		First(&task).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			ctx.JSON(http.StatusNotFound, gin.H{
				"msg": "task not found",
			})
			return
		}
		log.WithError(err).Error("fail to get task")
		ctx.Abort()
		return
	}

	// 查询任务条件
	var conditions []model.TaskCondition
	err = db.SQL().Table("task_condition").
		Where("task_id = ?", taskId).
		Find(&conditions).Error
	if err != nil {
		log.WithError(err).Error("fail to get task conditions")
		ctx.Abort()
		return
	}

	// 构建响应
	response := gin.H{
		"task":       task,
		"conditions": conditions,
	}

	ctx.JSON(http.StatusOK, gin.H{"data": response})
}

// TaskStats 获取任务提交统计信息
func TaskStats(c *gin.Context) {
	_, ok := getUser(c)
	if !ok {
		return
	}

	taskId, err := strconv.Atoi(c.Param("taskId"))
	if err != nil {
		log.WithError(err).Error("fail to parse taskId")
		c.Abort()
		return
	}

	// 获取任务信息
	var task model.Task
	if err := db.SQL().First(&task, taskId).Error; err != nil {
		c.JSON(404, gin.H{"error": "task not found"})
		return
	}

	// 获取话题成员和他们的提交统计
	type MemberStats struct {
		UserID   uint   `json:"user_id"`
		Name     string `json:"name"`
		Finished int64  `json:"finished"`
		Total    int64  `json:"total"`
		CommitAt string `json:"commit_at,omitempty"`
	}

	var stats []MemberStats
	err = db.SQL().Raw(`
		SELECT 
			u.id AS user_id,
			u.name AS name,
			COUNT(DISTINCT tc.id) AS total,
			COUNT(DISTINCT tcm.id) AS finished,
			MAX(tcm.created_at) AS commit_at
		FROM 
			topic_join tj
		JOIN 
			user u ON tj.user_id = u.id
		LEFT JOIN 
			task_condition tc ON tc.task_id = %d AND tc.deleted_at IS NULL
		LEFT JOIN 
			task_commit tcm ON tcm.task_id = %d 
			AND tcm.user_id = u.id 
			AND tcm.cond_id = tc.id
			AND tcm.deleted_at IS NULL
		WHERE 
			tj.topic_id = %d
			AND tj.deleted_at IS NULL
			AND u.deleted_at IS NULL
		GROUP BY 
			u.id, u.name
	`, taskId, taskId, task.TopicId).Scan(&stats).Error

	if err != nil {
		log.WithError(err).Error("failed to get member stats")
		c.JSON(500, gin.H{"error": "failed to get member stats"})
		return
	}

	// 计算总体完成率
	totalMembers := len(stats)
	finishedMembers := 0
	for _, stat := range stats {
		if stat.Finished == stat.Total {
			finishedMembers++
		}
	}

	c.JSON(200, gin.H{
		"stats": gin.H{
			"total_members":    totalMembers,
			"finished_members": finishedMembers,
			"progress":         float64(finishedMembers) / float64(totalMembers),
		},
		"members": stats,
	})
}
