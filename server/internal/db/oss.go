package db

import (
	"context"
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

func (o *TodoOSS) MakeBuckets(buckets ...string) error {
	for _, bucket := range buckets {
		exist, err := o.BucketExists(context.Background(), bucket)
		if err != nil {
			return err
		}
		if !exist {
			err = o.MakeBucket(context.Background(), bucket, minio.MakeBucketOptions{})
			if err != nil {
				return err
			}
		}
	}
	return nil
}
