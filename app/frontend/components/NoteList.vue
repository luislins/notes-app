<template>
  <div class="note-list">
    <p v-if="loading">Carregando...</p>
    <p v-else-if="notes.length === 0" class="empty">Nenhuma anotação encontrada.</p>
    <div v-else>
      <div v-for="note in notes" :key="note.id" class="note-card">
        <h3>{{ note.title }}</h3>
        <p v-if="note.content">{{ note.content }}</p>
        <small>{{ formatDate(note.created_at) }}</small>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const notes = ref([])
const loading = ref(true)

const API_URL = 'http://localhost:5100/api/notes'

async function fetchNotes() {
  loading.value = true
  try {
    const response = await fetch(API_URL)
    notes.value = await response.json()
  } catch {
    notes.value = []
  } finally {
    loading.value = false
  }
}

function formatDate(dateString) {
  return new Date(dateString).toLocaleDateString('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

onMounted(fetchNotes)

defineExpose({ fetchNotes })
</script>
