package db

import (
	"fmt"
	"mytodo/internal/conf"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

type TodoOSS struct {
	*minio.Client
}

func NewOSS(opt conf.Minio) *TodoOSS {
	cli, err := minio.New(
		fmt.Sprintf("%s:%d", opt.Host, opt.Port), &minio.Options{
			Creds:  credentials.NewStaticV4(opt.ID, opt.Secret, ""),
			Secure: opt.Secure,
		})
	if err != nil {
		panic(err)
	}
	return &TodoOSS{cli}
}

var oss *TodoOSS

func SetOSS(o *TodoOSS) {
	oss = o
}

func OSS() *TodoOSS {
	return oss
}
