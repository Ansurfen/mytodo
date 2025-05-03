package routes

import (
	"mytodo/internal/handler"
	"mytodo/internal/middleware"

	"github.com/gin-gonic/gin"
)

func InstallNotificationRoute(e *gin.Engine) {
	notificationRouter := e.Group("/notification")
	{
		notificationRouter.POST("/new", middleware.Auth, handler.NotificationNew)
		notificationRouter.GET("/get", middleware.Auth, handler.NotificationGet)
		notificationRouter.POST("/del", middleware.Auth, handler.NotificationDel)
		notificationRouter.GET("/unread/count", middleware.Auth, handler.NotificationUnreadCount)
		publishRouter := notificationRouter.Group("/publish")
		{
			publishRouter.POST("/new", middleware.Auth, handler.NotificationPublishNew)
			publishRouter.GET("/get", middleware.Auth, handler.NotificationPublishGet)
		}
	}
}
