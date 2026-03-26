import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import vue from '@vitejs/plugin-vue'

const railsPort = process.env.RAILS_PORT || '5100'
const railsUrl = `http://localhost:${railsPort}`

export default defineConfig({
  plugins: [RubyPlugin(), vue()],
  root: 'app/frontend',
  server: {
    port: 3036,
    proxy: {
      '/api': railsUrl,
      '/session': railsUrl,
      '/registration': railsUrl,
    },
  },
})
