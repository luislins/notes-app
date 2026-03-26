<template>
  <div class="container">
    <template v-if="authenticated">
      <header class="app-header">
        <div class="app-brand">
          <span class="brand-icon">&#9998;</span>
          <h1>Anotações</h1>
        </div>
        <div class="header-actions">
          <button class="btn-new-note" @click="showForm = true">+ Nova Nota</button>
          <button class="btn-logout" @click="handleLogout">Sair</button>
        </div>
      </header>

      <div v-if="showForm" class="note-editor-overlay">
        <button class="btn-editor-close" @click="showForm = false">&times;</button>
        <NoteForm :categories="categories" @created="onNoteCreated" />
      </div>

      <NoteList ref="list" :categories="categories" @categories-changed="loadCategories" />
    </template>
    <AuthForm v-else @authenticated="onAuthenticated" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { isAuthenticated, logout, fetchCategories } from '../services/api.js'
import AuthForm from './AuthForm.vue'
import NoteForm from './NoteForm.vue'
import NoteList from './NoteList.vue'

const authenticated = ref(false)
const showForm = ref(false)
const list = ref(null)
const categories = ref([])

onMounted(() => {
  authenticated.value = isAuthenticated()
  if (authenticated.value) loadCategories()
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

function onNoteCreated() {
  showForm.value = false
  list.value.fetchNotes()
}

function handleLogout() {
  logout()
  authenticated.value = false
}
</script>

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

.container {
  max-width: 960px;
  margin: 0 auto;
  padding: 3rem 2rem 4rem;
  animation: fadeIn 600ms ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes slideIn {
  from { opacity: 0; transform: translateY(12px); }
  to { opacity: 1; transform: translateY(0); }
}

/* ── Header ── */

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

/* ── Auth Form ── */

.auth-form {
  background: var(--surface);
  padding: 2.5rem;
  border-radius: var(--radius);
  border: 1px solid var(--border);
  box-shadow: var(--shadow-md);
  animation: slideIn 500ms ease-out;
}

.auth-form .toggle {
  margin-top: 1.5rem;
  text-align: center;
  font-size: 0.875rem;
  color: var(--text-muted);
}

.auth-form .toggle a {
  color: var(--accent);
  text-decoration: none;
  font-weight: 500;
  transition: color var(--transition);
}

.auth-form .toggle a:hover {
  color: var(--accent-hover);
}

/* ── Form Elements (Auth) ── */

.form-group {
  margin-bottom: 1.25rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.375rem;
  font-weight: 500;
  font-size: 0.8125rem;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  font-size: 0.9375rem;
  font-family: var(--font-body);
  color: var(--text);
  background: var(--surface);
  transition: border-color var(--transition), box-shadow var(--transition);
}

.form-group input::placeholder,
.form-group textarea::placeholder {
  color: var(--text-muted);
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: var(--border-focus);
  box-shadow: 0 0 0 3px var(--accent-light);
}

.form-group textarea {
  resize: vertical;
  min-height: 5rem;
}

/* ── Buttons ── */

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

/* ── Note Editor (full page) ── */

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

.note-editor-card {
  background: #f5ddd1;
  border-radius: 16px;
  border: 1.5px solid rgba(0, 0, 0, 0.08);
  width: 100%;
  max-width: 720px;
  min-height: 70vh;
  margin-top: 2.5rem;
  padding: 2.5rem 3rem;
  display: flex;
  flex-direction: column;
  animation: slideIn 350ms ease-out;
}

.editor-errors {
  list-style: none;
  margin-bottom: 1rem;
  padding: 0.75rem 1rem;
  background: rgba(192, 57, 43, 0.08);
  border: 1px solid rgba(192, 57, 43, 0.15);
  border-radius: var(--radius-sm);
  color: var(--danger);
  font-size: 0.8125rem;
  font-weight: 500;
}

.editor-errors li + li {
  margin-top: 0.25rem;
}

.editor-title {
  font-family: var(--font-display);
  font-size: 2rem;
  font-weight: 400;
  color: var(--text);
  background: transparent;
  border: none;
  outline: none;
  width: 100%;
  margin-bottom: 0.75rem;
  padding: 0;
}

.editor-title::placeholder {
  color: rgba(44, 36, 24, 0.35);
}

.editor-content {
  font-family: var(--font-body);
  font-size: 1rem;
  color: var(--text);
  background: transparent;
  border: none;
  outline: none;
  width: 100%;
  flex-grow: 1;
  resize: none;
  line-height: 1.7;
  padding: 0;
}

.editor-content::placeholder {
  color: rgba(44, 36, 24, 0.3);
}

.btn-save {
  background: rgba(0, 0, 0, 0.7);
  color: #fff;
  padding: 0.5rem 1.5rem;
  border-radius: 20px;
  font-size: 0.875rem;
}

.btn-save:hover {
  background: rgba(0, 0, 0, 0.85);
}

/* ── Errors ── */

.errors {
  list-style: none;
  margin-bottom: 1rem;
  padding: 0.75rem 1rem;
  background: var(--danger-light);
  border: 1px solid rgba(192, 57, 43, 0.12);
  border-radius: var(--radius-sm);
  color: var(--danger);
  font-size: 0.8125rem;
  font-weight: 500;
}

.errors li + li {
  margin-top: 0.25rem;
}

/* ── Note List ── */

.note-list .empty {
  color: var(--text-muted);
  text-align: center;
  padding: 3rem 2rem;
  font-style: italic;
  font-family: var(--font-display);
  font-size: 1.125rem;
}

.notes-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1rem;
}

.note-card {
  padding: 1.5rem 1.5rem 1.25rem;
  border-radius: var(--radius);
  border: 1.5px solid rgba(0, 0, 0, 0.05);
  box-shadow: var(--shadow-sm);
  transition: all var(--transition);
  animation: slideIn 400ms ease-out both;
  display: flex;
  flex-direction: column;
  min-height: 180px;
}

.note-card:nth-child(1) { animation-delay: 0ms; }
.note-card:nth-child(2) { animation-delay: 50ms; }
.note-card:nth-child(3) { animation-delay: 100ms; }
.note-card:nth-child(4) { animation-delay: 150ms; }
.note-card:nth-child(5) { animation-delay: 200ms; }
.note-card:nth-child(6) { animation-delay: 250ms; }

.note-card:hover {
  box-shadow: var(--shadow-lg);
  transform: translateY(-2px);
}

.note-card h3 {
  font-family: var(--font-display);
  font-size: 1.3rem;
  font-weight: 400;
  margin-bottom: 0.5rem;
  color: var(--text);
}

.note-card p {
  color: var(--text-secondary);
  margin-bottom: 0.5rem;
  font-size: 0.9rem;
  line-height: 1.6;
  flex-grow: 1;
}

.note-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 0.625rem;
  padding-top: 0.625rem;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
}

.note-footer small {
  color: var(--text-muted);
  font-size: 0.6875rem;
  letter-spacing: 0.02em;
}

.actions {
  display: flex;
  gap: 0.375rem;
}

.btn-edit {
  background: rgba(255, 255, 255, 0.5);
  color: var(--text-secondary);
  padding: 0.25rem 0.625rem;
  font-size: 0.7rem;
  border: 1px solid rgba(0, 0, 0, 0.08);
}

.btn-edit:hover {
  background: rgba(255, 255, 255, 0.85);
  color: var(--accent);
  border-color: var(--accent);
  transform: none;
  box-shadow: none;
}

.btn-delete {
  background: transparent;
  color: var(--text-muted);
  padding: 0.25rem 0.625rem;
  font-size: 0.7rem;
  border: 1px solid transparent;
}

.btn-delete:hover {
  background: rgba(255, 255, 255, 0.5);
  color: var(--danger);
  border-color: rgba(192, 57, 43, 0.15);
  transform: none;
  box-shadow: none;
}

.btn-cancel {
  background: transparent;
  color: var(--text-secondary);
  padding: 0.3rem 0.75rem;
  font-size: 0.75rem;
  border: 1px solid var(--border);
}

.btn-cancel:hover {
  background: var(--surface-hover);
  transform: none;
  box-shadow: none;
}

/* ── Edit Form ── */

.edit-form input,
.edit-form textarea {
  width: 100%;
  padding: 0.625rem 0.875rem;
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  font-size: 0.9375rem;
  font-family: var(--font-body);
  color: var(--text);
  background: var(--surface);
  margin-bottom: 0.5rem;
  transition: border-color var(--transition), box-shadow var(--transition);
}

.edit-form input:focus,
.edit-form textarea:focus {
  outline: none;
  border-color: var(--border-focus);
  box-shadow: 0 0 0 3px var(--accent-light);
}

.edit-form .actions {
  margin-top: 0.25rem;
}

/* ── Categories Bar ── */

.categories-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
}

