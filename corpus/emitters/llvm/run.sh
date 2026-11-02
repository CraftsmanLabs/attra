# clang source-based coverage, exported by llvm-cov, on samples/c.
source /corpus/emitters/lib.sh
tool clang clang --version
tool llvm-cov llvm-cov --version

fresh c
step ./build.sh clang clang++ -O0 -fprofile-instr-generate -fcoverage-mapping -fcoverage-mcdc
step env LLVM_PROFILE_FILE=build/test.profraw ./build/test
step llvm-profdata merge -sparse build/test.profraw -o build/test.profdata

cov="llvm-cov export ./build/test -instr-profile=build/test.profdata"
step $cov -format=text > export.json
keep llvm-cov-json export.json llvm-cov/export.json
step $cov -format=text -summary-only > summary.json
keep llvm-cov-json summary.json llvm-cov/summary-only.json
note "summary-only.json has totals per file and no per-line or per-region data"
step $cov -format=lcov > export.info
keep lcov export.info llvm-cov/export.info
step $cov -format=text -skip-expansions -skip-functions > export-no-functions.json
keep llvm-cov-json export-no-functions.json llvm-cov/export-skip-expansions-functions.json
