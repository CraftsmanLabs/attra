# JaCoCo and OpenClover through Maven, on samples/java.
source /corpus/emitters/lib.sh
tool java java -version
tool maven mvn --version
tool jacoco echo "jacoco-maven-plugin 0.8.16 (pinned in samples/java/pom.xml)"
tool openclover echo "clover-maven-plugin 5.1.1 (pinned in samples/java/pom.xml)"

fresh java
step bash -c '../gen-big.sh java > src/main/java/attra/sample/Big.java'

step mvn -B -q -Pjacoco test
keep jacoco-xml target/site/jacoco/jacoco.xml jacoco/jacoco.xml
keep jacoco-csv target/site/jacoco/jacoco.csv jacoco/jacoco.csv
keep jacoco-exec target/jacoco.exec jacoco/jacoco.exec

step mvn -B -q clean
step mvn -B -q -Pclover clover:setup test clover:clover
keep clover target/site/clover/clover.xml openclover/clover.xml
