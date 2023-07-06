import tools from "./tools";

const convertBlockToMarkdown = (block) => {
  const tool = tools[block.type].class;
  const maybePromise = tool.toMarkdown(block.data);
  return Promise.resolve(maybePromise);
};

const exportMarkdown = async (data) => {
  const blocksAsMarkdown = await Promise.all(data.blocks.map(convertBlockToMarkdown));
  return blocksAsMarkdown.join("\n\n");
};

export default exportMarkdown;
