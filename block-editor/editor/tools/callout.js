import { IconChevronRight, IconBrackets } from '@codexteam/icons';
import IconInset from 'bootstrap-icons/icons/layout-sidebar-inset.svg?raw';
import IconInfo from 'bootstrap-icons/icons/info.svg?raw';
import IconExclamation from 'bootstrap-icons/icons/exclamation-circle-fill.svg?raw';
import App from './callout/App.svelte';

class Callout {
  static get toolbox() {
    return {
      title: 'Callout',
      icon: IconInset,
    };
  }

  constructor({ data, api, config, readOnly, block }) {
    // ... use or store arguments as you want
    this.api = api;
    this.app = null;
  }

  render() {
    const target = document.createElement('div');
    target.classList.add(this.api.styles.block, 'govspeak');
    this.app = new App({ target });
    return target;
  }

  renderSettings() {
    const { calloutType } = this.app.getData();
    
    return [
      {
        icon: IconInfo,
        label: 'Information callout',
        toggle: 'calloutType',
        isActive: calloutType == "information",
        onActivate: () => { this.app.setData({ calloutType: "information" }) },
        closeOnActivate: true,
      },
      {
        icon: IconExclamation,
        label: 'Warning callout',
        toggle: 'calloutType',
        isActive: calloutType == "warning",
        onActivate: () => { this.app.setData({ calloutType: "warning" }) },
        closeOnActivate: true,
      },
      {
        icon: IconInset,
        label: 'Example callout',
        toggle: 'calloutType',
        isActive: calloutType == "example",
        onActivate: () => { this.app.setData({ calloutType: "example" }) },
        closeOnActivate: true,
      }
    ];
  }

  destroy() {
    if (this.app) {
      // Destroy the Svelte component
      this.app.$destroy();
      this.app = null;
    }
  }

  save() {
    return this.app.getData();
  }

  validate(data) {
    return (data.content && data.calloutType);
  }

  static toMarkdown(data) {
    switch (data.calloutType) {
      case "information":
        return `^${data.content}^`;
      case "warning":
        return `%${data.content}%`;
      case "example":
        return `$E\n${data.content}\n$E`;
      default:
        return "";
    };
  }

  static get sanitize() {
    return {
      calloutType: false, // disallow HTML
      content: {} // only tags from Inline Toolbar are allowed
    }
  }

  static get pasteConfig() {
    return {};

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
    }
  }
}

export default {
  class: Callout,
  inlineToolbar: true,
};
