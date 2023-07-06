import theredoc from 'theredoc';

describe('Editor', () => {
  it('can be initialised', () => {
    cy.createEditor();
    cy.get('[data-cy="editorjs"]');
    cy.get('[data-placeholder="Write something inspirational..."]');
  });

  describe('converting between Markdown and Editor Blocks', () => {
    [
      {
        markdown: "## Hello world",
        expectBlocks: [
          {
            type: "header",
            data: {
              level: 2,
              text: "Hello world"
            }
          }
        ],
      },
      {
        markdown: "A regular paragraph",
        expectBlocks: [
          {
            type: "paragraph",
            data: {
              text: "A regular paragraph"
            }
          }
        ],
      },
      {
        markdown: "A paragraph [with links](https://www.gov.uk) embedded.",
        expectBlocks: [
          {
            type: "paragraph",
            data: {
              text: `A paragraph <a href="https://www.gov.uk">with links</a> embedded.`
            }
          }
        ],
      },
      {
        markdown: theredoc`
          ## Heading 2

          A paragraph of text, including **bold text**.

          ### Heading 3

          Some more text [with links](https://example.com) embedded.
        `,
        expectBlocks: [
          {
            type: "header",
            data: {
              "text": "Heading 2",
              "level": 2
            }
          },
          {
            type: "paragraph",
            data: {
              text: "A paragraph of text, including <b>bold text</b>."
            }
          },
          {
            type: "header",
            data: {
              text: "Heading 3",
              level: 3
            }
          },
          {
            type: "paragraph",
            data: {
              text: "Some more text <a href=\"https://example.com\">with links</a> embedded."
            }
          }
        ],
      },
      {
        markdown: theredoc`
          ## A document with a table

          | Number | Name |
          | --- | --- |
          | 1 | One |
          | 2 | Two |
          | 3 | Three |
        `,
        expectBlocks: [
          {
            type: "header",
            data: {
              "text": "A document with a table",
              "level": 2
            }
          },
          {
            type: "table",
            data: {
              withHeadings: true,
              content: [
                ["Number", "Name"],
                ["1", "One"],
                ["2", "Two"],
                ["3", "Three"],
              ],
            },
          },
        ],
      },
      {
        markdown: theredoc`
          There are 8 planets in our solar system:

          1. Mercury
          2. Venus
          3. Earth (that's where we live)
          4. Mars
          5. Jupiter
          6. Saturn
          7. Uranus
          8. Neptune

          If you want to visit a planet, you're going to need:

          - A space ship
          - Enough fuel to get you there
          - Lots of money
          - A space suit
        `,
        expectBlocks: [
          {
            type: "paragraph",
            data: {
              text: "There are 8 planets in our solar system:"
            }
          },
          {
            type: "list",
            data: {
              style: "ordered",
              items: [
                "Mercury",
                "Venus",
                "Earth (that's where we live)",
                "Mars",
                "Jupiter",
                "Saturn",
                "Uranus",
                "Neptune"
              ]
            }
          },
          {
            type: "paragraph",
            data: {
              text: "If you want to visit a planet, you're going to need:"
            }
          },
          {
            type: "list",
            data: {
              style: "unordered",
              items: [
                "A space ship",
                "Enough fuel to get you there",
                "Lots of money",
                "A space suit"
              ]
            }
          }
        ],
      }
    ].forEach((example, index) => {
      describe(`Example #${index}`, () => {
        it(`renders Editor Blocks`, () => {
          const { markdown, expectBlocks } = example;
          cy.createEditor({ markdown }).then(async (editor) => {
            const data = await editor.save();
            expect(data).to.containSubset({
              blocks: expectBlocks
            });
          });
        });

        it(`exports the Blocks back to Markdown`, () => {
          const { markdown } = example;
          cy.createEditor({ markdown })
            .then((editor) => (cy.getMarkdown(editor)))
            .then((output) => {
              expect(output).to.equal(markdown);
            });
        });
      });
    });
  });

  describe('transforming Markdown syntax to Blocks', () => {
    [
      {
        type: "## Hello",
        expectBlocks: [{
          type: "header",
          data: {
            text: "Hello",
            level: 2,
          },
        }],
      },
      {
        type: "Hello{moveToStart}## ",
        expectBlocks: [{
          type: "header",
          data: {
            text: "Hello",
            level: 2,
          },
        }],
      },
      {
        type: "- Bread{enter}Milk{enter}Eggs",
        expectBlocks: [{
          type: "list",
          data: {
            items: ["Bread", "Milk", "Eggs"],
            style: "unordered",
          },
        }],
      },
      {
        type: "1. One{enter}Two{enter}Three",
        expectBlocks: [{
          type: "list",
          data: {
            items: ["One", "Two", "Three"],
            style: "ordered",
          },
        }],
      },
    ].forEach((example, index) => {
      it(example.type, () => {
        const editor = cy.createEditor();

        cy.lastBlock().type(example.type, { delay: 50 });


        editor.then(e => e.save()).then((data) => {
          expect(data.blocks).to.have.lengthOf(example.expectBlocks.length);
          expect(data).to.containSubset({
            blocks: example.expectBlocks,
          });
        });
      });
    });
  });
});