.category-chip {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  background: var(--surface);
  color: var(--text-secondary);
  border: 1px solid var(--border);
  padding: 0.375rem 0.875rem;
  border-radius: 20px;
  font-size: 0.8125rem;
  font-weight: 500;
  cursor: pointer;
}

.category-chip:hover {
  background: var(--surface-hover);
  border-color: var(--border-focus);
  transform: none;
  box-shadow: none;
}

.category-chip.active {
  background: var(--accent-light);
  border-color: var(--accent);
  color: var(--accent);
}

.category-chip.active:hover {
  background: var(--accent-light);
}

.category-chip.add-chip {
  border-style: dashed;
  color: var(--text-muted);
}

.category-chip.add-chip:hover {
  color: var(--accent);
  border-color: var(--accent);
}

.chip-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  flex-shrink: 0;
}

.chip-remove {
  font-size: 1rem;
  line-height: 1;
  margin-left: 0.125rem;
  opacity: 0;
  transition: opacity var(--transition);
}

.category-chip:hover .chip-remove {
  opacity: 0.6;
}

.chip-remove:hover {
  opacity: 1 !important;
  color: var(--danger);
}

/* ── New Category Form ── */

.new-category-form {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 1.25rem;
  margin-bottom: 1.5rem;
  animation: slideIn 250ms ease-out;
}

