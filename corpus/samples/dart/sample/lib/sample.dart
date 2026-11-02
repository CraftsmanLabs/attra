import 'package:util/util.dart';

export 'src/big.dart';

/// Branches: the tests only take the "negative even" and "positive" arms.
String classify(int n) {
  if (n < 0 && n % 2 == 0) {
    return 'negative even';
  } else if (n < 0) {
    return 'negative odd';
  } else if (n == 0) {
    return 'zero';
  }
  return 'positive';
}

/// Partial line: only the "small" side of the ternary runs.
String size(int n) => n > 100 ? 'big' : 'small';

/// One statement spread over several lines.
int total(int a,
    int b,
    int c) {
  return add(a,
      add(b, c));
}

/// Never called.
int neverCalled(int n) {
  return n * 2;
}

/// Excluded by the user. The tests never call it.
// coverage:ignore-start
int excluded(int n) {
  return n * 3;
}
// coverage:ignore-end
