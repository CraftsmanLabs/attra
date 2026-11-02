import 'package:sample/sample.dart';
import 'package:test/test.dart';

void main() {
  test('sample', () {
    expect(classify(-2), 'negative even');
    expect(classify(5), 'positive');
    expect(size(3), 'small');
    expect(total(1, 2, 3), 6);
    expect(bigRun(), greaterThan(0));
  });
}
