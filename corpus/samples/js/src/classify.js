const { add } = require("../lib/util");

// Branches: the tests only take the "negative even" and "positive" arms.
function classify(n) {
  if (n < 0 && n % 2 === 0) {
    return "negative even";
  } else if (n < 0) {
    return "negative odd";
  } else if (n === 0) {
    return "zero";
  }
  return "positive";
}

// Partial line: only the "small" side of the ternary runs.
const size = (n) => (n > 100 ? "big" : "small");

// One statement spread over several lines; default parameter never used.
function total(a,
               b,
               c = 0) {
  return add(a,
             add(b, c));
}

// Never called.
function neverCalled(n) {
  return n * 2;
}

// Excluded by the user. The tests never call it.
/* istanbul ignore next */
/* c8 ignore start */
function excluded(n) {
  return n * 3;
}
/* c8 ignore stop */

// Logical expression with a short-circuit leaf that never runs.
function pick(a, b) {
  return a || b || "none";
}

module.exports = { classify, size, total, neverCalled, excluded, pick, anon: () => 1 };
