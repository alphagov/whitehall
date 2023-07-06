// Module under test
import tools from './tools';

// Expected tools
import Header from './tools/header';
import List from './tools/list';
import Paragraph from './tools/paragraph';

describe('editor/tools', () => {
  it('returns a key => value mapping of tools', () => {
    expect(tools.header).toBe(Header);
    expect(tools.paragraph).toBe(Paragraph);
    expect(tools.list).toBe(List);
  });
});
