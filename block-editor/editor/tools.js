/**
 * Glob import all tools present in the "tools" directory
 */
const globImport = import.meta.glob('./tools/*.js', { eager: true });

/**
 * Input: "./editor/tools/somename.js"
 * Output: "somename"
 */
const nameFromPath = (path) => (path.match(/.*\/([^\/]+)\.js/)[1]);

const tools = Object.entries(globImport).reduce((obj, entry) => {
  const name = nameFromPath(entry[0]);
  const tool = entry[1].default;
  obj[name] = tool;
  return obj;
}, {});

export default tools;
