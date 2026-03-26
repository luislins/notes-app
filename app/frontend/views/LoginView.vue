<template>
  <div class="login-container">
    <AuthForm @authenticated="onAuthenticated" />
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import AuthForm from '../components/AuthForm.vue'

const router = useRouter()

function onAuthenticated() {
  router.push({ name: 'notes' })
}
</script>

<style scoped>
.login-container {
  max-width: 960px;
  margin: 0 auto;
  padding: 3rem 2rem 4rem;
  animation: fadeIn 600ms ease-out;
}
</style>
