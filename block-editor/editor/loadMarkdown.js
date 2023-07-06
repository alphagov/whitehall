import { unified } from 'unified';
import remarkParse from 'remark-parse';
import remarkGfm from 'remark-gfm';
import remarkRehype from 'remark-rehype';
import rehypeStringify from 'rehype-stringify';
import { visit } from 'unist-util-visit';

/**
 * Editor.js sanitizes HTML input to remove unwanted elements.
 * 
 * The built-in 'bold' and 'italic' Inline Tools of Editor.js create
 * non-semantic <b> and <i> tags. So these are considered 'valid' HTML elements
 * when sanitizing input.
 * 
 * However, <strong> and <em> tags are considered invalid. It's therefore
 * necessary to transform any <strong> and <em> tags produced by Markdown
 * into their non-semantic equivalents.
 * 
 * See those built-in Inline Tools here:
 * https://github.com/codex-team/editor.js/tree/b9a0665672cf9b33770c67bd075b5bf7c18d9ace/src/components/inline-tools
 */
function transformSemanticFormatting() {
  const transforms = new Map([
    ['strong', 'b'],
    ['em', 'i'],
  ]);

  return (tree) => {
    visit(tree, 'element', (node) => {
      if (transforms.has(node.tagName)) {
        node.tagName = transforms.get(node.tagName);
      }
    })
  }
}

const markdownToHtml = async (markdown) => {
  const parser = unified()
    .use(remarkParse)
    .use(remarkGfm)
    .use(remarkRehype)
    .use(transformSemanticFormatting)
    .use(rehypeStringify);
  const vfile = await parser().process(markdown);
  return vfile.value;
}

const loadMarkdown = async ({ editor, markdown }) => {
  const html = await markdownToHtml(markdown);
  editor.blocks.renderFromHTML(html);
};

export default loadMarkdown;
