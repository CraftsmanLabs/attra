# GCC 15 gcov, lcov's geninfo, and gcovr, all reading one instrumented build of samples/c.
source /corpus/emitters/lib.sh
tool gcc gcc --version
tool gcov gcov --version
tool lcov lcov --version
tool lcov-package dpkg-query -W lcov
note "Debian's lcov 2.3.1-1 package reports itself as \"LCOV version 2.0-1\"; trust the package version"
tool gcovr gcovr --version

fresh c
step ./build.sh gcc g++ -O0 --coverage -fcondition-coverage
step ./build/test

# gcov JSON, one gzipped file per translation unit, with branches and conditions.
mkdir -p gcov-json && cd gcov-json
step gcov --json-format --branch-probabilities --conditions --object-directory ../build ../build/*.gcda
cd ..
keep gcov-json gcov-json gcov-json
note "gcov JSON writes one .gcov.json.gz per translation unit; static inline add() from lib/util.h appears in several of them"

# lcov geninfo: line and function only (lcov's default), then with branches and MC/DC.
step lcov --capture --directory build --base-directory . --output-file lcov-default.info
keep lcov lcov-default.info lcov/default.info
step lcov --capture --directory build --base-directory . --rc branch_coverage=1 --rc mcdc_coverage=1 --output-file lcov-branch-mcdc.info
keep lcov lcov-branch-mcdc.info lcov/branch-mcdc.info

# gcovr: Cobertura, LCOV and gcovr's own JSON, with the exclusion markers honoured.
step gcovr --root . --object-directory build --cobertura-pretty --cobertura gcovr-cobertura.xml --lcov gcovr.info --json-pretty --json gcovr.json
keep cobertura gcovr-cobertura.xml gcovr/cobertura.xml
keep lcov gcovr.info gcovr/lcov.info
keep gcovr-json gcovr.json gcovr/gcovr.json
