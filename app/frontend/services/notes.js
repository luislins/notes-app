import { API_BASE, authHeaders, handleResponse } from './api.js'

export async function fetchNotes(page = 1, perPage = 12) {
  const response = handleResponse(await fetch(`${API_BASE}/api/notes?page=${page}&per_page=${perPage}`, { headers: authHeaders() }))
  if (!response.ok) throw new Error('unauthorized')
  return response.json()
}

export async function fetchNote(id) {
  const response = handleResponse(await fetch(`${API_BASE}/api/notes/${id}`, { headers: authHeaders() }))
  if (!response.ok) throw new Error('unauthorized')
  return response.json()
}

export async function createNote(title, content, category_id) {
  const response = handleResponse(await fetch(`${API_BASE}/api/notes`, {
    method: 'POST',
    headers: authHeaders(),
    body: JSON.stringify({ note: { title, content, category_id } })
  }))
  const data = await response.json()
  return { ok: response.ok, data }
}

export async function updateNote(id, title, content, category_id) {
  const response = handleResponse(await fetch(`${API_BASE}/api/notes/${id}`, {
    method: 'PATCH',
    headers: authHeaders(),
    body: JSON.stringify({ note: { title, content, category_id } })
  }))
  const data = await response.json()
  return { ok: response.ok, data }
}

export async function deleteNote(id) {
  const response = handleResponse(await fetch(`${API_BASE}/api/notes/${id}`, {
    method: 'DELETE',
    headers: authHeaders()
  }))
  return { ok: response.ok }
}
