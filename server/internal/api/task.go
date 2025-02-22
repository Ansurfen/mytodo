package api

import (
	"github.com/relvacode/iso8601"
	"gorm.io/datatypes"
)

type TaskNewRequest struct {
	TopicId     uint         `json:"topic_id"`
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
