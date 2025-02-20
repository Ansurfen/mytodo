package conf

import (
	"os"

	"github.com/caarlos0/log"
	"gopkg.in/yaml.v3"
)

type TodoConf struct {
	SQL   SQL   `yaml:"sql"`
	Minio Minio `yaml:"minio"`
	Redis Redis `yaml:"redis"`
}

func New() (ret TodoConf) {
	ReadYAML("boot.yaml", &ret)
	return
}

type SQL struct {
	Username string `yaml:"username"`
	Password string `yaml:"password"`
	Host     string `yaml:"host"`
	Port     int    `yaml:"port"`
	Database string `yaml:"database"`
}

type Minio struct {
	Host   string `yaml:"host"`
	Port   int    `yaml:"port"`
	ID     string `yaml:"id"`
	Secret string `yaml:"secret"`
	Secure bool   `yaml:"secure"`
}

type Redis struct {
	Host string `yaml:"host"`
	Port int    `yaml:"port"`
}

func ReadYAML(filename string, v any) error {
	data, err := ReadFile(filename)
	if err != nil {
		return err
	}
	log.Debug("parsing configure")
	return yaml.Unmarshal(data, v)
}

func ReadFile(name string) ([]byte, error) {
	log.Debugf("reading %s", name)
	return os.ReadFile(name)
}
