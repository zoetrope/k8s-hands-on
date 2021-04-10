package sub

import (
	"github.com/cybozu-go/well"
	"github.com/zoetrope/neco-hands-on/backend"
	"net/http"
)

func subMain() error {
	server := backend.NewAPIServer(config.AllowCORS)

	mux := http.NewServeMux()
	mux.Handle("/api/v1/", server)

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
