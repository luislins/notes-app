<template>
  <div class="note-editor-card" :style="cardStyle">
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
          @click="selectCategory(null)"
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
          @click="selectCategory(cat.id)"
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
      <span class="save-status" :class="saveStatusClass">{{ saveStatusText }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onBeforeUnmount } from 'vue'
import { updateNote } from '../services/api.js'

const props = defineProps({
  categories: { type: Array, default: () => [] },
  note: { type: Object, required: true }
})

const title = ref('')
const content = ref('')
const categoryId = ref(null)
const titleInput = ref(null)
const dropdownRef = ref(null)
const dropdownOpen = ref(false)

// Autosave state
const saveStatus = ref('saved') // 'saved' | 'saving' | 'idle'
let debounceTimer = null

const saveStatusText = computed(() => {
  if (saveStatus.value === 'saving') return 'Salvando...'
  if (saveStatus.value === 'saved') return 'Salvo'
  return ''
})

const saveStatusClass = computed(() => saveStatus.value)

const selectedCategory = computed(() =>
  props.categories.find(c => c.id === categoryId.value)
)

const cardStyle = computed(() => {
  if (selectedCategory.value) {
    return { background: selectedCategory.value.color }
  }
  return { background: '#f0ece6' }
})

function selectCategory(id) {
  categoryId.value = id
  dropdownOpen.value = false
  triggerAutosave()
}

function triggerAutosave() {
  saveStatus.value = 'idle'
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(autoSave, 500)
}

async function autoSave() {
  if (!props.note?.id) return

  saveStatus.value = 'saving'
  try {
    await updateNote(props.note.id, title.value, content.value, categoryId.value)
    saveStatus.value = 'saved'
  } catch {
    saveStatus.value = 'idle'
  }
}

// Watch text fields for changes
watch(title, () => triggerAutosave())
watch(content, () => triggerAutosave())

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

onMounted(() => {
  title.value = props.note.title === 'Sem título' ? '' : props.note.title
  content.value = props.note.content || ''
  categoryId.value = props.note.category?.id || null
  saveStatus.value = 'saved'

  titleInput.value?.focus()
  document.addEventListener('click', handleClickOutside)
  document.addEventListener('keydown', handleKeydown)
})

onBeforeUnmount(() => {
  clearTimeout(debounceTimer)
  // Save immediately on close if there are pending changes
  if (saveStatus.value === 'idle' && props.note?.id) {
    updateNote(props.note.id, title.value, content.value, categoryId.value)
  }
  document.removeEventListener('click', handleClickOutside)
  document.removeEventListener('keydown', handleKeydown)
})

defineExpose({
  get currentTitle() { return title.value }
})
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

.save-status {
  font-size: 0.75rem;
  color: var(--text-muted);
  transition: opacity var(--transition);
}

.save-status.saving {
  opacity: 0.7;
}

.save-status.saved {
  opacity: 0.5;
}

.save-status.idle {
  opacity: 0;
}
</style>
