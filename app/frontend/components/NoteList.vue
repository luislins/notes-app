<template>
  <div class="note-list">
    <!-- Category manager -->
    <div class="categories-bar">
      <button
        class="category-chip"
        :class="{ active: !filterCategoryId }"
        @click="filterCategoryId = null"
      >
        Todas
      </button>
      <button
        v-for="cat in categories"
        :key="cat.id"
        class="category-chip"
        :class="{ active: filterCategoryId === cat.id }"
        @click="filterCategoryId = filterCategoryId === cat.id ? null : cat.id"
      >
        <span class="chip-dot" :style="{ background: cat.color }" />
        {{ cat.name }}
        <span class="chip-remove" @click.stop="handleDeleteCategory(cat.id)" title="Remover">&times;</span>
      </button>
      <button class="category-chip add-chip" @click="showNewCategory = true">
        + Categoria
      </button>
    </div>

    <!-- New category modal -->
    <div v-if="showNewCategory" class="modal-overlay" @click.self="showNewCategory = false">
      <div class="modal">
        <div class="modal-header">
          <h2>Nova Categoria</h2>
          <button class="btn-modal-close" @click="showNewCategory = false">&times;</button>
        </div>
        <input
          ref="catNameInput"
          v-model="newCategoryName"
          type="text"
          placeholder="Nome da categoria"
          class="cat-input"
          @keydown.enter="handleCreateCategory"
        />
        <div class="color-picker-row">
          <label class="color-picker-label">Cor</label>
          <input type="color" v-model="newCategoryColor" class="color-picker-input" />
        </div>
        <div class="modal-actions">
          <button class="btn-cancel" @click="showNewCategory = false">Cancelar</button>
          <button @click="handleCreateCategory" :disabled="!newCategoryName.trim()">Criar</button>
        </div>
      </div>
    </div>

    <!-- Notes grid -->
    <p v-if="loading" class="empty">Carregando...</p>
    <p v-else-if="filteredNotes.length === 0" class="empty">Nenhuma anotação encontrada.</p>
    <div v-else class="notes-grid">
      <div
        v-for="note in filteredNotes"
        :key="note.id"
        class="note-card"
        :class="{ 'note-card-dark': isDarkColor(note.category?.color) }"
        :style="noteCardStyle(note)"
      >
        <div v-if="note.category" class="note-category-label">{{ note.category.name }}</div>
        <h3>{{ note.title }}</h3>
        <p v-if="note.content">{{ note.content }}</p>
        <div class="note-footer">
          <small>{{ formatDate(note.created_at) }}</small>
          <div class="actions">
            <button class="btn-edit" @click="emit('edit', note)">Editar</button>
            <button class="btn-delete" @click="handleDelete(note.id)">Excluir</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Pagination -->
    <div v-if="meta.total_pages > 1" class="pagination">
      <button
        class="btn-page"
        :disabled="meta.page <= 1"
        @click="goToPage(meta.page - 1)"
      >
        &laquo; Anterior
      </button>
      <span class="page-info">{{ meta.page }} / {{ meta.total_pages }}</span>
      <button
        class="btn-page"
        :disabled="meta.page >= meta.total_pages"
        @click="goToPage(meta.page + 1)"
      >
        Próxima &raquo;
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick, watch } from 'vue'
import { fetchNotes as apiFetchNotes, deleteNote, createCategory, deleteCategory } from '../services/api.js'

const props = defineProps({
  categories: { type: Array, default: () => [] }
})

const emit = defineEmits(['categories-changed', 'edit'])

const notes = ref([])
const loading = ref(true)
const filterCategoryId = ref(null)
const meta = ref({ page: 1, per_page: 12, total: 0, total_pages: 1 })

// New category state
const showNewCategory = ref(false)
const newCategoryName = ref('')
const newCategoryColor = ref('#fdf0d5')
const catNameInput = ref(null)

function handleKeydown(e) {
  if (e.key === 'Escape' && showNewCategory.value) {
    showNewCategory.value = false
  }
}

watch(showNewCategory, (val) => {
  if (val) {
    nextTick(() => catNameInput.value?.focus())
    document.addEventListener('keydown', handleKeydown)
  } else {
    document.removeEventListener('keydown', handleKeydown)
  }
})

const filteredNotes = computed(() => {
  if (!filterCategoryId.value) return notes.value
  return notes.value.filter(n => n.category?.id === filterCategoryId.value)
})

function isDarkColor(hex) {
  if (!hex) return false
  const c = hex.replace('#', '')
  const r = parseInt(c.substring(0, 2), 16)
  const g = parseInt(c.substring(2, 4), 16)
  const b = parseInt(c.substring(4, 6), 16)
  const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
  return luminance < 0.55
}

function noteCardStyle(note) {
  if (note.category?.color) {
    return { background: note.category.color }
  }
  return { background: '#f0ece6' }
}

