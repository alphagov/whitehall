//= require govspeak-visual-editor/dist/govspeak-visual-editor.js
import GovspeakVisualEditor from './govspeak-visual-editor.js';

new GovspeakVisualEditor(
  document.querySelector('.app-c-govspeak-editor__preview'),
  document.querySelector('.app-c-govspeak-editor__visual-editor'),
  document.querySelector('.app-c-govspeak-editor__textarea textarea')
)
