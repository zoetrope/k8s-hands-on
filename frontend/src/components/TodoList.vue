<template>
  <v-simple-table>
    <template v-slot:default>
      <thead>
      <tr>
        <th class="text-left">
          Name
        </th>
      </tr>
      </thead>
      <tbody>
      <tr
          v-for="item in todos"
          :key="item.name"
      >
        <td>{{ item.name }}</td>
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
}
</script>
