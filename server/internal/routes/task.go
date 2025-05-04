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
		taskRouter.GET("/dashboard", middleware.Auth, handler.TaskDashboard)
		taskRouter.GET("/qr/:taskId", middleware.Auth, handler.TaskQR)
		taskRouter.GET("/heatmap", middleware.Auth, handler.TaskHeatMap)
		taskRouter.GET("/locate/:filename", handler.TaskLocate)
		taskRouter.POST("/file/upload", middleware.Auth, handler.TaskFileUpload)
		taskRouter.GET("/file/:filename", handler.TaskFileDownload)
		taskRouter.DELETE("/file/:filename", middleware.Auth, handler.TaskFileDelete)
		taskRouter.GET("/detail/:taskId", middleware.Auth, handler.TaskDetail)
		taskRouter.GET("/stats/:taskId", middleware.Auth, handler.TaskStats)
		taskRouter.GET("/permission/:taskId", middleware.Auth, handler.TaskPermission)
	}
}
