package api

import (
	"mime/multipart"

	"github.com/relvacode/iso8601"
	"gorm.io/datatypes"
)

type TaskNewRequest struct {
	TopicId     uint         `json:"topic_id"`
	Icon        string       `json:"icon"`
	Name        string       `json:"name"`
	Description string       `json:"description"`
	StartAt     iso8601.Time `json:"start_at"`
	EndAt       iso8601.Time `json:"end_at"`
	Conditions  []struct {
		Type  string            `json:"type"`
		Param datatypes.JSONMap `json:"param"`
	} `json:"conditions"`
}

type TaskCommitRequest struct {
	TaskId      uint              `json:"task_id"`
	ConditionId uint              `json:"condition_id"`
	Argument    datatypes.JSONMap `json:"argument"`
}

type TaskDelRequest struct {
	TaskId uint `json:"task_id"`
}

type TaskEditRequest struct {
	TaskId      uint         `json:"task_id"`
	Name        string       `json:"name"`
	Description string       `json:"description"`
	StartAt     iso8601.Time `json:"start_at"`
	EndAt       iso8601.Time `json:"end_at"`
	Conditions  []struct {
		Type  string            `json:"type"`
		Param datatypes.JSONMap `json:"param"`
	} `json:"conditions"`
}

type TaskFileUploadRequest struct {
	TaskId      uint                  `form:"task_id"`
	ConditionId uint                  `form:"condition_id"`
	File        *multipart.FileHeader `form:"file"`
}
