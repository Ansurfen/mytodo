package model

// SwaggerModel 用于Swagger文档的基础模型
type SwaggerModel struct {
	ID        uint   `json:"id"`
	CreatedAt string `json:"createdAt"`
	UpdatedAt string `json:"updatedAt"`
	DeletedAt string `json:"deletedAt"`
}

// SwaggerUser 用于Swagger文档的用户模型
type SwaggerUser struct {
	SwaggerModel
	Name     string `json:"name"`
	Email    string `json:"email"`
	Avatar   string `json:"avatar"`
	Role     uint   `json:"role"`
	Status   uint   `json:"status"`
	LastSeen string `json:"lastSeen"`
}

// SwaggerTask 用于Swagger文档的任务模型
type SwaggerTask struct {
	SwaggerModel
	Title       string      `json:"title"`
	Description string      `json:"description"`
	Creator     uint        `json:"creator"`
	Status      uint        `json:"status"`
	Priority    uint        `json:"priority"`
	Conditions  interface{} `json:"conditions"`
}

// SwaggerNotification 用于Swagger文档的通知模型
type SwaggerNotification struct {
	SwaggerModel
	Type        uint   `json:"type"`
	Creator     uint   `json:"creator"`
	Name        string `json:"name"`
	Description string `json:"description"`
}

// SwaggerTopic 用于Swagger文档的主题模型
type SwaggerTopic struct {
	SwaggerModel
	Name        string `json:"name"`
	Description string `json:"description"`
	Creator     uint   `json:"creator"`
	Status      uint   `json:"status"`
}

// SwaggerChat 用于Swagger文档的聊天模型
type SwaggerChat struct {
	SwaggerModel
	Type    uint   `json:"type"`
	Content string `json:"content"`
	Sender  uint   `json:"sender"`
	Target  uint   `json:"target"`
}
