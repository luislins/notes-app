import { API_BASE, authHeaders, handleResponse } from './api.js'

export async function fetchCategories() {
  const response = handleResponse(await fetch(`${API_BASE}/api/categories`, { headers: authHeaders() }))
  if (!response.ok) throw new Error('unauthorized')
  return response.json()
}

export async function createCategory(name, color) {
  const response = handleResponse(await fetch(`${API_BASE}/api/categories`, {
    method: 'POST',
    headers: authHeaders(),
    body: JSON.stringify({ category: { name, color } })
  }))
  const data = await response.json()
  return { ok: response.ok, data }
}

export async function deleteCategory(id) {
  const response = handleResponse(await fetch(`${API_BASE}/api/categories/${id}`, {
    method: 'DELETE',
    headers: authHeaders()
  }))
  return { ok: response.ok }
}