async function fetchNotes(page = 1) {
  loading.value = true
  try {
    const data = await apiFetchNotes(page)
    notes.value = data.notes
    meta.value = data.meta
  } catch {
    notes.value = []
  } finally {
    loading.value = false
  }
}

function goToPage(page) {
  fetchNotes(page)
}

async function handleDelete(id) {
  if (!confirm('Tem certeza que deseja excluir esta anotação?')) return

  try {
    await deleteNote(id)
    await fetchNotes()
  } catch {
    alert('Erro ao excluir anotação')
  }
}

async function handleCreateCategory() {
  if (!newCategoryName.value.trim()) return
  try {
    const result = await createCategory(newCategoryName.value, newCategoryColor.value)
    if (result.ok) {
      newCategoryName.value = ''
      newCategoryColor.value = '#fdf0d5'
      showNewCategory.value = false
      emit('categories-changed')
    } else {
      alert(result.data.errors?.join(', ') || 'Erro ao criar categoria')
    }
  } catch {
    alert('Erro de conexão com o servidor')
  }
}

async function handleDeleteCategory(id) {
  if (!confirm('Remover esta categoria? As notas serão mantidas.')) return
  try {
    await deleteCategory(id)
    if (filterCategoryId.value === id) filterCategoryId.value = null
    emit('categories-changed')
    await fetchNotes()
  } catch {
    alert('Erro ao remover categoria')
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

<style scoped>
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

/* ── Modal ── */

.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(44, 36, 24, 0.3);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: flex-start;
  justify-content: center;
  padding-top: 15vh;
  z-index: 100;
  animation: fadeIn 200ms ease-out;
}

.modal {
  background: var(--surface);
  border-radius: var(--radius);
  box-shadow: var(--shadow-lg), 0 0 0 1px var(--border);
  width: 100%;
  max-width: 400px;
  padding: 2rem;
  animation: slideIn 300ms ease-out;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.25rem;
}

.modal-header h2 {
  margin-bottom: 0;
}

.btn-modal-close {
  background: transparent;
  color: var(--text-muted);
  font-size: 1.5rem;
  padding: 0.25rem 0.5rem;
  line-height: 1;
}

.btn-modal-close:hover {
  color: var(--text);
  background: transparent;
  transform: none;
  box-shadow: none;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  margin-top: 0.25rem;
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

/* ── Notes Grid ── */

.empty {
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

.note-category-label {
  font-size: 0.6875rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: rgba(44, 36, 24, 0.45);
  margin-bottom: 0.375rem;
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
  color: var(--text-secondary);
  font-size: 0.6875rem;
  letter-spacing: 0.02em;
}

.actions {
  display: flex;
  gap: 0.375rem;
}

.btn-edit {
  background: rgba(255, 255, 255, 0.5);
  color: var(--text);
  padding: 0.25rem 0.625rem;
  font-size: 0.7rem;
  border: 1px solid rgba(0, 0, 0, 0.12);
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
  color: var(--text-secondary);
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

/* ── Dark card variant ── */

.note-card-dark h3 {
  color: #fff;
}

.note-card-dark p {
  color: rgba(255, 255, 255, 0.75);
}

.note-card-dark .note-category-label {
  color: rgba(255, 255, 255, 0.5);
}

.note-card-dark .note-footer {
  border-top-color: rgba(255, 255, 255, 0.15);
}

.note-card-dark .note-footer small {
  color: rgba(255, 255, 255, 0.5);
}

.note-card-dark .btn-edit {
  background: rgba(255, 255, 255, 0.15);
  color: rgba(255, 255, 255, 0.8);
  border-color: rgba(255, 255, 255, 0.2);
}

.note-card-dark .btn-edit:hover {
  background: rgba(255, 255, 255, 0.25);
  color: #fff;
  border-color: rgba(255, 255, 255, 0.4);
}

.note-card-dark .btn-delete {
  color: rgba(255, 255, 255, 0.5);
}

.note-card-dark .btn-delete:hover {
  background: rgba(255, 255, 255, 0.15);
  color: #ff9e9e;
  border-color: rgba(255, 255, 255, 0.2);
}

/* ── Pagination ── */

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1rem;
  margin-top: 2rem;
  padding-top: 1.5rem;
  border-top: 1px solid var(--border);
}

.btn-page {
  background: var(--surface);
  color: var(--text-secondary);
  border: 1px solid var(--border);
  padding: 0.4rem 1rem;
  border-radius: var(--radius-sm);
  font-size: 0.8125rem;
}

.btn-page:hover:not(:disabled) {
  background: var(--surface-hover);
  border-color: var(--border-focus);
  transform: none;
  box-shadow: none;
}

.btn-page:disabled {
  opacity: 0.35;
  background: var(--surface);
}

.page-info {
  font-size: 0.8125rem;
  color: var(--text-muted);
  font-weight: 500;
}
</style>
