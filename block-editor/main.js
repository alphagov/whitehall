import { createEditor, getMarkdown } from './editor/editor';

const importButton = document.getElementById('import-button');
const importDialog = document.getElementById('import-dialog');
const importTextarea = document.getElementById('import-textarea');

const exportButton = document.getElementById('export-button');
const exportDialog = document.getElementById('export-dialog');
const exportTextarea = document.getElementById('export-textarea');

const resetButton = document.getElementById('reset-button');

let editor = createEditor();

/**
 * Import
 */
importButton.addEventListener('click', () => {
  importDialog.showModal();
});

importDialog.addEventListener('close', () => {
  const markdown = importTextarea.value;
  importTextarea.value = "";
  if (markdown) {
    editor.destroy();
    editor = createEditor({ markdown });
  }
});

/**
 * Export
 */
exportButton.addEventListener('click', async () => {
  exportDialog.showModal();
  exportTextarea.value = await getMarkdown(editor);
});

/**
 * Reset
 */
resetButton.addEventListener('click', () => {
  editor.destroy();
  editor = createEditor();
});
