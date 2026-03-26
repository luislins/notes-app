<template>
  <div class="auth-form">
    <h2>{{ isLogin ? 'Login' : 'Cadastro' }}</h2>

    <form @submit.prevent="handleSubmit">
      <div class="form-group">
        <label for="email">E-mail</label>
        <input id="email" v-model="email" type="email" placeholder="seu@email.com" />
      </div>

      <div class="form-group">
        <label for="password">Senha</label>
        <input id="password" v-model="password" type="password" placeholder="Sua senha" />
      </div>

      <div v-if="!isLogin" class="form-group">
        <label for="passwordConfirmation">Confirmar senha</label>
        <input id="passwordConfirmation" v-model="passwordConfirmation" type="password" placeholder="Confirme a senha" />
      </div>

      <ul v-if="errors.length" class="errors">
        <li v-for="error in errors" :key="error">{{ error }}</li>
      </ul>

      <button type="submit" :disabled="submitting">
        {{ submitting ? 'Aguarde...' : (isLogin ? 'Entrar' : 'Cadastrar') }}
      </button>
    </form>

    <p class="toggle">
      {{ isLogin ? 'Não tem conta?' : 'Já tem conta?' }}
      <a href="#" @click.prevent="toggleMode">{{ isLogin ? 'Cadastre-se' : 'Faça login' }}</a>
    </p>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { login, register } from '../services/api.js'

const emit = defineEmits(['authenticated'])

const isLogin = ref(true)
const email = ref('')
const password = ref('')
const passwordConfirmation = ref('')
const errors = ref([])
const submitting = ref(false)

function toggleMode() {
  isLogin.value = !isLogin.value
  errors.value = []
}

async function handleSubmit() {
  errors.value = []
  submitting.value = true

  try {
    const result = isLogin.value
      ? await login(email.value, password.value)
      : await register(email.value, password.value, passwordConfirmation.value)

    if (result.ok) {
      emit('authenticated', result.data.user)
    } else {
      errors.value = result.data.errors || ['Erro ao processar requisição']
    }
  } catch {
    errors.value = ['Erro de conexão com o servidor']
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.auth-form {
  background: var(--surface);
  padding: 2.5rem;
  border-radius: var(--radius);
  border: 1px solid var(--border);
  box-shadow: var(--shadow-md);
  animation: slideIn 500ms ease-out;
  max-width: 420px;
  margin: 0 auto;
}

.toggle {
  margin-top: 1.5rem;
  text-align: center;
  font-size: 0.875rem;
  color: var(--text-muted);
}

.toggle a {
  color: var(--accent);
  text-decoration: none;
  font-weight: 500;
  transition: color var(--transition);
}

.toggle a:hover {
  color: var(--accent-hover);
}

.form-group {
  margin-bottom: 1.25rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.375rem;
  font-weight: 500;
  font-size: 0.8125rem;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.form-group input {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  font-size: 0.9375rem;
  font-family: var(--font-body);
  color: var(--text);
  background: var(--surface);
  transition: border-color var(--transition), box-shadow var(--transition);
}

.form-group input::placeholder {
  color: var(--text-muted);
}

.form-group input:focus {
  outline: none;
  border-color: var(--border-focus);
  box-shadow: 0 0 0 3px var(--accent-light);
}

.errors {
  list-style: none;
  margin-bottom: 1rem;
  padding: 0.75rem 1rem;
  background: var(--danger-light);
  border: 1px solid rgba(192, 57, 43, 0.12);
  border-radius: var(--radius-sm);
  color: var(--danger);
  font-size: 0.8125rem;
  font-weight: 500;
}

.errors li + li {
  margin-top: 0.25rem;
}
</style>
