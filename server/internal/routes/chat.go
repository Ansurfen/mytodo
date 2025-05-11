package routes

import (
	"mytodo/internal/handler"
	"mytodo/internal/middleware"

	"github.com/gin-gonic/gin"
)

func InstallChatRoute(e *gin.Engine) {
	chatRouter := e.Group("/chat")
	{
		chatRouter.GET("/snap", middleware.Auth, handler.ChatSnap)
		topicRouter := chatRouter.Group("/topic")
		{
			topicRouter.GET("/snap", middleware.Auth)
			topicRouter.POST("/new", middleware.Auth, handler.ChatTopicNew)
			topicRouter.POST("/upload", middleware.Auth, handler.ChatTopicUpload)
			topicRouter.POST("/get", middleware.Auth, handler.ChatTopicGet)
			topicRouter.POST("/reaction", middleware.Auth, handler.ChatTopicReaction)
			topicRouter.GET("/file/:filename", handler.ChatTopicFile)
			topicRouter.GET("/audio/:filename")
			topicRouter.POST("/read", middleware.Auth, handler.ChatTopicRead)
		}
		friendRouter := chatRouter.Group("/friend")
		{
			friendRouter.GET("/snap", middleware.Auth)
			friendRouter.POST("/new", middleware.Auth, handler.ChatFriendNew)
			friendRouter.POST("/upload", middleware.Auth, handler.ChatFriendUpload)
			friendRouter.POST("/get", middleware.Auth, handler.ChatFriendGet)
			// friendRouter.POST("/del", middleware.Auth, handler.ChatTopicDel)
			friendRouter.POST("/reaction", middleware.Auth, handler.ChatFriendReaction)
			friendRouter.GET("/file/:filename", handler.ChatFriendFile)
			friendRouter.GET("/audio/:filename")
			friendRouter.POST("/read", middleware.Auth, handler.ChatFriendRead)
		}
		chatRouter.GET("/ws", handler.ChatWS)
	}
}
