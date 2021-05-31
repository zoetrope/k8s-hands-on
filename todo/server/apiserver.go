package backend

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
	"sync"

	"github.com/cybozu-go/log"
)

func NewAPIServer(allowCORS bool) http.Handler {
	todos := make([]todo, 0)
	return &apiServer{
		allowCORS: allowCORS,
		todos:     todos,
	}
}

type apiServer struct {
	allowCORS bool

	mu    sync.Mutex
	todos []todo
	count int
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
	case r.Method == http.MethodPut && strings.HasPrefix(p, "todo/"):
		s.updateTodo(w, r)
	case r.Method == http.MethodDelete && strings.HasPrefix(p, "todo/"):
		s.removeTodo(w, r)
	default:
		http.Error(w, "requested resource is not found", http.StatusNotFound)
	}
}

type todo struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
	Done bool   `json:"done"`
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
	todo.ID = s.count
	s.count++
	log.Info("add todo: ", map[string]interface{}{"todo": todo})
	s.todos = append(s.todos, todo)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	err = json.NewEncoder(w).Encode(todo)
	if err != nil {
		log.Error("failed to output JSON", map[string]interface{}{
			log.FnError: err.Error(),
		})
	}
}

func (s *apiServer) updateTodo(w http.ResponseWriter, r *http.Request) {
	s.mu.Lock()
	defer s.mu.Unlock()

	id, err := strconv.Atoi(r.URL.Path[len("/api/v1/todo/"):])
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	var todo todo
	err = json.NewDecoder(r.Body).Decode(&todo)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	for i, t := range s.todos {
		if t.ID == id {
			log.Info("update todo: ", map[string]interface{}{"todo": todo})
			s.todos[i].Name = todo.Name
			s.todos[i].Done = todo.Done
			return
		}
	}
	http.Error(w, "id not found", http.StatusNotFound)
}

func (s *apiServer) removeTodo(w http.ResponseWriter, r *http.Request) {
	s.mu.Lock()
	defer s.mu.Unlock()

	id, err := strconv.Atoi(r.URL.Path[len("/api/v1/todo/"):])
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	for i, t := range s.todos {
		if t.ID == id {
			s.todos = append(s.todos[:i], s.todos[i+1:]...)
			log.Info("remove todo: ", map[string]interface{}{"id": id})
			return
		}
	}
	http.Error(w, "id not found", http.StatusNotFound)
}
