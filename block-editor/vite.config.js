import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';

export default defineConfig({
  plugins: [
    svelte(),
  ],
  test: {
    globals: true,
    environment: 'jsdom',
  },
  build: {
    lib: {
      entry: 'editor/editor.js',
      name: "BlockEditor",
      formats: ['es'],
    }
  },
});
