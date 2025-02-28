package routes

import (
	"mytodo/internal/handler"
	"mytodo/internal/middleware"

	"github.com/gin-gonic/gin"
)

func InstallTaskRoute(e *gin.Engine) {
	taskRouter := e.Group("/task")
	{
		taskRouter.POST("/new", middleware.Auth, handler.TaskNew)
		taskRouter.POST("/del", middleware.Auth, handler.TaskDel)
		taskRouter.POST("/edit", middleware.Auth, handler.TaskEdit)
		taskRouter.POST("/commit", middleware.Auth, handler.TaskCommit)
		taskRouter.GET("/get", middleware.Auth, handler.TaskGet)
		taskRouter.GET("/qr/:task", middleware.Auth, handler.TaskQR)
	}
}
