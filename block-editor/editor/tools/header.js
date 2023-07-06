import Header from '@editorjs/header';

class ExportableHeader extends Header {
  static toMarkdown(data) {
    const prefix = "#".repeat(data.level);
    return `${prefix} ${data.text}`;
  }
}

export default {
  class: ExportableHeader,
  config: {
    levels: [2, 3, 4, 5, 6],
    defaultLevel: 2,
  },
};
