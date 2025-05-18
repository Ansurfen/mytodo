package metrics

import (
	"github.com/gin-gonic/gin"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	// HTTPRequestsTotal 记录 HTTP 请求总数
	HTTPRequestsTotal = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"method", "path", "status"},
	)

	// HTTPRequestDuration 记录 HTTP 请求持续时间
	HTTPRequestDuration = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_request_duration_seconds",
			Help:    "Duration of HTTP requests in seconds",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"method", "path"},
	)

	// DatabaseOperationsTotal 记录数据库操作总数
	DatabaseOperationsTotal = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "database_operations_total",
			Help: "Total number of database operations",
		},
		[]string{"operation", "table"},
	)

	// DatabaseOperationDuration 记录数据库操作持续时间
	DatabaseOperationDuration = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "database_operation_duration_seconds",
			Help:    "Duration of database operations in seconds",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"operation", "table"},
	)

	// CacheOperationsTotal 记录缓存操作总数
	CacheOperationsTotal = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "cache_operations_total",
			Help: "Total number of cache operations",
		},
		[]string{"operation", "key"},
	)

	// CacheOperationDuration 记录缓存操作持续时间
	CacheOperationDuration = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "cache_operation_duration_seconds",
			Help:    "Duration of cache operations in seconds",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"operation", "key"},
	)
)

// RegisterMetrics 注册所有指标
func RegisterMetrics(r *gin.Engine) {
	// 注册 metrics 端点
	r.GET("/internal/metrics", func(c *gin.Context) {
		promhttp.Handler().ServeHTTP(c.Writer, c.Request)
	})
}

// RecordHTTPRequest 记录 HTTP 请求指标
func RecordHTTPRequest(method, path string, status int, duration float64) {
	HTTPRequestsTotal.WithLabelValues(method, path, string(status)).Inc()
	HTTPRequestDuration.WithLabelValues(method, path).Observe(duration)
}

// RecordDatabaseOperation 记录数据库操作指标
func RecordDatabaseOperation(operation, table string, duration float64) {
	DatabaseOperationsTotal.WithLabelValues(operation, table).Inc()
	DatabaseOperationDuration.WithLabelValues(operation, table).Observe(duration)
}

// RecordCacheOperation 记录缓存操作指标
func RecordCacheOperation(operation, key string, duration float64) {
	CacheOperationsTotal.WithLabelValues(operation, key).Inc()
	CacheOperationDuration.WithLabelValues(operation, key).Observe(duration)
}
