const assert = require("node:assert");
const s = require("../src/classify");
const { bigRun } = require("../gen/big");

assert.strictEqual(s.classify(-2), "negative even");
assert.strictEqual(s.classify(5), "positive");
assert.strictEqual(s.size(3), "small");
assert.strictEqual(s.total(1, 2, 3), 6);
assert.strictEqual(s.pick("x", "y"), "x");
assert.strictEqual(s.anon(), 1);
assert.ok(bigRun() > 0);
