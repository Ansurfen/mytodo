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
		userRouter.POST("/login", handler.UserLogin)
		userRouter.POST("/signup", handler.UserSignUp)
		userRouter.POST("/recover", handler.UserRecover)
		userRouter.POST("/verify", handler.UserVerifyOTP)
		userRouter.GET("/detail", middleware.Auth, handler.UserDetail)
		userRouter.GET("/get/:id", handler.UserGet)
		userRouter.GET("/profile/:id", handler.UserProfile)
		userRouter.GET("/online", handler.UserOnline)
		userRouter.POST("/edit", middleware.Auth, handler.UserEdit)
		userRouter.POST("/edit_password", middleware.Auth, handler.UserEditPassword)
		userRouter.GET("/contacts", middleware.Auth, handler.UserContacts)

		friendRouter := userRouter.Group("/friend")
		{
			friendRouter.POST("/new", middleware.Auth, handler.FriendNew)
			friendRouter.POST("/commit", middleware.Auth, handler.FriendCommit)
			friendRouter.GET("/get/:friend_id", middleware.Auth, handler.FriendGet)
			friendRouter.GET("/snapshot", middleware.Auth, handler.FriendSnapshot)
			friendRouter.POST("/del", middleware.Auth, handler.FriendDel)
			friendRouter.POST("/post/get", middleware.Auth, handler.FriendPostGet)
		}
	}
}
