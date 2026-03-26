# Notes App

Sistema de anotações pessoais com categorias, desenvolvido com Ruby on Rails (API) e Vue.js.

## Tecnologias

- **Backend:** Ruby 3.3.2, Rails 8.1 (API mode)
- **Frontend:** Vue 3 (Composition API), Vite
- **Banco de dados:** PostgreSQL
- **Autenticação:** Token Bearer (bcrypt + has_secure_password)
- **Testes:** Minitest
- **i18n:** pt-BR

## Funcionalidades

- Cadastro e login de usuários
- CRUD completo de anotações (criar, listar, editar, excluir)
- Categorias com cores personalizadas
- Filtro de anotações por categoria
- Validações no backend e frontend
- Editor fullscreen para criação e edição de notas
- Adaptação visual automática para categorias com cores escuras

## Pré-requisitos

- Ruby 3.3.2
- Node.js 20+
- PostgreSQL
- Bundler (`gem install bundler`)
- Foreman (`gem install foreman`)

## Instalacao

```bash
git clone <url-do-repositorio>
cd notes-app

# Instalar dependencias
bundle install
npm install

# Criar e migrar o banco de dados
bin/rails db:create db:migrate
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
│   │   ├── notes_controller.rb       # CRUD de anotacoes
│   │   └── categories_controller.rb  # CRUD de categorias
│   ├── sessions_controller.rb        # Login
│   ├── registrations_controller.rb   # Cadastro
│   └── concerns/
│       └── authentication.rb         # Autenticacao via Bearer token
├── models/
│   ├── user.rb                       # Usuario com validacoes
│   ├── note.rb                       # Anotacao (titulo, conteudo, categoria)
│   └── category.rb                   # Categoria (nome, cor hex)
└── frontend/
    ├── components/
    │   ├── App.vue                   # Layout principal
    │   ├── AuthForm.vue              # Login e cadastro
    │   ├── NoteForm.vue              # Editor fullscreen de notas
    │   └── NoteList.vue              # Grid de notas e categorias
    ├── services/
    │   └── api.js                    # Camada de comunicacao com a API
    └── entrypoints/
        └── application.js            # Entry point do Vue
```

## API

### Autenticacao

| Metodo | Endpoint        | Descricao           |
|--------|----------------|---------------------|
| POST   | /registration  | Cadastro de usuario |
| POST   | /session       | Login               |
| DELETE | /session       | Logout              |

### Anotacoes (requer autenticacao)

| Metodo | Endpoint         | Descricao               |
|--------|-----------------|-------------------------|
| GET    | /api/notes      | Lista anotacoes         |
| GET    | /api/notes/:id  | Exibe uma anotacao      |
| POST   | /api/notes      | Cria uma anotacao       |
| PATCH  | /api/notes/:id  | Atualiza uma anotacao   |
| DELETE | /api/notes/:id  | Exclui uma anotacao     |

### Categorias (requer autenticacao)

| Metodo | Endpoint              | Descricao               |
|--------|-----------------------|-------------------------|
| GET    | /api/categories      | Lista categorias        |
| POST   | /api/categories      | Cria uma categoria      |
| PATCH  | /api/categories/:id  | Atualiza uma categoria  |
| DELETE | /api/categories/:id  | Exclui uma categoria    |

### Exemplos

**Criar anotacao:**
```json
POST /api/notes
Authorization: Bearer <token>

{
  "note": {
    "title": "Titulo da anotacao",
    "content": "Conteudo opcional",
    "category_id": 1
  }
}
```

**Resposta (201):**
```json
{
  "id": 1,
  "title": "Titulo da anotacao",
  "content": "Conteudo opcional",
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

**Erro de validacao (422):**
```json
{
  "errors": ["Titulo nao pode ficar em branco"]
}
```

## Decisoes tecnicas

- **Rails API mode:** separacao clara entre backend e frontend, comunicacao via HTTP/JSON.
- **Vue 3 com Composition API:** codigo conciso com `<script setup>` e `<style scoped>` por componente.
- **Vite + vite-plugin-ruby:** build rapido com HMR no desenvolvimento e proxy para a API.
- **Autenticacao por token:** `has_secure_password` com Bearer token armazenado no localStorage.
- **Categorias com cores:** usuario escolhe qualquer cor via color picker nativo; cards adaptam texto para cores escuras usando calculo de luminancia.
- **i18n pt-BR:** todas as mensagens de validacao e erro em portugues.
- **Testes de integracao:** cobertura para controllers de notas e categorias, incluindo isolamento entre usuarios.
