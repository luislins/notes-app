# Notes App

Sistema de anotações com criação e listagem, desenvolvido com Ruby on Rails (API) e Vue.js.

## Tecnologias

- **Backend:** Ruby 3.2, Rails 8.1 (API mode)
- **Frontend:** Vue 3, Vite
- **Banco de dados:** PostgreSQL
- **Testes:** Minitest

## Pré-requisitos

- Ruby 3.2+
- Node.js 20+
- PostgreSQL
- Bundler (`gem install bundler`)
- Foreman (`gem install foreman`)

## Instalação

```bash
# Clonar o repositório
git clone <url-do-repositorio>
cd notes-app

# Instalar dependências Ruby
bundle install

# Instalar dependências Node
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
├── controllers/api/
│   └── notes_controller.rb   # Endpoints da API (index, create)
├── models/
│   └── note.rb               # Model com validação de título
└── frontend/
    ├── components/
    │   ├── App.vue            # Componente principal
    │   ├── NoteForm.vue       # Formulário de criação
    │   └── NoteList.vue       # Listagem de anotações
    └── entrypoints/
        └── application.js     # Entry point do Vue
```

## API

| Método | Endpoint     | Descrição              |
|--------|-------------|------------------------|
| GET    | /api/notes  | Lista todas as anotações |
| POST   | /api/notes  | Cria uma nova anotação   |

### POST /api/notes

**Request:**
```json
{
  "note": {
    "title": "Título da anotação",
    "content": "Conteúdo opcional"
  }
}
```

**Sucesso (201):**
```json
{
  "id": 1,
  "title": "Título da anotação",
  "content": "Conteúdo opcional",
  "created_at": "2026-03-25T14:00:00.000Z",
  "updated_at": "2026-03-25T14:00:00.000Z"
}
```

**Erro de validação (422):**
```json
{
  "errors": ["Title can't be blank"]
}
```

## Decisões técnicas

- **Rails API mode:** separação clara entre backend e frontend, comunicação via HTTP/JSON.
- **Vue 3 com Composition API:** código mais conciso com `<script setup>`.
- **Vite + vite-plugin-ruby:** build rápido e HMR no desenvolvimento.
- **Ordenação por data decrescente:** anotações mais recentes aparecem primeiro.
