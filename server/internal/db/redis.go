package db

import (
	"context"
	"fmt"
	"mytodo/internal/conf"

	"github.com/go-redis/redis/v8"
)

type RedisDB struct {
	*redis.Client
	ctx context.Context
}

func NewRdb(opt conf.Redis) *RedisDB {
	return &RedisDB{
		Client: redis.NewClient(&redis.Options{
			Addr: fmt.Sprintf("%s:%d", opt.Host, opt.Port),
		}),
		ctx: context.Background(),
	}
}

var rdb *RedisDB

func SetRdb(r *RedisDB) {
	rdb = r
}

func Rdb() *RedisDB {
	return rdb
}
