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
		topicRouter.GET("/getSelectable", middleware.Auth, handler.TopicGetSelectable)
		topicRouter.POST("/calendar", middleware.Auth, handler.TopicCalendar)
		topicRouter.POST("/join", middleware.Auth, handler.TopicJoin)
		topicRouter.POST("/exit", middleware.Auth, handler.TopicExit)
		topicRouter.POST("/edit", middleware.Auth, handler.TopicEdit)
		memberRouter := topicRouter.Group("/member")
		{
			memberRouter.POST("/invite", middleware.Auth, handler.TopicMemberInvite)
			memberRouter.POST("/get", handler.TopicMemberGet)
			memberRouter.POST("/del", middleware.Auth, handler.TopicMemberDel)
		}
	}
}
