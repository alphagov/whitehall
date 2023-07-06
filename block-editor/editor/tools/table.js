import Table from "@editorjs/table";

/**
 * The built-in Editor.js Table tool doesn't directly map to Markdown
 * due to it supporting slightly different features.
 *
 * Extra features:
 *   - Use can choose "With headings" or "Without headings"
 *     whereas Markdown tables always have a header row
 *
 * Missing features:
 *   - Text alignment on columns (e.g. right align with `| ---: |` Markdown)
 *   - Row titles (as supported by Govspeak)
 *     https://github.com/alphagov/govspeak/blob/b752bf5cb25e904ebfbf2c400b4447441b110007/test/govspeak_table_with_headers_test.rb#L178-L181
 */

class ExportableTable extends Table {
  static toMarkdown(data) {
    const lines = data.content.map((row) => {
      const columns = row.join(" | ");
      return `| ${columns} |`;
    });

    if (lines.length > 1) {
      // Underline the header row
      const columns = data.content[0].map(() => ("---")).join(" | ");
      lines.splice(1, 0, `| ${columns} |`);
    }

    return lines.join("\n");
  }

  static get pasteConfig() {
    return {
      tags: [
        {
          table: true,
          thead: true,
          tbody: true,
          tr: true,
          th: true,
          td: true,
        }
      ]
    }
  }

  onPaste(event) {
    const table = event.detail.data;
    this.data.content = this.getTableContent(table);
    this.data.withHeadings = true;
    this.updateTable();
  }

  getTableContent(table) {
    const rows = table.querySelectorAll("tr");
    return Array.from(rows).map((row) => {
      const cells = row.querySelectorAll("th, td");
      return Array.from(cells).map((cell) => (cell.innerText));
    });
  }

  updateTable() {
    // First we need to delete all rows/columns in the table
    // Because table.resize() assumes there are 0
    while (this.table.numberOfRows > 0) {
      this.table.deleteRow(1);
    }

    // Then populate it with the new data
    this.table.resize();
    this.table.fill();
    this.table.setHeadingsSetting(this.data.withHeadings);
  }
}

export default {
  class: ExportableTable,
};
