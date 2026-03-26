export const API_BASE = import.meta.env.VITE_API_URL || ''

let onUnauthorized = null

export function setOnUnauthorized(callback) {
  onUnauthorized = callback
}

export function getToken() {
  return localStorage.getItem('token')
}

export function setToken(token) {
  localStorage.setItem('token', token)
}

export function removeToken() {
  localStorage.removeItem('token')
}

export function authHeaders() {
  const token = getToken()
  const headers = { 'Content-Type': 'application/json' }
  if (token) headers['Authorization'] = `Bearer ${token}`
  return headers
}

export function isAuthenticated() {
  return !!getToken()
}

export function handleResponse(response) {
  if (response.status === 401 && onUnauthorized) {
    removeToken()
    onUnauthorized()
  }
  return response
}
