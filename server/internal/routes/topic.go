package routes

import (
	"mytodo/internal/handler"
	"mytodo/internal/middleware"

	"github.com/gin-gonic/gin"
)

func InstallTopicRoute(e *gin.Engine) {
	topicRouter := e.Group("/topic")
	{
		topicRouter.POST("/new", middleware.Auth, handler.TopicNew)
		topicRouter.GET("/get", middleware.Auth, handler.TopicGet)
		topicRouter.POST("/join", middleware.Auth, handler.TopicJoin)
		topicRouter.POST("/exit", middleware.Auth, handler.TopicExit)
		topicRouter.POST("/edit", middleware.Auth, handler.TopicEdit)
		memberRouter := topicRouter.Group("/member")
		{
			memberRouter.POST("/invite", middleware.Auth, handler.TopicMemberInvite)
			memberRouter.GET("/get", handler.TopicMemberGet)
			memberRouter.POST("/del", middleware.Auth, handler.TopicMemberDel)
		}
	}
}
