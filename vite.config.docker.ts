import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  root: 'app/frontend',
  server: {
    host: '0.0.0.0',
    port: 3036,
    proxy: {
      '/api': 'http://web:5100',
      '/session': 'http://web:5100',
      '/registration': 'http://web:5100',
    },
  },
})
