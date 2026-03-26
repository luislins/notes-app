<template>
  <div class="note-editor-card" :style="cardStyle">
    <ul v-if="errors.length" class="editor-errors">
      <li v-for="error in errors" :key="error">{{ error }}</li>
    </ul>

    <div class="editor-category-select" ref="dropdownRef">
      <button class="category-select-trigger" @click="dropdownOpen = !dropdownOpen" type="button">
        <span v-if="selectedCategory" class="select-dot" :style="{ background: selectedCategory.color }" />
        <span v-else class="select-dot select-dot-empty" />
        <span>{{ selectedCategory ? selectedCategory.name : 'Sem categoria' }}</span>
        <span class="select-arrow">&#9662;</span>
      </button>
      <div v-if="dropdownOpen" class="category-dropdown">
        <button
          class="category-dropdown-item"
          :class="{ active: categoryId === null }"
          @click="categoryId = null; dropdownOpen = false"
          type="button"
        >
          <span class="select-dot select-dot-empty" />
          <span>Sem categoria</span>
        </button>
        <button
          v-for="cat in categories"
          :key="cat.id"
          class="category-dropdown-item"
          :class="{ active: categoryId === cat.id }"
          @click="categoryId = cat.id; dropdownOpen = false"
          type="button"
        >
          <span class="select-dot" :style="{ background: cat.color }" />
          <span>{{ cat.name }}</span>
        </button>
      </div>
    </div>

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
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { createNote, updateNote } from '../services/api.js'

const props = defineProps({
  categories: { type: Array, default: () => [] },
  note: { type: Object, default: null }
})

const emit = defineEmits(['saved'])

const isEditing = computed(() => !!props.note)

const title = ref('')
const content = ref('')
const categoryId = ref(null)
const errors = ref([])
const submitting = ref(false)
const titleInput = ref(null)
const dropdownRef = ref(null)
const dropdownOpen = ref(false)

function handleClickOutside(e) {
  if (dropdownRef.value && !dropdownRef.value.contains(e.target)) {
    dropdownOpen.value = false
  }
}

function handleKeydown(e) {
  if (e.key === 'Escape' && dropdownOpen.value) {
    dropdownOpen.value = false
    e.stopPropagation()
  }
}

const selectedCategory = computed(() =>
  props.categories.find(c => c.id === categoryId.value)
)

const cardStyle = computed(() => {
  if (selectedCategory.value) {
    return { background: selectedCategory.value.color }
  }
  return { background: isEditing.value ? '#f0ece6' : '#f5ddd1' }
})

onMounted(() => {
  if (props.note) {
    title.value = props.note.title
    content.value = props.note.content || ''
    categoryId.value = props.note.category?.id || null
  }
  titleInput.value?.focus()
  document.addEventListener('click', handleClickOutside)
  document.addEventListener('keydown', handleKeydown)
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleClickOutside)
  document.removeEventListener('keydown', handleKeydown)
})

async function handleSubmit() {
  errors.value = []

  if (!title.value.trim()) {
    errors.value = ['Título não pode ficar em branco']
    return
  }

  submitting.value = true

  try {
    const result = isEditing.value
      ? await updateNote(props.note.id, title.value, content.value, categoryId.value)
      : await createNote(title.value, content.value, categoryId.value)

    if (result.ok) {
      emit('saved')
    } else {
      errors.value = result.data.errors || ['Erro ao salvar anotação']
    }
  } catch {
    errors.value = ['Erro de conexão com o servidor']
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.note-editor-card {
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

.editor-category-select {
  position: relative;
  margin-bottom: 1.25rem;
  width: fit-content;
}

.category-select-trigger {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: rgba(255, 255, 255, 0.4);
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: var(--radius-sm);
  padding: 0.4rem 0.75rem;
  font-size: 0.8125rem;
  color: var(--text);
  cursor: pointer;
}

.category-select-trigger:hover {
  background: rgba(255, 255, 255, 0.6);
  transform: none;
  box-shadow: none;
}

.select-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  flex-shrink: 0;
}

.select-dot-empty {
  border: 1.5px dashed rgba(0, 0, 0, 0.2);
}

.select-arrow {
  font-size: 0.625rem;
  opacity: 0.5;
  margin-left: 0.25rem;
}

.category-dropdown {
  position: absolute;
  top: calc(100% + 4px);
  left: 0;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  box-shadow: var(--shadow-md);
  min-width: 180px;
  padding: 0.25rem;
  z-index: 10;
  animation: slideIn 150ms ease-out;
}

.category-dropdown-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  width: 100%;
  background: transparent;
  border: none;
  border-radius: 6px;
  padding: 0.5rem 0.75rem;
  font-size: 0.8125rem;
  color: var(--text);
  cursor: pointer;
  text-align: left;
}

.category-dropdown-item:hover {
  background: var(--bg);
  transform: none;
  box-shadow: none;
}

.category-dropdown-item.active {
  background: var(--accent-light);
  color: var(--accent);
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

.editor-footer {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  margin-top: 1.5rem;
  padding-top: 1rem;
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
</style>
