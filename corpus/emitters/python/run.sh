# coverage.py: every output format, with and without branch measurement, plus contexts.
source /corpus/emitters/lib.sh
tool python python --version
tool coverage coverage --version

fresh python
step bash -c '../gen-big.sh py > src/sample/big.py'
export PYTHONPATH=src:lib

# Line only (coverage.py's default).
step coverage run test/run.py
step coverage json -o line.json
step coverage xml -o line.xml
step coverage lcov -o line.info
keep coverage-py-json line.json line-only/coverage.json
keep cobertura line.xml line-only/coverage.xml
keep lcov line.info line-only/coverage.info
keep coverage-py-data .coverage line-only/.coverage
note "line-only/coverage.xml is Cobertura with branch-rate 0 and branches-valid 0 although branches were not measured"

# Branch measurement on.
step coverage erase
step coverage run --branch test/run.py
step coverage json -o branch.json
step coverage xml -o branch.xml
step coverage lcov -o branch.info
keep coverage-py-json branch.json branch/coverage.json
keep cobertura branch.xml branch/coverage.xml
keep lcov branch.info branch/coverage.info
keep coverage-py-data .coverage branch/.coverage

# Two runs with different static contexts, combined.
step coverage erase
step coverage run --branch --parallel-mode --context=part-a test/run.py a
step coverage run --branch --parallel-mode --context=part-b test/run.py b
step coverage combine
step coverage json --show-contexts --include='src/sample/classify.py,lib/*' -o contexts.json
keep coverage-py-json contexts.json contexts/coverage.json
note "contexts/coverage.json leaves out the generated big.py; with contexts shown, it alone made the report 60 MB"
keep coverage-py-data .coverage contexts/.coverage
