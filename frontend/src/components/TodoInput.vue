<template>
  <v-form ref="form">
    <v-text-field label="What needs to be done?" v-model="newTodo" required></v-text-field>
    <v-btn @click="addNewTodo">Add</v-btn>
  </v-form>
</template>

<script>
export default {
  name: "TodoInput",
  data() {
    return {
      newTodo: ""
    }
  },
  methods: {
    addNewTodo(e) {
      e.preventDefault()
      const name = this.newTodo
      if (name === "") {
        return
      }
      console.log("new todo: " + name)
      this.$emit("eventAddNewTodo", name)
      this.newTodo = ""
    }
  }
}
</script>
