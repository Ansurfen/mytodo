package routes

import (
	"mytodo/internal/handler"
	"mytodo/internal/middleware"

	"github.com/gin-gonic/gin"
)

func InstallChatRoute(e *gin.Engine) {
	chatRouter := e.Group("/chat")
	{
		topicRouter := chatRouter.Group("/topic")
		{
			topicRouter.POST("/new", middleware.Auth, handler.ChatTopicNew)
			topicRouter.POST("/upload", middleware.Auth, handler.ChatTopicUpload)
			topicRouter.POST("/get", middleware.Auth, handler.ChatTopicGet)
			topicRouter.POST("/del", middleware.Auth, handler.ChatTopicDel)
			topicRouter.POST("/reaction", middleware.Auth, handler.ChatTopicReaction) 
			topicRouter.GET("/image/:filename", handler.ChatTopicImage)
			topicRouter.GET("/audio/:filename")
		}
	}
}
