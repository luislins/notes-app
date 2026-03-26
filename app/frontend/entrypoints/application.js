import { createApp } from 'vue'
import App from '../components/App.vue'
import router from '../router.js'
import { setOnUnauthorized } from '../services/api.js'

const app = createApp(App)
app.use(router)

setOnUnauthorized(() => {
  router.push({ name: 'login' })
})

app.mount('#app')
