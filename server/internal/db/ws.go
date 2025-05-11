package db

import (
	"sync"

	"github.com/caarlos0/log"
)

type WSManager interface {
	Send(channel string, message interface{})
	Subscribe(channel string, callback func(interface{}))
	Unsubscribe(channel string)
}

type wsManager struct {
	subscribers map[string][]func(interface{})
	mu          sync.RWMutex
}

var (
	ws     *wsManager
	wsOnce sync.Once
)

func NewWS() *wsManager {
	wsOnce.Do(func() {
		ws = &wsManager{
			subscribers: make(map[string][]func(interface{})),
		}
	})
	return ws
}

func WS() WSManager {
	if ws == nil {
		return NewWS()
	}
	return ws
}

func (w *wsManager) Send(channel string, message interface{}) {
	w.mu.RLock()
	callbacks, ok := w.subscribers[channel]
	w.mu.RUnlock()

	if !ok {
		return
	}

	// 为每个回调创建一个互斥锁
	var wg sync.WaitGroup
	for _, callback := range callbacks {
		wg.Add(1)
		go func(cb func(interface{})) {
			defer wg.Done()
			defer func() {
				if r := recover(); r != nil {
					log.WithField("error", r).Error("panic in websocket callback")
				}
			}()
			cb(message)
		}(callback)
	}
	wg.Wait()
}

func (w *wsManager) Subscribe(channel string, callback func(interface{})) {
	w.mu.Lock()
	defer w.mu.Unlock()
	w.subscribers[channel] = append(w.subscribers[channel], callback)
}

func (w *wsManager) Unsubscribe(channel string) {
	w.mu.Lock()
	defer w.mu.Unlock()
	delete(w.subscribers, channel)
}
