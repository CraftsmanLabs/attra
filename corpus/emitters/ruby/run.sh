# SimpleCov 1.x and 0.22 (resultset and JSON), plus the common Cobertura and LCOV plugins.
source /corpus/emitters/lib.sh
tool ruby ruby --version

fresh ruby
step bash -c '../gen-big.sh rb > lib/sample/big.rb'

for v in 1 0.22; do
  export BUNDLE_GEMFILE=$PWD/gemfiles/simplecov-$v.gemfile
  step bundle install --quiet
  tool simplecov-$v bundle exec ruby -e 'require "simplecov"; puts SimpleCov::VERSION'

  rm -rf coverage
  step env WITH_PLUGINS=1 bundle exec ruby test/run.rb
  keep simplecov-resultset coverage/.resultset.json simplecov-$v/line/.resultset.json
  keep simplecov-json coverage/coverage.json simplecov-$v/line/coverage.json
  keep cobertura coverage/coverage.xml simplecov-$v/line/cobertura.xml
  keep lcov coverage/lcov.info simplecov-$v/line/lcov.info

  rm -rf coverage
  step env WITH_PLUGINS=1 BRANCH=1 METHOD=1 bundle exec ruby test/run.rb
  keep simplecov-resultset coverage/.resultset.json simplecov-$v/branch/.resultset.json
  keep simplecov-json coverage/coverage.json simplecov-$v/branch/coverage.json
  keep cobertura coverage/coverage.xml simplecov-$v/branch/cobertura.xml
  keep lcov coverage/lcov.info simplecov-$v/branch/lcov.info
done
