import { API_BASE, authHeaders, setToken, removeToken, getToken } from './api.js'

export async function login(email_address, password) {
  const response = await fetch(`${API_BASE}/session`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email_address, password })
  })
  const data = await response.json()
  if (response.ok) setToken(data.token)
  return { ok: response.ok, data }
}

export async function register(email_address, password, password_confirmation) {
  const response = await fetch(`${API_BASE}/registration`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ user: { email_address, password, password_confirmation } })
  })
  const data = await response.json()
  if (response.ok) setToken(data.token)
  return { ok: response.ok, data }
}

export function logout() {
  const token = getToken()
  removeToken()
  if (token) {
    fetch(`${API_BASE}/session`, { method: 'DELETE', headers: authHeaders() })
  }
}
