import { createRouter, createWebHashHistory } from 'vue-router'
import { isAuthenticated } from './services/api.js'
import LoginView from './views/LoginView.vue'
import NotesView from './views/NotesView.vue'
import NoteEditorView from './views/NoteEditorView.vue'

const routes = [
  { path: '/login', name: 'login', component: LoginView, meta: { guest: true } },
  { path: '/', name: 'notes', component: NotesView },
  { path: '/notes/:id', name: 'note-editor', component: NoteEditorView, props: true },
]

const router = createRouter({
  history: createWebHashHistory(),
  routes,
})

router.beforeEach((to) => {
  if (to.meta.guest) return true
  if (!isAuthenticated()) return { name: 'login' }
  return true
})

export default router