.cat-input {
  width: 100%;
  padding: 0.5rem 0.75rem;
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  font-size: 0.875rem;
  font-family: var(--font-body);
  color: var(--text);
  background: var(--bg);
  margin-bottom: 0.75rem;
}

.cat-input:focus {
  outline: none;
  border-color: var(--border-focus);
}

.color-picker-row {
  display: flex;
  align-items: center;
  gap: 0.625rem;
  margin-bottom: 0.75rem;
}

.color-picker-label {
  font-size: 0.8125rem;
  font-weight: 500;
  color: var(--text-secondary);
}

.color-picker-input {
  width: 36px;
  height: 36px;
  border: 1px solid var(--border);
  border-radius: 50%;
  padding: 2px;
  cursor: pointer;
  background: none;
}

.color-picker-input::-webkit-color-swatch-wrapper {
  padding: 0;
}

.color-picker-input::-webkit-color-swatch {
  border: none;
  border-radius: 50%;
}

.color-picker-input::-moz-color-swatch {
  border: none;
  border-radius: 50%;
}

/* ── Category Picker (Editor) ── */

.editor-category-picker {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1.25rem;
  flex-wrap: wrap;
}

.category-dot {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  border: 2px solid transparent;
  padding: 0;
  cursor: pointer;
  transition: all var(--transition);
}

.category-dot:hover {
  transform: scale(1.2);
  box-shadow: none;
}

.category-dot.active {
  border-color: var(--text);
  transform: scale(1.2);
}

.category-dot.no-category {
  background: var(--bg);
  border: 2px dashed var(--border);
}

.category-dot.no-category.active {
  border-color: var(--text);
  border-style: solid;
}

/* ── Note Category Label ── */

.note-category-label {
  font-size: 0.6875rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: rgba(44, 36, 24, 0.45);
  margin-bottom: 0.375rem;
}

.editor-category-label {
  font-size: 0.8125rem;
  color: var(--text-muted);
  font-weight: 500;
}

.editor-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1.5rem;
  padding-top: 1rem;
}
</style>
