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
