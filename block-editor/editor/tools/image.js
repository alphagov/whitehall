import App from './image/App.svelte';
import { IconPicture } from '@codexteam/icons';
import getRemoteImage from './image/lib/getRemoteImage';

export const ALLOWED_TYPES = [
  'image/png',
  'image/jpeg',
  'image/gif',
  'image/svg+xml',
];

class Image {
  static get toolbox() {
    return {
      title: 'Image',
      icon: IconPicture,
    };
  }

  constructor({ data, api, config, readOnly, block }) {
    // ... use or store arguments as you want
    // console.log({ data, api, config, readOnly, block });
    this.api = api;
    this.app = null;
  }

  render() {
    const target = document.createElement('div');
    target.classList.add(this.api.styles.block);
    this.app = new App({ target });
    return target;
  }

  destroy() {
    if (this.app) {
      // Destroy the Svelte component
      this.app.$destroy();
      this.app = null;
    }
  }

  save() {
    const data = this.app.getData();
    return {
      file: data.file ? 'example.jpg' : null,
      caption: data.caption,
    };
  }

  validate(data) {
    return (data.file && data.caption);
  }

  static toMarkdown(data) {
    return `![${data.caption ?? ''}](${data.file})`;
  }

  static get pasteConfig() {
    return {
      // Paste HTML into Editor
      // This could have come from a website, word processing app, etc.
      tags: [
        {
          img: { src: true, alt: true },
        },
      ],

      // Paste an image URL into the Editor
      patterns: {
        image: /https?:\/\/\S+\.(gif|jpe?g|tiff|png|svg|webp)(\?[a-z0-9=]*)?$/i,
      },

      // Paste or Drag & Drop a file into the Editor
      files: {
        mimeTypes: ALLOWED_TYPES,
      },
    };
  }

  async onPaste(event) {
    const showError = (message) => {
      this.api.notifier.show({ message, style: 'error' });
    };

    switch (event.type) {
      case 'tag': {
        try {
          const image = event.detail.data;
          const file = await getRemoteImage(image.src);
          const caption = image.alt;
          this.app.setData({ file, caption });
        } catch (error) {
          showError('Failed to load pasted image');
        }
        break;
      }

      case 'pattern': {
        try {
          const url = event.detail.data;
          const file = await getRemoteImage(url);
          this.app.setData({ file });
        } catch (error) {
          showError('Failed to load image from pasted URL');
        }
        break;
      }

      case 'file': {
        const file = event.detail.file;
        this.app.setData({ file });
        break;
      }
    }
  }
}

export default {
  class: Image
};
