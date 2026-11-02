# PHPUnit coverage reports, collected with Xdebug (line, then path and branch) and with PCOV.
source /corpus/emitters/lib.sh
tool php php --version
tool xdebug echo "xdebug 3.5.3 (pecl)"
tool pcov echo "pcov 1.0.12 (pecl)"

fresh php
step composer install -q --no-progress
tool phpunit vendor/bin/phpunit --version
step bash -c '../gen-big.sh php > src/Big.php'
reports="--coverage-clover clover.xml --coverage-cobertura cobertura.xml --coverage-openclover openclover.xml --coverage-php coverage.php"

xd="php -d memory_limit=4G -d zend_extension=xdebug -d xdebug.mode=coverage vendor/bin/phpunit"
step $xd $reports
for f in clover cobertura openclover; do keep ${f/openclover/clover} $f.xml xdebug/$f.xml; done
keep phpunit-php coverage.php xdebug/coverage.php
note "openclover.xml is PHPUnit's --coverage-openclover writer, separate from its Clover writer"

step $xd --path-coverage $reports
note "Xdebug path coverage needed about 450 MB for the 1000-function Big.php, past PHP's default 128 MB limit, so memory_limit is raised"
for f in clover cobertura openclover; do keep ${f/openclover/clover} $f.xml xdebug-path-coverage/$f.xml; done

step php -d extension=pcov -d pcov.enabled=1 vendor/bin/phpunit $reports
for f in clover cobertura; do keep $f $f.xml pcov/$f.xml; done
