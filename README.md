# Notes App

Sistema de anotações pessoais com categorias, desenvolvido com Ruby on Rails (API) e Vue.js.

## Tecnologias

- **Backend:** Ruby 3.3.2, Rails 8.1 (API mode)
- **Frontend:** Vue 3 (Composition API), Vue Router, Vite
- **Banco de dados:** PostgreSQL
- **Autenticação:** Token Bearer (bcrypt + has_secure_password)
- **Testes:** Minitest (60 testes)
- **i18n:** pt-BR

## Funcionalidades

- Cadastro e login de usuários
- CRUD completo de anotações (criar, listar, editar, excluir)
- Categorias com cores personalizadas
- Filtro de anotações por categoria
- Editor fullscreen com autosave (debounce de 500ms)
- Paginação na listagem de notas
- Navegação SPA com Vue Router (voltar/avançar do navegador)
- Validações no backend e frontend
- Adaptação visual automática para categorias com cores escuras

## Pré-requisitos

- Ruby 3.3.2
- Node.js 20+
- PostgreSQL
- Bundler (`gem install bundler`)
- Foreman (`gem install foreman`)

## Instalação

```bash
git clone <url-do-repositorio>
cd notes-app

# Instalar dependências
bundle install
npm install

# Criar e migrar o banco de dados
bin/rails db:create db:migrate

# (Opcional) Popular com dados de demonstração
bin/rails db:seed
# Usuário: demo@email.com / Senha: 12345678
```

## Executando o projeto

```bash
bin/dev
```

Isso inicia os dois servidores:

- **Rails API:** http://localhost:5100
- **Vue (Vite):** http://localhost:3036

Acesse o frontend em **http://localhost:3036**.

## Testes

```bash
bin/rails test
```

## Estrutura do projeto

```
app/
├── controllers/
│   ├── api/
│   │   ├── notes_controller.rb       # CRUD de anotações (com paginação)
│   │   └── categories_controller.rb  # CRUD de categorias
│   ├── sessions_controller.rb        # Login
│   ├── registrations_controller.rb   # Cadastro
│   └── concerns/
│       └── authentication.rb         # Autenticação via Bearer token
├── models/
│   ├── user.rb                       # Usuário com validações
│   ├── note.rb                       # Anotação (título, conteúdo, categoria)
│   └── category.rb                   # Categoria (nome, cor hex)
└── frontend/
    ├── views/
    │   ├── LoginView.vue             # Tela de login/cadastro
    │   ├── NotesView.vue             # Listagem de notas
    │   └── NoteEditorView.vue        # Editor fullscreen
    ├── components/
    │   ├── App.vue                   # Layout raiz (router-view)
    │   ├── AuthForm.vue              # Formulário de login e cadastro
    │   ├── NoteForm.vue              # Editor de nota com autosave
    │   └── NoteList.vue              # Grid de notas e categorias
    ├── services/
    │   ├── api.js                    # Base (token, headers)
    │   ├── auth.js                   # Login, registro, logout
    │   ├── notes.js                  # CRUD de notas
    │   └── categories.js             # CRUD de categorias
    ├── router.js                     # Rotas da aplicação
    └── entrypoints/
        └── application.js            # Entry point do Vue
```

## API

### Autenticação

| Método | Endpoint        | Descrição           |
|--------|----------------|---------------------|
| POST   | /registration  | Cadastro de usuário |
| POST   | /session       | Login               |
| DELETE | /session       | Logout              |

### Anotações (requer autenticação)

| Método | Endpoint         | Descrição               |
|--------|-----------------|-------------------------|
| GET    | /api/notes      | Lista anotações (paginado) |
| GET    | /api/notes/:id  | Exibe uma anotação      |
| POST   | /api/notes      | Cria uma anotação       |
| PATCH  | /api/notes/:id  | Atualiza uma anotação   |
| DELETE | /api/notes/:id  | Exclui uma anotação     |

### Categorias (requer autenticação)

| Método | Endpoint              | Descrição               |
|--------|-----------------------|-------------------------|
| GET    | /api/categories      | Lista categorias        |
| POST   | /api/categories      | Cria uma categoria      |
| PATCH  | /api/categories/:id  | Atualiza uma categoria  |
| DELETE | /api/categories/:id  | Exclui uma categoria    |

### Exemplos

**Criar anotação:**
```json
POST /api/notes
Authorization: Bearer <token>

{
  "note": {
    "title": "Título da anotação",
    "content": "Conteúdo opcional",
    "category_id": 1
  }
}
```

**Resposta (201):**
```json
{
  "id": 1,
  "title": "Título da anotação",
  "content": "Conteúdo opcional",
  "category_id": 1,
  "created_at": "2026-03-25T14:00:00.000Z",
  "updated_at": "2026-03-25T14:00:00.000Z",
  "category": {
    "id": 1,
    "name": "Trabalho",
    "color": "#4a90d9"
  }
}
```

**Listagem paginada:**
```
GET /api/notes?page=1&per_page=12
```
```json
{
  "notes": [...],
  "meta": {
    "page": 1,
    "per_page": 12,
    "total": 20,
    "total_pages": 2
  }
}
```

**Erro de validação (422):**
```json
{
  "errors": ["Título não pode ficar em branco"]
}
```

## Decisões técnicas

- **Rails API mode:** separação clara entre backend e frontend, comunicação via HTTP/JSON.
- **Vue 3 com Composition API:** código conciso com `<script setup>` e `<style scoped>` por componente.
- **Vue Router (hash mode):** navegação SPA com suporte a botão voltar/avançar. Hash mode escolhido por compatibilidade com backend API-only sem necessidade de fallback no servidor.
- **Autosave com debounce:** ao abrir "Nova Nota", a nota é criada imediatamente no banco. Alterações são salvas automaticamente com debounce de 500ms, sem botão de salvar. Notas sem título são removidas ao fechar o editor.
- **Vite + vite-plugin-ruby:** build rápido com HMR no desenvolvimento e proxy para a API Rails.
- **Services separados por domínio:** camada de API organizada em `api.js` (base), `auth.js`, `notes.js` e `categories.js`.
- **Autenticação por token:** `has_secure_password` com Bearer token armazenado no localStorage.
- **Categorias com cores:** usuário escolhe qualquer cor via color picker nativo; cards adaptam texto para cores escuras usando cálculo de luminância.
- **Paginação:** implementada sem gems externas, usando `limit`/`offset` do ActiveRecord com metadados de paginação no JSON.
- **i18n pt-BR:** todas as mensagens de validação e erro em português, centralizadas em `config/locales/pt-BR.yml`.
- **Testes de integração:** 60 testes cobrindo models (validações, associações) e controllers (CRUD, autorização, isolamento entre usuários).
