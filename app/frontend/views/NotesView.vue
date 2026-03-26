<template>
  <div class="notes-container">
    <header class="app-header">
      <div class="app-brand">
        <span class="brand-icon">&#9998;</span>
        <h1>Anotações</h1>
      </div>
      <div class="header-actions">
        <button class="btn-new-note" @click="openNew" :disabled="creating">
          {{ creating ? 'Criando...' : '+ Nova Nota' }}
        </button>
        <button class="btn-logout" @click="handleLogout">Sair</button>
      </div>
    </header>

    <NoteList ref="list" :categories="categories" @categories-changed="loadCategories" @edit="openEdit" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { logout } from '../services/auth.js'
import { createNote } from '../services/notes.js'
import { fetchCategories } from '../services/categories.js'
import NoteList from '../components/NoteList.vue'

const router = useRouter()
const list = ref(null)
const categories = ref([])
const creating = ref(false)

onMounted(() => {
  loadCategories()
})

async function loadCategories() {
  try {
    categories.value = await fetchCategories()
  } catch {
    categories.value = []
  }
}

async function openNew() {
  creating.value = true
  try {
    const result = await createNote('Sem título', '', null)
    if (result.ok) {
      router.push({ name: 'note-editor', params: { id: result.data.id } })
    }
  } catch {
    // fail silently
  } finally {
    creating.value = false
  }
}

function openEdit(note) {
  router.push({ name: 'note-editor', params: { id: note.id } })
}

function handleLogout() {
  logout()
  router.push({ name: 'login' })
}
</script>

<style scoped>
.notes-container {
  max-width: 960px;
  margin: 0 auto;
  padding: 3rem 2rem 4rem;
  animation: fadeIn 600ms ease-out;
}

.app-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2.5rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid var(--border);
}

.app-brand {
  display: flex;
  align-items: center;
  gap: 0.625rem;
}

.brand-icon {
  font-size: 1.5rem;
  opacity: 0.7;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-new-note {
  background: var(--accent);
  color: #fff;
  padding: 0.5rem 1.25rem;
  border-radius: var(--radius-sm);
  font-size: 0.875rem;
  font-weight: 500;
}

.btn-new-note:hover {
  background: var(--accent-hover);
}

.btn-logout {
  background: transparent;
  color: var(--text-muted);
  font-size: 0.8125rem;
  padding: 0.375rem 0.75rem;
  border-radius: var(--radius-sm);
}

.btn-logout:hover {
  color: var(--danger);
  background: var(--danger-light);
  transform: none;
  box-shadow: none;
}
</style>
