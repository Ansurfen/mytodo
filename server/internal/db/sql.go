package db

import (
	"fmt"
	"mytodo/internal/conf"

	"github.com/caarlos0/log"
	_ "github.com/go-sql-driver/mysql"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

type TodoDB struct {
	*gorm.DB
}

func NewSQL(opt conf.SQL) *TodoDB {
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?parseTime=true",
		opt.Username,
		opt.Password,
		opt.Host,
		opt.Port,
		opt.Database)
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		log.WithError(err).Fatal("fail to dial mysql")
	}
	return &TodoDB{db}
}

func (db *TodoDB) Rawf(format string, arg ...any) (tx *gorm.DB) {
	sql := fmt.Sprintf(format, arg...)
	return db.DB.Raw(sql)
}

var sql *TodoDB

func SetSQL(db *TodoDB) {
	sql = db
}

func SQL() *TodoDB {
	return sql
}
