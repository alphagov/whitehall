import { createEditor, getMarkdown } from '../editor/editor';
import exportMarkdown from '../editor/exportMarkdown';
import markdown from '../__fixtures__/headings-and-paragraphs.md?raw';

/**
 * Live output of EditorJS data
 */
const outputTo = document.querySelector('#output code');
const renderOutput = async (api) => {
  const data = await api.saver.save();
  outputTo.innerText = await exportMarkdown(data);
}

const editor = createEditor({
  onChange: renderOutput,
  markdown,
});

// For live debugging in the browser console
window.editor = editor;
window.getMarkdown = () => (getMarkdown(editor));

/**
 * Show the current block index
 */
const currentBlockTo = document.querySelector('#current-block');
const updateCurrentBlock = () => {
  const current = editor.blocks.getCurrentBlockIndex();
  currentBlockTo.innerText = current;
};
document.addEventListener("keydown", updateCurrentBlock);
document.addEventListener("mousedown", updateCurrentBlock);
