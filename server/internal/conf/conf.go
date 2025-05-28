package conf

import (
	"os"

	"github.com/caarlos0/log"
	"github.com/spf13/viper"
	"gopkg.in/yaml.v3"
)

type TodoConf struct {
	SQL    SQL           `yaml:"sql"`
	Minio  Minio         `yaml:"minio"`
	Redis  Redis         `yaml:"redis"`
	ES     ElasticSearch `yaml:"es"`
	Server Server        `yaml:"server"`
	Email  Email         `yaml:"email"`
}

var cfg TodoConf

func New() (ret TodoConf) {
	ReadYAML("boot.yaml", &ret)
	cfg = ret
	// viper.BindEnv("email.senderEmail", "ABC")
	// fmt.Println(viper.GetString("email.senderEmail"))
	return
}

func Config() TodoConf {
	return cfg
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

type ElasticSearch struct {
	Addresses []string `yaml:"addresses"`
	Username  string   `yaml:"username"`
	Password  string   `yaml:"password"`
}

type Server struct {
	Host string `yaml:"host"`
	Port string `yaml:"port"`
}

type Email struct {
	Host           string `yaml:"host"`
	Port           string `yaml:"port"`
	SenderEmail    string `yaml:"senderEmail"`
	SenderPassword string `yaml:"senderPassword"`
}

func ReadYAML(filename string, v any) error {
	viper.SetConfigType("yaml")
	viper.AutomaticEnv()
	viper.AddConfigPath(".")
	viper.SetConfigName("boot")

	if err := viper.ReadInConfig(); err != nil {
		return err
	}
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
