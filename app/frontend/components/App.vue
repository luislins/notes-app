<template>
  <div class="container">
    <h1>Anotações</h1>
    <NoteForm @created="$refs.list.fetchNotes()" />
    <NoteList ref="list" />
  </div>
</template>

<script setup>
import NoteForm from './NoteForm.vue'
import NoteList from './NoteList.vue'
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: system-ui, -apple-system, sans-serif;
  background: #f5f5f5;
  color: #333;
}

.container {
  max-width: 640px;
  margin: 2rem auto;
  padding: 0 1rem;
}

h1 {
  margin-bottom: 1.5rem;
  font-size: 1.75rem;
}

.note-form {
  background: #fff;
  padding: 1.5rem;
  border-radius: 8px;
  margin-bottom: 2rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.25rem;
  font-weight: 500;
  font-size: 0.875rem;
}

.form-group input,
.form-group textarea {
  width: 100%;
  padding: 0.5rem 0.75rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
  font-family: inherit;
}

.form-group input:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #4a90d9;
  box-shadow: 0 0 0 2px rgba(74, 144, 217, 0.2);
}

button {
  background: #4a90d9;
  color: #fff;
  border: none;
  padding: 0.6rem 1.25rem;
  border-radius: 4px;
  font-size: 1rem;
  cursor: pointer;
}

button:hover {
  background: #357abd;
}

button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.errors {
  list-style: none;
  margin-bottom: 1rem;
  color: #d32f2f;
  font-size: 0.875rem;
}

.note-list .empty {
  color: #999;
  text-align: center;
  padding: 2rem;
}

.note-card {
  background: #fff;
  padding: 1rem 1.5rem;
  border-radius: 8px;
  margin-bottom: 0.75rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.note-card h3 {
  font-size: 1.1rem;
  margin-bottom: 0.25rem;
}

.note-card p {
  color: #555;
  margin-bottom: 0.5rem;
}

.note-card small {
  color: #999;
  font-size: 0.8rem;
}
</style>
