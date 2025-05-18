package model

import (
	"database/sql"
	"time"

	"gorm.io/datatypes"
	"gorm.io/gorm"
)

// Model struct represents the base model for database tables,
// which includes common fields such as ID, CreatedAt, UpdatedAt, and DeletedAt.
type Model struct {
	// ID is the primary key of the model.
	ID uint `json:"id" gorm:"primarykey"`

	// CreatedAt is the timestamp when the record was created.
	CreatedAt time.Time `json:"createdAt" gorm:"column:created_at;"`

	// UpdatedAt is the timestamp when the record was last updated.
	UpdatedAt time.Time `json:"updatedAt" gorm:"column:updated_at;"`

	// DeletedAt is used to track soft-deletion and is indexed.
	DeletedAt gorm.DeletedAt `json:"deletedAt" gorm:"index"`
}

// Exist checks if the model has a non-zero ID.
// Returns true if the ID is not zero, indicating the model exists.
func (m *Model) Exist() bool {
	return m.ID != 0
}

type NullString = sql.NullString

// JSONMap is a type alias for datatypes.JSONMap
type JSONMap = datatypes.JSONMap
