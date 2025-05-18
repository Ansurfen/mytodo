package middleware

import (
	"time"

	"mytodo/internal/metrics"

	"github.com/gin-gonic/gin"
)

// Prometheus 中间件用于收集 HTTP 请求的指标
func Prometheus() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		path := c.FullPath()
		if path == "" {
			path = "unknown"
		}

		// 处理请求
		c.Next()

		// 记录请求指标
		duration := time.Since(start).Seconds()
		status := c.Writer.Status()
		metrics.RecordHTTPRequest(c.Request.Method, path, status, duration)
	}
}
