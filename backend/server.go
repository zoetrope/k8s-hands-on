package backend

import (
	"encoding/json"
	"github.com/cybozu-go/log"
	"net/http"
	"sync"
)

func NewAPIServer(allowCORS bool) http.Handler {
	todos := make([]todo, 0)
	return &apiServer{
		allowCORS: allowCORS,
		todos: todos,
	}
}

type apiServer struct {
	allowCORS bool

	mu sync.Mutex
	todos []todo
}

func (s *apiServer) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if s.allowCORS {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Headers", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		if r.Method == http.MethodOptions {
			return
		}
	}

	p := r.URL.Path[len("/api/v1/"):]
	switch {
	case r.Method == http.MethodGet && p == "todo":
		s.listTodos(w, r)
	case r.Method == http.MethodPost && p == "todo":
		s.addTodo(w, r)
	default:
		http.Error(w, "requested resource is not found", http.StatusNotFound)
	}
}

type todo struct {
	Name string `json:"name"`
}

func (s *apiServer) listTodos(w http.ResponseWriter, r *http.Request) {
	s.mu.Lock()
	defer s.mu.Unlock()

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	err := json.NewEncoder(w).Encode(s.todos)
	if err != nil {
		log.Error("failed to output JSON", map[string]interface{}{
			log.FnError: err.Error(),
		})
	}
}

func (s *apiServer) addTodo(w http.ResponseWriter, r *http.Request) {
	s.mu.Lock()
	defer s.mu.Unlock()

	var todo todo
	err := json.NewDecoder(r.Body).Decode(&todo)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	log.Info("add todo: ", map[string]interface{}{"todo": todo})
	s.todos = append(s.todos, todo)
}
