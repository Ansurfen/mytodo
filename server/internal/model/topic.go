package model

import (
	"time"

	"gorm.io/datatypes"
)

type Topic struct {
	Model
	Icon        string                      `json:"icon" gorm:"column:icon"`
	Creator     uint                        `json:"creator" gorm:"column:creator"`
	Name        string                      `json:"name" gorm:"column:name"`
	Description string                      `json:"description" gorm:"column:description"`
	IsPublic    bool                        `json:"is_public" gorm:"is_public"`
	Tags        datatypes.JSONSlice[string] `json:"tags" gorm:"column:tags;type:json"`
	InviteCode  string                      `json:"invite_code" gorm:"invite_code"`
}

func (Topic) TableName() string {
	return "topic"
}

type TopicJoin struct {
	Model
	TopicId uint `json:"topic_id" gorm:"column:topic_id;uniqueIndex:tid_uid_idx"`
	UserId  uint `json:"user_id" gorm:"column:user_id;uniqueIndex:tid_uid_idx"`
}

func (TopicJoin) TableName() string {
	return "topic_join"
}

type TopicPolicy struct {
	Model
	Role    TopicRole `json:"role" gorm:"type:tinyint;default:0"`
	UserId  uint      `json:"user_id" gorm:"column:user_id;uniqueIndex:tid_uid_idx"`
	TopicId uint      `json:"topic_id" gorm:"column:topic_id;uniqueIndex:tid_uid_idx"`
}

func (TopicPolicy) TableName() string {
	return "topic_policy"
}

type TopicRole uint8

func (r TopicRole) GT(want TopicRole) bool {
	return r > want
}

func (r TopicRole) GE(want TopicRole) bool {
	return r >= want
}

func (r TopicRole) EQ(want TopicRole) bool {
	return r == want
}

const (
	TopicRoleMember TopicRole = iota
	TopicRoleAdmin
	TopicRoleOwner
)

type Task struct {
	Model
	TopicId     uint            `json:"topic_id" gorm:"column:topic_id"`
	Icon        string          `json:"icon"`
	Creator     uint            `json:"creator" gorm:"column:creator"`
	Name        string          `json:"name" gorm:"column:name"`
	Description string          `json:"description" gorm:"column:description"`
	StartAt     time.Time       `json:"start_at" gorm:"column:start_at"`
	EndAt       time.Time       `json:"end_at" gorm:"end_at"`
	Conditions  []TaskCondition `json:"conditions,omitempty" gorm:"-"`
}

func (Task) TableName() string {
	return "task"
}

type TaskCondition struct {
	Model
	TaskId uint              `json:"task_id"`
	Type   TaskType          `json:"type" gorm:"column:type;type:tinyint;default:0"`
	Param  datatypes.JSONMap `json:"param" gorm:"column:param;type:json"`
}

func (TaskCondition) TableName() string {
	return "task_condition"
}

type TaskType uint

const (
	TaskTypeClick TaskType = iota
	TaskTypeFile
	TaskTypeImage
	TaskTypeQR
	TaskTypeLocate
	TaskTypeText
	TaskTypeTimer
)

type TaskCommit struct {
	Model
	TaskId      uint              `json:"task_id"  gorm:"column:task_id;uniqueIndex:tid_uid_cid_idx"`
	UserId      uint              `json:"user_id" gorm:"column:user_id;uniqueIndex:tid_uid_cid_idx"`
	ConditionId uint              `json:"cond_id" gorm:"column:cond_id;uniqueIndex:tid_uid_cid_idx"`
	Argument    datatypes.JSONMap `json:"argument"  gorm:"column:argument;type:json"`
}

func (TaskCommit) TableName() string {
	return "task_commit"
}
