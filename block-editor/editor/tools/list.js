import List from '@editorjs/list';

class ExportableList extends List {
  static toMarkdown(data) {
    const { items, style } = data;
    const format = {
      ordered: (item, index) => (`${index + 1}. ${item}`),
      unordered: (item) => (`- ${item}`),
    };
    return items.map(format[style]).join("\n");
  }
}

export default {
  class: ExportableList
};
