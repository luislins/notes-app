import { API_BASE, authHeaders } from './api.js'

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
