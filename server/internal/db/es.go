package db

import (
	"mytodo/internal/conf"

	"github.com/elastic/go-elasticsearch/v8"
)

type TodoES struct {
	*elasticsearch.Client
}

func NewES(opt conf.ElasticSearch) *TodoES {
	cli, err := elasticsearch.NewClient(elasticsearch.Config{
		Addresses: opt.Addresses,
	})
	if err != nil {
		panic(err)
	}
	return &TodoES{Client: cli}
}

var es *TodoES

func SetES(e *TodoES) {
	es = e
}

func ES() *TodoES {
	return es
}
