# kcov on a shell script (interpreted) and on samples/c built without instrumentation (compiled, DWARF).
source /corpus/emitters/lib.sh
tool kcov kcov --version
tool gcc gcc --version

fresh shell
step kcov --include-path=/work/shell out-shell ./classify.sh
keep cobertura out-shell/classify.sh/cobertura.xml bash/cobertura.xml
keep codecov-json out-shell/classify.sh/codecov.json bash/codecov.json
keep kcov-json out-shell/classify.sh/coverage.json bash/coverage.json
keep sonarqube-xml out-shell/classify.sh/sonarqube.xml bash/sonarqube.xml

fresh c
step ./build.sh gcc g++ -O0 -g
step kcov --include-path=/work/c out-c ./build/test
keep cobertura out-c/test/cobertura.xml compiled/cobertura.xml
keep codecov-json out-c/test/codecov.json compiled/codecov.json
keep kcov-json out-c/test/coverage.json compiled/coverage.json
note "compiled/: for compiled code kcov's per-line hits count breakpoint addresses on the line, not executions"
