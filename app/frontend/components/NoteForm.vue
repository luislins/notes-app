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
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleClickOutside)
})

async function handleSubmit() {
  errors.value = []
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
