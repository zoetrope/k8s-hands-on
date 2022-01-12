import Alpine from 'alpinejs'

window.Alpine = Alpine
const apiEndpoint = process.env.DEV_API_ENDPOINT || '/api/v1'

Alpine.data('app', () => ({
  newTodo: "",
  todos: [],
  add() {
    fetch(apiEndpoint + "/todo", {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=utf-8"
      },
      body: JSON.stringify({
        name: this.newTodo
      })
    })
    .then(res => res.json())
    .then(res => {
      this.todos.push({name: res.name, id: res.id, done: false})
    })
    .catch(error => {
      console.error('failed to add todo', error);
    });
    this.newTodo = "";
  },
  update(index) {
    this.todos[index].done = !this.todos[index].done;
    fetch(apiEndpoint + "/todo/" + this.todos[index].id, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json; charset=utf-8"
      },
      body: JSON.stringify(this.todos[index])
    })
    .catch(error => {
      console.error('failed to update todo', error);
    });
  },
  remove(index) {
    fetch(apiEndpoint + "/todo/" + this.todos[index].id, {
      method: "DELETE",
      headers: {
        "Content-Type": "application/json; charset=utf-8"
      }
    })
    .then(() => {
      this.todos = this.todos.filter(n => n.id !== this.todos[index].id);
    })
    .catch(error => {
      console.error('failed to delete todo', error);
    });
  },
  isLast(index) {
    return this.todos.length - 1 === index
  },
  init() {
    fetch(apiEndpoint + '/todo')
    .then(response => response.json())
    .then(data => {
      this.todos = data
    })
    .catch(error => {
      console.error('failed to fetch todos', error);
    });
  }
}));

Alpine.start()
