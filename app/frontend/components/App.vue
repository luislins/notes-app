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

      <div v-if="showForm" class="modal-overlay" @click.self="showForm = false">
        <div class="modal">
          <div class="modal-header">
            <h2>Nova Anotação</h2>
            <button class="btn-modal-close" @click="showForm = false">&times;</button>
          </div>
          <NoteForm @created="onNoteCreated" />
        </div>
      </div>

      <NoteList ref="list" />
    </template>
    <AuthForm v-else @authenticated="onAuthenticated" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { isAuthenticated, logout } from '../services/api.js'
import AuthForm from './AuthForm.vue'
import NoteForm from './NoteForm.vue'
import NoteList from './NoteList.vue'

const authenticated = ref(false)
const showForm = ref(false)
const list = ref(null)

onMounted(() => {
  authenticated.value = isAuthenticated()
})

function onAuthenticated() {
  authenticated.value = true
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
  max-width: 780px;
  margin: 0 auto;
  padding: 3rem 1.5rem 4rem;
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

/* ── Note Form ── */

.note-form {
  background: var(--surface);
  padding: 1.75rem;
  border-radius: var(--radius);
  margin-bottom: 2.5rem;
  border: 1px solid var(--border);
  box-shadow: var(--shadow-sm);
  transition: box-shadow var(--transition);
}

.note-form:focus-within {
  box-shadow: var(--shadow-md);
  border-color: var(--border-focus);
}

/* ── Form Elements ── */

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
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 0.875rem;
}

.note-card {
  padding: 1.25rem 1.375rem;
  border-radius: var(--radius);
  border: none;
  box-shadow: var(--shadow-sm);
  transition: all var(--transition);
  animation: slideIn 400ms ease-out both;
  display: flex;
  flex-direction: column;
}

.note-card:nth-child(1) { animation-delay: 0ms; }
.note-card:nth-child(2) { animation-delay: 50ms; }
.note-card:nth-child(3) { animation-delay: 100ms; }
.note-card:nth-child(4) { animation-delay: 150ms; }
.note-card:nth-child(5) { animation-delay: 200ms; }
.note-card:nth-child(6) { animation-delay: 250ms; }

/* Card color variations */
.note-color-0 { background: #fdf0d5; }
.note-color-1 { background: #dce8d2; }
.note-color-2 { background: #f5ddd1; }
.note-color-3 { background: #d4e4ed; }
.note-color-4 { background: #f0e0ef; }
.note-color-5 { background: #e8e0d0; }

.note-card:hover {
  box-shadow: var(--shadow-lg);
  transform: translateY(-2px);
}

.note-card h3 {
  font-family: var(--font-display);
  font-size: 1.2rem;
  font-weight: 400;
  margin-bottom: 0.375rem;
  color: var(--text);
}

.note-card p {
  color: var(--text-secondary);
  margin-bottom: 0.5rem;
  font-size: 0.875rem;
  line-height: 1.5;
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
</style>
