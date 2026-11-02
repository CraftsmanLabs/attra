// The same checks, as a node:test file for Node's built-in coverage.
const { test } = require("node:test");
test("sample", () => {
  require("./run");
});
