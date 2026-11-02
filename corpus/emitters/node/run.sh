# Istanbul through nyc, V8 through c8, raw V8 coverage, and Node's built-in test coverage, on samples/js.
source /corpus/emitters/lib.sh
tool node node --version

fresh js
step npm ci --silent
tool nyc node -p 'require("nyc/package.json").version'
tool c8 node -p 'require("c8/package.json").version'
mkdir -p gen && step bash -c '../gen-big.sh js > gen/big.js'

# nyc instruments with Istanbul.
step npx nyc --all --include 'src/**' --include 'lib/**' --include 'gen/**' --reporter=json --reporter=lcovonly --reporter=cobertura --reporter=clover --reporter=json-summary node test/run.js
keep istanbul-json coverage/coverage-final.json nyc/coverage-final.json
keep lcov coverage/lcov.info nyc/lcov.info
keep cobertura coverage/cobertura-coverage.xml nyc/cobertura-coverage.xml
keep clover coverage/clover.xml nyc/clover.xml
keep istanbul-json-summary coverage/coverage-summary.json nyc/coverage-summary.json
rm -rf coverage .nyc_output

# c8 collects V8 coverage and converts it to Istanbul.
step npx c8 --all --include 'src/**' --include 'lib/**' --include 'gen/**' --reporter=json --reporter=lcovonly --reporter=cobertura --reporter=clover node test/run.js
keep istanbul-json coverage/coverage-final.json c8/coverage-final.json
keep lcov coverage/lcov.info c8/lcov.info
keep cobertura coverage/cobertura-coverage.xml c8/cobertura-coverage.xml
keep clover coverage/clover.xml c8/clover.xml
rm -rf coverage

# Raw V8 coverage, one JSON file per process, Node internals filtered out.
step env NODE_V8_COVERAGE=v8 node test/run.js
step node /corpus/emitters/node/filter-v8.js v8 v8.json
keep v8-json v8.json v8/coverage.json
note "v8/coverage.json is NODE_V8_COVERAGE output filtered to the sample's own files (Node internals and node_modules dropped); otherwise as written"

# Node's built-in test runner coverage, written as LCOV by Node itself.
step node --test --experimental-test-coverage --test-reporter=lcov --test-reporter-destination=node-test.info test/run.test.js
keep lcov node-test.info node-test/lcov.info
