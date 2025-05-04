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
		topicRouter.POST("/find", handler.TopicFind)
		topicRouter.POST("/apply/new", middleware.Auth, handler.TopicApplyNew)
		topicRouter.POST("/apply/commit", middleware.Auth, handler.TopicApplyCommit)
		topicRouter.GET("/getSelectable", middleware.Auth, handler.TopicGetSelectable)
		topicRouter.POST("/calendar", middleware.Auth, handler.TopicCalendar)
		topicRouter.POST("/join", middleware.Auth, handler.TopicJoin)
		topicRouter.POST("/exit", middleware.Auth, handler.TopicExit)
		topicRouter.POST("/del", middleware.Auth, handler.TopicDel)
		topicRouter.POST("/edit", middleware.Auth, handler.TopicEdit)
		topicRouter.POST("/disband", middleware.Auth, handler.TopicDisband)
		topicRouter.GET("/permission/:topicId", middleware.Auth, handler.TopicPermission)
		topicRouter.POST("/subscribe", middleware.Auth, handler.TopicSubscribe)
		memberRouter := topicRouter.Group("/member")
		{
			memberRouter.POST("/invite", middleware.Auth, handler.TopicMemberInvite)
			memberRouter.POST("/get", handler.TopicMemberGet)
			memberRouter.POST("/del", middleware.Auth, handler.TopicMemberDel)
			memberRouter.POST("/commit", middleware.Auth, handler.TopicMemberCommit)
			memberRouter.POST("/grant_admin", middleware.Auth, handler.TopicGrantAdmin)
			memberRouter.POST("/revoke_admin", middleware.Auth, handler.TopicRevokeAdmin)
			memberRouter.POST("/remove", middleware.Auth, handler.TopicRemoveMember)
		}
	}
}
