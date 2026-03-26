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

// New category state
const showNewCategory = ref(false)
const newCategoryName = ref('')
const newCategoryColor = ref('#fdf0d5')
const catNameInput = ref(null)

watch(showNewCategory, (val) => {
  if (val) nextTick(() => catNameInput.value?.focus())
})

const filteredNotes = computed(() => {
  if (!filterCategoryId.value) return notes.value
  return notes.value.filter(n => n.category?.id === filterCategoryId.value)
})

function noteCardStyle(note) {
  if (note.category?.color) {
    return { background: note.category.color }
  }
  return { background: '#f0ece6' }
}

async function fetchNotes() {
  loading.value = true
  try {
    notes.value = await apiFetchNotes()
  } catch {
    notes.value = []
  } finally {
    loading.value = false
  }
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
    }
  } catch {
    // silently fail
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
    // silently fail
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
