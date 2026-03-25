<template>
  <div class="note-list">
    <p v-if="loading">Carregando...</p>
    <p v-else-if="notes.length === 0" class="empty">Nenhuma anotação encontrada.</p>
    <div v-else>
      <div v-for="note in notes" :key="note.id" class="note-card">
        <template v-if="editingId === note.id">
          <form @submit.prevent="saveEdit(note.id)" class="edit-form">
            <input v-model="editTitle" placeholder="Título" />
            <textarea v-model="editContent" placeholder="Conteúdo (opcional)" rows="3" />
            <ul v-if="editErrors.length" class="errors">
              <li v-for="error in editErrors" :key="error">{{ error }}</li>
            </ul>
            <div class="actions">
              <button type="submit">Salvar</button>
              <button type="button" class="btn-cancel" @click="cancelEdit">Cancelar</button>
            </div>
          </form>
        </template>
        <template v-else>
          <h3>{{ note.title }}</h3>
          <p v-if="note.content">{{ note.content }}</p>
          <div class="note-footer">
            <small>{{ formatDate(note.created_at) }}</small>
            <div class="actions">
              <button class="btn-edit" @click="startEdit(note)">Editar</button>
              <button class="btn-delete" @click="deleteNote(note.id)">Excluir</button>
            </div>
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const notes = ref([])
const loading = ref(true)
const editingId = ref(null)
const editTitle = ref('')
const editContent = ref('')
const editErrors = ref([])

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

function startEdit(note) {
  editingId.value = note.id
  editTitle.value = note.title
  editContent.value = note.content || ''
  editErrors.value = []
}

function cancelEdit() {
  editingId.value = null
  editErrors.value = []
}

async function saveEdit(id) {
  editErrors.value = []
  try {
    const response = await fetch(`${API_URL}/${id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ note: { title: editTitle.value, content: editContent.value } })
    })

    if (response.ok) {
      editingId.value = null
      await fetchNotes()
    } else {
      const data = await response.json()
      editErrors.value = data.errors || ['Erro ao atualizar anotação']
    }
  } catch {
    editErrors.value = ['Erro de conexão com o servidor']
  }
}

async function deleteNote(id) {
  if (!confirm('Tem certeza que deseja excluir esta anotação?')) return

  try {
    await fetch(`${API_URL}/${id}`, { method: 'DELETE' })
    await fetchNotes()
  } catch {
    alert('Erro ao excluir anotação')
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
