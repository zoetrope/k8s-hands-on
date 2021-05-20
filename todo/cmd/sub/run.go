package sub

import (
	"io"
	"math/rand"
	"net/http"
	"time"

	"github.com/cybozu-go/well"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"github.com/zoetrope/k8s-hands-on/todo/server"
)

func subMain() error {
	server := backend.NewAPIServer(config.AllowCORS)

	mux := http.NewServeMux()
	mux.Handle("/api/v1/", backend.WithInstruments("api", server.ServeHTTP))
	mux.Handle("/health", backend.WithInstruments("health", health))
	mux.Handle("/test", backend.WithInstruments("test", test))
	mux.Handle("/metrics", promhttp.Handler())

	fs := http.FileServer(http.Dir(config.ContentDir))
	mux.Handle("/", fs)

	s := &well.HTTPServer{
		Server: &http.Server{
			Addr:    config.ListenAddr,
			Handler: mux,
		},
	}
	err := s.ListenAndServe()
	if err != nil {
		return err
	}
	return well.Wait()
}

func health(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	io.WriteString(w, "ok")
}

func test(w http.ResponseWriter, r *http.Request) {
	waitTimeInMs := rand.Intn(1000)
	time.Sleep(time.Duration(waitTimeInMs) * time.Millisecond)
	n := rand.Intn(2)
	if n == 0 {
		http.Error(w, "error", http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusOK)
	io.WriteString(w, "ok")
}
