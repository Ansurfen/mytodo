package handler

import (
	"fmt"
	"mytodo/internal/db"
	"mytodo/internal/middleware"
	"mytodo/internal/model"
	"net/http"
	"sync"

	"github.com/caarlos0/log"
	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // 允许所有跨域请求
	},
}

func ChatWS(ctx *gin.Context) {
	// 尝试从 query 参数获取 token
	token := ctx.Query("token")
	if token != "" {
		// 如果从 query 获取到 token，手动解析并设置到 context
		_, claims, err := middleware.ParseToken(token)
		if err != nil {
			log.WithError(err).Error("invalid token from query")
			ctx.AbortWithStatus(http.StatusUnauthorized)
			return
		}
		// 从 claims 中获取用户ID
		var user model.User
		err = db.SQL().Table("user").Where("id = ?", claims.Id).First(&user).Error
		if err != nil {
			log.WithError(err).Error("fail to get user")
			ctx.Abort()
			return
		}

		ctx.Set("user", user)
	} else {
		// 如果没有从 query 获取到 token，使用标准的 auth 中间件
		middleware.Auth(ctx)
	}

	// 获取用户ID
	user, ok := getUser(ctx)
	if !ok {
		ctx.AbortWithStatus(http.StatusUnauthorized)
		return
	}

	// 升级 HTTP 连接为 WebSocket
	conn, err := upgrader.Upgrade(ctx.Writer, ctx.Request, nil)
	if err != nil {
		log.WithError(err).Error("fail to upgrade connection")
		return
	}
	defer conn.Close()

	// 订阅用户频道
	channel := fmt.Sprintf("user_%d", user.ID)
	wsManager := db.WS()

	// 创建一个互斥锁来保护写入操作
	var writeMu sync.Mutex

	// 创建消息处理回调
	callback := func(message interface{}) {
		writeMu.Lock()
		defer writeMu.Unlock()

		err := conn.WriteJSON(message)
		if err != nil {
			log.WithError(err).Error("fail to send message")
			conn.Close()
			return
		}
	}

	// 订阅频道
	wsManager.Subscribe(channel, callback)
	defer wsManager.Unsubscribe(channel)

	// 保持连接
	for {
		_, _, err := conn.ReadMessage()
		if err != nil {
			log.WithError(err).Debug("connection closed")
			break
		}
	}
}
