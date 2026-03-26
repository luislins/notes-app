<template>
  <div class="note-editor-card">
    <ul v-if="errors.length" class="editor-errors">
      <li v-for="error in errors" :key="error">{{ error }}</li>
    </ul>

    <input
      ref="titleInput"
      v-model="title"
      type="text"
      class="editor-title"
      placeholder="Título da nota"
      @keydown.enter.prevent="$refs.contentArea.focus()"
    />

    <textarea
      ref="contentArea"
      v-model="content"
      class="editor-content"
      placeholder="Escreva sua nota..."
    />

    <div class="editor-footer">
      <button class="btn-save" :disabled="submitting" @click="handleSubmit">
        {{ submitting ? 'Salvando...' : 'Salvar' }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { createNote } from '../services/api.js'

const emit = defineEmits(['created'])

const title = ref('')
const content = ref('')
const errors = ref([])
const submitting = ref(false)
const titleInput = ref(null)

onMounted(() => {
  titleInput.value?.focus()
})

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
