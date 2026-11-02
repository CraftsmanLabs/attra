# Dart VM coverage: the raw hitmap JSON from dart test, and LCOV from package:coverage.
source /corpus/emitters/lib.sh
tool dart dart --version

fresh dart
cd sample
step bash -c '../../gen-big.sh dart > lib/src/big.dart'
step dart pub get
tool coverage bash -c 'grep -A8 "^  coverage:" pubspec.lock | grep version'

step dart test --coverage=raw
step bash -c 'cp raw/test/sample_test.dart.vm.json hitmap.json'
keep dart-vm-json hitmap.json dart-test/sample_test.dart.vm.json
note "dart-test/sample_test.dart.vm.json covers every loaded library (about 320, mostly package: dependencies and the SDK), not only the sample"

step dart run coverage:format_coverage --lcov --in=raw --out=format.info --report-on=lib --report-on=../util/lib --check-ignore
keep lcov format.info format_coverage/lcov.info

step dart run coverage:test_with_coverage --branch-coverage --function-coverage --out=twc
keep lcov twc/lcov.info test_with_coverage/branch-function-lcov.info
keep dart-vm-json twc/coverage.json test_with_coverage/coverage.json
