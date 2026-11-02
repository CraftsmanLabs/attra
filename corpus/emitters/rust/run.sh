# cargo-llvm-cov (source-based, LLVM) and cargo-tarpaulin (ptrace by default), on samples/rust.
source /corpus/emitters/lib.sh
tool rustc rustc --version
tool cargo-llvm-cov cargo llvm-cov --version
tool cargo-tarpaulin cargo tarpaulin --version

fresh rust
step bash -c '../gen-big.sh rs > sample/src/big.rs'

step cargo llvm-cov --workspace --json --output-path llvm-cov.json
keep llvm-cov-json llvm-cov.json cargo-llvm-cov/export.json
step cargo llvm-cov report --lcov --output-path llvm-cov.info
keep lcov llvm-cov.info cargo-llvm-cov/lcov.info
step cargo llvm-cov report --cobertura --output-path llvm-cov.xml
keep cobertura llvm-cov.xml cargo-llvm-cov/cobertura.xml
step cargo llvm-cov report --codecov --output-path llvm-cov-codecov.json
keep codecov-json llvm-cov-codecov.json cargo-llvm-cov/codecov.json

step cargo tarpaulin --workspace --skip-clean --out Json --out Lcov --out Xml --output-dir tarpaulin
keep tarpaulin-json tarpaulin/tarpaulin-report.json tarpaulin/tarpaulin-report.json
keep lcov tarpaulin/lcov.info tarpaulin/lcov.info
keep cobertura tarpaulin/cobertura.xml tarpaulin/cobertura.xml
