<template>
  <v-app>
    <v-app-bar app color="primary" dark>
      <div class="d-flex align-center">
        Todo
      </div>
    </v-app-bar>
    <v-main>
      <v-container>
        <TodoInput @eventAddNewTodo="addNewTodo"/>
        <TodoList :todos="todos"/>
      </v-container>
    </v-main>
  </v-app>
</template>

<script>
import TodoInput from "./components/TodoInput"
import TodoList from "./components/TodoList"
import axios from 'axios';

const apiEndpoint = process.env.VUE_APP_DEV_API_ENDPOINT || '/api/v1'

export default {
  name: 'App',

  components: {
    TodoInput,
    TodoList,
  },

  data() {
    return {
      todos: [],
    }
  },
  mounted() {
    axios.get(apiEndpoint + '/todo')
        .then(response => {
          console.log(response.data);
          (this.todos = response.data)
        })
        .catch((e) => {
          console.log(e)
        })
  },
  methods: {
    addNewTodo(name) {
      axios.post(apiEndpoint + '/todo', {
        name: name,
      })
          .then(() => {
            this.todos.push({name: name})
          })
          .catch((e) => {
            console.log(e)
          })
    }
  }
};
</script>
