<template>
  <form @submit.prevent="handleSubmit" class="note-form">
    <div class="form-group">
      <label for="title">Título *</label>
      <input
        id="title"
        v-model="title"
        type="text"
        placeholder="Digite o título da anotação"
      />
    </div>

    <div class="form-group">
      <label for="content">Conteúdo</label>
      <textarea
        id="content"
        v-model="content"
        placeholder="Digite o conteúdo (opcional)"
        rows="4"
      />
    </div>

    <ul v-if="errors.length" class="errors">
      <li v-for="error in errors" :key="error">{{ error }}</li>
    </ul>

    <button type="submit" :disabled="submitting">
      {{ submitting ? 'Salvando...' : 'Criar Anotação' }}
    </button>
  </form>
</template>

<script setup>
import { ref } from 'vue'
import { createNote } from '../services/api.js'

const emit = defineEmits(['created'])

const title = ref('')
const content = ref('')
const errors = ref([])
const submitting = ref(false)

async function handleSubmit() {
  errors.value = []
  submitting.value = true

  try {
    const result = await createNote(title.value, content.value)

    if (result.ok) {
      title.value = ''
      content.value = ''
      emit('created')
    } else {
      errors.value = result.data.errors || ['Erro ao criar anotação']
    }
  } catch {
    errors.value = ['Erro de conexão com o servidor']
  } finally {
    submitting.value = false
  }
}
</script>
