package routes

import (
	"mytodo/internal/handler"
	"mytodo/internal/middleware"

	"github.com/gin-gonic/gin"
)

func InstallPostRoute(e *gin.Engine) {
	postRouter := e.Group("/post")
	{
		postRouter.POST("/search", middleware.Auth, handler.PostSearch)
		postRouter.POST("/new", middleware.Auth, handler.PostNew)
		postRouter.POST("/edit", middleware.Auth, handler.PostEdit)
		postRouter.POST("/del", middleware.Auth, handler.PostDel)
		postRouter.GET("/me", middleware.Auth, handler.PostMe)
		postRouter.GET("/src/:file", handler.PostSource)
		postRouter.GET("/get/:id", middleware.Auth, handler.PostGet)
		postRouter.GET("/snapshot", middleware.Auth)
		postRouter.POST("/like", middleware.Auth, handler.PostLike)
		commentRouter := postRouter.Group("/comment")
		{
			commentRouter.GET("/get/:post_id", middleware.Auth, handler.PostCommentGet)
			commentRouter.POST("/new", middleware.Auth, handler.PostCommentNew)
			commentRouter.POST("/del", middleware.Auth, handler.PostCommentDel)
			commentRouter.POST("/edit", middleware.Auth, handler.PostCommentEdit)
			commentRouter.POST("/like", middleware.Auth, handler.PostCommentLike)
		}
	}
}
