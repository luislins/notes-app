<template>
  <div class="container">
    <template v-if="authenticated">
      <header class="app-header">
        <div class="app-brand">
          <span class="brand-icon">&#9998;</span>
          <h1>Anotações</h1>
        </div>
        <div class="header-actions">
          <button class="btn-new-note" @click="openNew">+ Nova Nota</button>
          <button class="btn-logout" @click="handleLogout">Sair</button>
        </div>
      </header>

      <div v-if="showEditor" class="note-editor-overlay">
        <button class="btn-editor-close" @click="closeEditor">&times;</button>
        <NoteForm :categories="categories" :note="editingNote" @saved="onNoteSaved" />
      </div>

      <NoteList ref="list" :categories="categories" @categories-changed="loadCategories" @edit="openEdit" />
    </template>
    <AuthForm v-else @authenticated="onAuthenticated" />
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { isAuthenticated, logout, fetchCategories } from '../services/api.js'
import AuthForm from './AuthForm.vue'
import NoteForm from './NoteForm.vue'
import NoteList from './NoteList.vue'

const authenticated = ref(false)
const showEditor = ref(false)
const editingNote = ref(null)
const list = ref(null)
const categories = ref([])

function handleKeydown(e) {
  if (e.key === 'Escape' && showEditor.value) {
    closeEditor()
  }
}

onMounted(() => {
  authenticated.value = isAuthenticated()
  if (authenticated.value) loadCategories()
  document.addEventListener('keydown', handleKeydown)
})

onBeforeUnmount(() => {
  document.removeEventListener('keydown', handleKeydown)
})

function onAuthenticated() {
  authenticated.value = true
  loadCategories()
}

async function loadCategories() {
  try {
    categories.value = await fetchCategories()
  } catch {
    categories.value = []
  }
}

function openNew() {
  editingNote.value = null
  showEditor.value = true
}

function openEdit(note) {
  editingNote.value = note
  showEditor.value = true
}

function closeEditor() {
  showEditor.value = false
  editingNote.value = null
}

function onNoteSaved() {
  closeEditor()
  list.value.fetchNotes()
}

function handleLogout() {
  logout()
  authenticated.value = false
}
</script>

<!-- Global styles: variables, reset, base typography, animations -->
<style>
:root {
  --bg: #f6f3ee;
  --surface: #fffdf9;
  --surface-hover: #faf7f2;
  --border: #e8e2d9;
  --border-focus: #c4a882;
  --text: #2c2418;
  --text-secondary: #7a6e5d;
  --text-muted: #a69e90;
  --accent: #b8860b;
  --accent-hover: #9a7209;
  --accent-light: rgba(184, 134, 11, 0.08);
  --danger: #c0392b;
  --danger-hover: #a93226;
  --danger-light: rgba(192, 57, 43, 0.06);
  --shadow-sm: 0 1px 2px rgba(44, 36, 24, 0.04);
  --shadow-md: 0 4px 12px rgba(44, 36, 24, 0.06);
  --shadow-lg: 0 8px 24px rgba(44, 36, 24, 0.08);
  --radius: 12px;
  --radius-sm: 8px;
  --font-display: 'Instrument Serif', Georgia, serif;
  --font-body: 'DM Sans', system-ui, sans-serif;
  --transition: 200ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: var(--font-body);
  background: var(--bg);
  color: var(--text);
  line-height: 1.6;
  -webkit-font-smoothing: antialiased;
}

h1 {
  font-family: var(--font-display);
  font-size: 2.25rem;
  font-weight: 400;
  letter-spacing: -0.01em;
  color: var(--text);
}

h2 {
  font-family: var(--font-display);
  font-size: 1.75rem;
  font-weight: 400;
  margin-bottom: 1.5rem;
  color: var(--text);
}

button {
  font-family: var(--font-body);
  background: var(--accent);
  color: #fff;
  border: none;
  padding: 0.625rem 1.5rem;
  border-radius: var(--radius-sm);
  font-size: 0.875rem;
  font-weight: 500;
  cursor: pointer;
  transition: all var(--transition);
  letter-spacing: 0.01em;
}

button:hover {
  background: var(--accent-hover);
  transform: translateY(-1px);
  box-shadow: var(--shadow-sm);
}

button:active {
  transform: translateY(0);
}

button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes slideIn {
  from { opacity: 0; transform: translateY(12px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>

<!-- Scoped styles: App layout -->
<style scoped>
.container {
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

.note-editor-overlay {
  position: fixed;
  inset: 0;
  background: var(--bg);
  z-index: 100;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 1.5rem;
  animation: fadeIn 250ms ease-out;
}

.btn-editor-close {
  position: absolute;
  top: 1.25rem;
  right: 1.5rem;
  background: transparent;
  color: var(--text-muted);
  font-size: 2rem;
  padding: 0.25rem 0.625rem;
  line-height: 1;
  z-index: 10;
}

.btn-editor-close:hover {
  color: var(--text);
  background: transparent;
  transform: none;
  box-shadow: none;
}
</style>
