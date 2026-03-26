<template>
  <router-view />
</template>

<!-- Global styles: variables, reset, base typography, animations -->
<style>
:root {
  --bg: #f6f3ee;
  --surface: #fffdf9;
  --surface-hover: #faf7f2;
  --border: #e8e2d9;
  --border-focus: #c4a882;
  --text: #2c2418;
  --text-secondary: #7a6e5d;
  --text-muted: #a69e90;
  --accent: #b8860b;
  --accent-hover: #9a7209;
  --accent-light: rgba(184, 134, 11, 0.08);
  --danger: #c0392b;
  --danger-hover: #a93226;
  --danger-light: rgba(192, 57, 43, 0.06);
  --shadow-sm: 0 1px 2px rgba(44, 36, 24, 0.04);
  --shadow-md: 0 4px 12px rgba(44, 36, 24, 0.06);
  --shadow-lg: 0 8px 24px rgba(44, 36, 24, 0.08);
  --radius: 12px;
  --radius-sm: 8px;
  --font-display: 'Instrument Serif', Georgia, serif;
  --font-body: 'DM Sans', system-ui, sans-serif;
  --transition: 200ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: var(--font-body);
  background: var(--bg);
  color: var(--text);
  line-height: 1.6;
  -webkit-font-smoothing: antialiased;
}

h1 {
  font-family: var(--font-display);
  font-size: 2.25rem;
  font-weight: 400;
  letter-spacing: -0.01em;
  color: var(--text);
}

h2 {
  font-family: var(--font-display);
  font-size: 1.75rem;
  font-weight: 400;
  margin-bottom: 1.5rem;
  color: var(--text);
}

button {
  font-family: var(--font-body);
  background: var(--accent);
  color: #fff;
  border: none;
  padding: 0.625rem 1.5rem;
  border-radius: var(--radius-sm);
  font-size: 0.875rem;
  font-weight: 500;
  cursor: pointer;
  transition: all var(--transition);
  letter-spacing: 0.01em;
}

button:hover {
  background: var(--accent-hover);
  transform: translateY(-1px);
  box-shadow: var(--shadow-sm);
}

button:active {
  transform: translateY(0);
}

button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes slideIn {
  from { opacity: 0; transform: translateY(12px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>
