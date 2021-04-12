<template>
  <v-simple-table dense="true">
    <template v-slot:default>
      <thead>
      <tr>
        <th width="20"></th>
        <th class="text-left"></th>
        <th width="20"></th>
      </tr>
      </thead>
      <tbody>
      <tr v-for="item in todos" :key="item.id">
        <td>
          <v-checkbox v-model="item.done" @click="updateTodo(item)"></v-checkbox>
        </td>
        <td>{{ item.name }}</td>
        <td>
          <v-btn @click="removeTodo(item)" icon>
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </td>
      </tr>
      </tbody>
    </template>
  </v-simple-table>
</template>
<script>

export default {
  props: {
    todos: {
      type: Array,
    }
  },
  methods: {
    updateTodo(item) {
      this.$emit("eventUpdateTodo", item)
    },
    removeTodo(item) {
      this.$emit("eventRemoveTodo", item)
    }
  }
}
</script>
