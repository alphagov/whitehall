import { describe, expect, it } from "vitest";
import exportMarkdown from "./exportMarkdown";
import theredoc from 'theredoc';

const convertBlock = (block) => {
  const editorData = {
    blocks: [block]
  };
  return exportMarkdown(editorData);
};

describe('Exporting Blocks as Markdown', () => {
  it('converts Editor Blocks to Markdown', async () => {
    const editorData = (await import('../__fixtures__/headings-and-paragraphs.json')).default;
    const expectMarkdown = (await import('../__fixtures__/headings-and-paragraphs.md?raw')).default.trim();
    const actual = await exportMarkdown(editorData);
    expect(actual).toEqual(expectMarkdown);
  });

  describe('List', () => {
    it('converts Ordered Lists', async () => {
      const block = {
        type: "list",
        data: {
          items: ["One", "Two", "Three", "Four"],
          style: "ordered",
        }
      };

      const markdown = theredoc`
        1. One
        2. Two
        3. Three
        4. Four
      `;

      expect(await convertBlock(block)).toEqual(markdown);
    });

    it('converts Unordered Lists', async () => {
      const block = {
        type: "list",
        data: {
          items: ["One", "Two", "Three", "Four"],
          style: "unordered",
        }
      };

      const markdown = theredoc`
        - One
        - Two
        - Three
        - Four
      `;

      expect(await convertBlock(block)).toEqual(markdown);
    });
  });

  describe('Header', () => {
    [
      {
        tag: "H2",
        data: {
          level: 2,
          text: "Heading",
        },
        markdown: "## Heading",
      },
      {
        tag: "H3",
        data: {
          level: 3,
          text: "Heading",
        },
        markdown: "### Heading",
      },
      {
        tag: "H4",
        data: {
          level: 4,
          text: "Heading",
        },
        markdown: "#### Heading",
      },
      {
        tag: "H5",
        data: {
          level: 5,
          text: "Heading",
        },
        markdown: "##### Heading",
      },
      {
        tag: "H6",
        data: {
          level: 6,
          text: "Heading",
        },
        markdown: "###### Heading",
      },
    ].forEach((example) => {
      it(`converts ${example.tag}`, async () => {
        const block = {
          type: "header",
          data: example.data,
        };
        expect(await convertBlock(block)).toEqual(example.markdown);
      });
    });
  });

  describe('Paragraph', () => {
    [
      {
        title: "text-only paragraph",
        text: "Lorem ipsum dolor.",
        markdown: "Lorem ipsum dolor.",
      },
      {
        title: "paragraph with bold formatting",
        text: "Some <strong>strong</strong> and <b>bold</b> text",
        markdown: "Some **strong** and **bold** text",
      },
      {
        title: "paragraph with italic formatting",
        text: "Some <em>emphasised</em> and <i>italic</i> text",
        markdown: "Some *emphasised* and *italic* text",
      },
      {
        title: "paragraph with embedded link",
        text: `Link to an <a href="https://example.com">example</a> website`,
        markdown: "Link to an [example](https://example.com) website",
      },
    ].forEach((example) => {
      it(`converts ${example.title}`, async () => {
        const block = {
          type: "paragraph",
          data: { text: example.text },
        };
        expect(await convertBlock(block)).toEqual(example.markdown);
      });
    });
  });

  describe('Table', () => {
    it('converts Tables', async () => {
      const block = {
        type: "table",
        data: {
          withHeadings: true,
          content: [
            ["Number", "Name"],
            ["1", "One"],
            ["2", "Two"],
          ],
        },
      };

      const markdown = theredoc`
        | Number | Name |
        | --- | --- |
        | 1 | One |
        | 2 | Two |
      `;

      expect(await convertBlock(block)).toEqual(markdown);
    });
  });
});
