// A second source root.
function add(a, b) {
  return a + b;
}

function unused(n) {
  return add(n, 1);
}

module.exports = { add, unused };
