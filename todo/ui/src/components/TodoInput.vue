<template>
  <v-form ref="form" @submit.prevent>
    <v-text-field
        label="what needs to be done?"
        v-model="newTodo"
        @keyup.enter="addNewTodo"
        autofocus
        required
    ></v-text-field>
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
