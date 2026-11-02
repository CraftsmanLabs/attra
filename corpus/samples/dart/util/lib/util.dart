/// A second package: a second source root.
int add(int a, int b) {
  return a + b;
}

int unused(int n) {
  return add(n, 1);
}
