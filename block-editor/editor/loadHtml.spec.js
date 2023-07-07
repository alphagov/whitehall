import { beforeEach, describe, expect, it, vi } from "vitest";
import loadHtml from "./loadHtml";
import theredoc from 'theredoc';

describe('Loading Markdown into the Editor', () => {
  let mockEditor;

  beforeEach(() => {
    mockEditor = {
      blocks: {
        renderFromHTML: vi.fn(),
      },
    };
  });

  it('calls EditorJS #renderFromHTML with the given HTML', async () => {
    const html = theredoc`
      <h2>Heading 2</h2>
      <p>A paragraph of text.</p>
      <p>A paragraph with <a href="https://example.com">embedded links</a>.</p>
      <ol>
      <li>List item one</li>
      <li>List item two</li>
      <li>List item three</li>
      </ol>
    `;

    await loadHtml({
      html,
      editor: mockEditor,
    });

    expect(mockEditor.blocks.renderFromHTML).toHaveBeenCalledWith(html);
  });

  it('converts <strong> tags to <b> for compatibility with EditorJS', async () => {
    const html = theredoc`
      <p>A paragraph with <strong>bold</strong> text.</p>
      <ol>
      <li><strong>A bold list item</strong></li>
      </ol>
    `;

    const expectHTML = theredoc`
      <p>A paragraph with <b>bold</b> text.</p>
      <ol>
      <li><b>A bold list item</b></li>
      </ol>
    `;

    await loadHtml({
      html,
      editor: mockEditor,
    });

    expect(mockEditor.blocks.renderFromHTML).toHaveBeenCalledWith(expectHTML);
  });

  it('converts <em> tags to <i> for compatibility with EditorJS', async () => {
    const html = theredoc`
      <p>A paragraph with <em>emphasised</em> text.</p>
      <ol>
      <li><em>An emphasised list item</em></li>
      </ol>
    `;

    const expectHTML = theredoc`
      <p>A paragraph with <i>emphasised</i> text.</p>
      <ol>
      <li><i>An emphasised list item</i></li>
      </ol>
    `;

    await loadHtml({
      html,
      editor: mockEditor,
    });

    expect(mockEditor.blocks.renderFromHTML).toHaveBeenCalledWith(expectHTML);
  });
});
