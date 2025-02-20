package routes

import (
	"mytodo/internal/handler"
	"mytodo/internal/middleware"

	"github.com/gin-gonic/gin"
)

func InstallUserRoute(e *gin.Engine) {
	userRouter := e.Group("/user")
	{
		userRouter.POST("/sign", handler.UserSign)
		userRouter.GET("/get/:id", handler.UserGet)
		userRouter.GET("/profile/:id", handler.UserProfile)
		userRouter.GET("/online", handler.UserOnline)

		friendRouter := userRouter.Group("/friend")
		{
			friendRouter.POST("/new", middleware.Auth, handler.FriendNew)
			friendRouter.GET("/get", middleware.Auth, handler.FriendGet)
			friendRouter.POST("/del", middleware.Auth, handler.FriendDel)
		}
	}
}
