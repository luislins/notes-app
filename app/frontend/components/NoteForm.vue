<template>
  <div class="note-editor-card" :style="cardStyle">
    <ul v-if="errors.length" class="editor-errors">
      <li v-for="error in errors" :key="error">{{ error }}</li>
    </ul>

    <div class="editor-category-picker">
      <button
        v-for="cat in categories"
        :key="cat.id"
        class="category-dot"
        :class="{ active: categoryId === cat.id }"
        :style="{ background: cat.color }"
        :title="cat.name"
        @click="categoryId = categoryId === cat.id ? null : cat.id"
      />
      <button
        class="category-dot no-category"
        :class="{ active: categoryId === null }"
        title="Sem categoria"
        @click="categoryId = null"
      />
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
      <span v-if="selectedCategory" class="editor-category-label">
        {{ selectedCategory.name }}
      </span>
      <button class="btn-save" :disabled="submitting" @click="handleSubmit">
        {{ submitting ? 'Salvando...' : 'Salvar' }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { createNote } from '../services/api.js'

const props = defineProps({
  categories: { type: Array, default: () => [] }
})

const emit = defineEmits(['created'])

const title = ref('')
const content = ref('')
const categoryId = ref(null)
const errors = ref([])
const submitting = ref(false)
const titleInput = ref(null)

const selectedCategory = computed(() =>
  props.categories.find(c => c.id === categoryId.value)
)

const cardStyle = computed(() => {
  if (selectedCategory.value) {
    return { background: selectedCategory.value.color }
  }
  return { background: '#f5ddd1' }
})

onMounted(() => {
  titleInput.value?.focus()
})

async function handleSubmit() {
  errors.value = []
  submitting.value = true

  try {
    const result = await createNote(title.value, content.value, categoryId.value)

    if (result.ok) {
      title.value = ''
      content.value = ''
      categoryId.value = null
      emit('created')
    } else {
      errors.value = result.data.errors || ['Erro ao criar anotação']
    }
  } catch {
    errors.value = ['Erro de conexão com o servidor']
  } finally {
    submitting.value = false
  }
}
</script>
