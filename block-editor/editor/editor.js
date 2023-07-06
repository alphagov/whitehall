import EditorJS from '@editorjs/editorjs';
import tools from './tools';
import loadMarkdown from './loadMarkdown';
import exportMarkdown from './exportMarkdown';

const DEFAULT_CONFIG = {
  holder: 'editorjs',
  tools,
  placeholder: "Write something inspirational...",
  autofocus: true,
};

const createEditor = (config = {}) => {
  if (config.markdown) {
    const { markdown } = config;
    delete config.markdown;
    config.onReady = () => {
      loadMarkdown({ editor, markdown });
    };
  }

  const editor = new EditorJS({
    ...DEFAULT_CONFIG,
    ...config
  });

  return editor;
};

const getMarkdown = async (editor) => {
  const data = await editor.save();
  const markdown = await exportMarkdown(data);
  return markdown;
};

export { createEditor, getMarkdown };
