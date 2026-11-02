# swift test --enable-code-coverage, and llvm-cov export from the same profile, on samples/swift.
source /corpus/emitters/lib.sh
tool swift swift --version
tool llvm-cov bash -c 'llvm-cov --version | grep -i version'

fresh swift
step bash -c '../gen-big.sh swift > Sources/Sample/Big.swift'
step swift test --enable-code-coverage
step bash -c 'cp "$(swift test --show-codecov-path)" swiftpm.json'
keep llvm-cov-json swiftpm.json swiftpm/codecov.json
note "swiftpm/codecov.json is the export SwiftPM writes itself; it covers the test target's sources too"

bin=$(echo .build/debug/SamplePackageTests.xctest)
step bash -c "llvm-cov export -format=lcov $bin -instr-profile=.build/debug/codecov/default.profdata -ignore-filename-regex='.build|Tests' > export.info"
keep lcov export.info llvm-cov/export.info
