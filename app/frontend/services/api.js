const API_BASE = import.meta.env.VITE_API_URL || ''

function getToken() {
  return localStorage.getItem('token')
}

function authHeaders() {
  const token = getToken()
  const headers = { 'Content-Type': 'application/json' }
  if (token) headers['Authorization'] = `Bearer ${token}`
  return headers
}

export async function login(email_address, password) {
  const response = await fetch(`${API_BASE}/session`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email_address, password })
  })
  const data = await response.json()
  if (response.ok) localStorage.setItem('token', data.token)
  return { ok: response.ok, data }
}

export async function register(email_address, password, password_confirmation) {
  const response = await fetch(`${API_BASE}/registration`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ user: { email_address, password, password_confirmation } })
  })
  const data = await response.json()
  if (response.ok) localStorage.setItem('token', data.token)
  return { ok: response.ok, data }
}

export function logout() {
  const token = getToken()
  localStorage.removeItem('token')
  if (token) {
    fetch(`${API_BASE}/session`, { method: 'DELETE', headers: authHeaders() })
  }
}

export function isAuthenticated() {
  return !!getToken()
}

export async function fetchNotes() {
  const response = await fetch(`${API_BASE}/api/notes`, { headers: authHeaders() })
  if (response.status === 401) throw new Error('unauthorized')
  return response.json()
}

export async function createNote(title, content, category_id) {
  const response = await fetch(`${API_BASE}/api/notes`, {
    method: 'POST',
    headers: authHeaders(),
    body: JSON.stringify({ note: { title, content, category_id } })
  })
  const data = await response.json()
  return { ok: response.ok, data }
}

export async function updateNote(id, title, content, category_id) {
  const response = await fetch(`${API_BASE}/api/notes/${id}`, {
    method: 'PATCH',
    headers: authHeaders(),
    body: JSON.stringify({ note: { title, content, category_id } })
  })
  const data = await response.json()
  return { ok: response.ok, data }
}

// Categories

export async function fetchCategories() {
  const response = await fetch(`${API_BASE}/api/categories`, { headers: authHeaders() })
  return response.json()
}

export async function createCategory(name, color) {
  const response = await fetch(`${API_BASE}/api/categories`, {
    method: 'POST',
    headers: authHeaders(),
    body: JSON.stringify({ category: { name, color } })
  })
  const data = await response.json()
  return { ok: response.ok, data }
}

export async function deleteCategory(id) {
  const response = await fetch(`${API_BASE}/api/categories/${id}`, {
    method: 'DELETE',
    headers: authHeaders()
  })
  return { ok: response.ok }
}

export async function deleteNote(id) {
  const response = await fetch(`${API_BASE}/api/notes/${id}`, {
    method: 'DELETE',
    headers: authHeaders()
  })
  return { ok: response.ok }
}
