<template>
  <div class="editor-view">
    <button class="btn-back" @click="goBack">&times;</button>

    <p v-if="loading" class="loading-text">Carregando...</p>
    <NoteForm v-else-if="note" ref="noteForm" :categories="categories" :note="note" />
    <p v-else class="loading-text">Nota não encontrada.</p>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { fetchNote, deleteNote } from '../services/notes.js'
import { fetchCategories } from '../services/categories.js'
import NoteForm from '../components/NoteForm.vue'

const router = useRouter()
const route = useRoute()

const note = ref(null)
const categories = ref([])
const loading = ref(true)
const noteForm = ref(null)

async function loadData() {
  loading.value = true
  try {
    const [noteData, categoriesData] = await Promise.all([
      fetchNote(route.params.id),
      fetchCategories()
    ])
    note.value = noteData
    categories.value = categoriesData
  } catch {
    note.value = null
  } finally {
    loading.value = false
  }
}

async function goBack() {
  const currentTitle = noteForm.value?.currentTitle
  if (note.value && !currentTitle?.trim()) {
    await deleteNote(note.value.id)
  }
  router.push({ name: 'notes' })
}

function handleKeydown(e) {
  if (e.key === 'Escape' && !e.defaultPrevented) {
    goBack()
  }
}

onMounted(() => {
  loadData()
  document.addEventListener('keydown', handleKeydown)
})

onBeforeUnmount(() => {
  document.removeEventListener('keydown', handleKeydown)
})
</script>

<style scoped>
.editor-view {
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

.btn-back {
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

.btn-back:hover {
  color: var(--text);
  background: transparent;
  transform: none;
  box-shadow: none;
}

.loading-text {
  color: var(--text-muted);
  font-style: italic;
  font-family: var(--font-display);
  font-size: 1.125rem;
  margin-top: 30vh;
}
</style>
