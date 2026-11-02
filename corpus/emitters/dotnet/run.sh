# coverlet (msbuild and collector) and Microsoft's dotnet-coverage, on samples/dotnet.
source /corpus/emitters/lib.sh
export DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1
tool dotnet dotnet --version
tool coverlet echo "coverlet.msbuild and coverlet.collector 10.1.0 (pinned in tests/Sample.Tests.csproj)"
tool dotnet-coverage dotnet-coverage --version

fresh dotnet
step bash -c '../gen-big.sh cs > src/Sample/Big.cs'
step dotnet build -v q tests/Sample.Tests

# coverlet.msbuild: every format it writes, from one run.
step dotnet test --no-build -v q tests/Sample.Tests /p:CollectCoverage=true '/p:CoverletOutputFormat="cobertura,opencover,lcov,json"' /p:CoverletOutput=$PWD/coverlet/
keep cobertura coverlet/coverage.cobertura.xml coverlet/coverage.cobertura.xml
keep opencover coverlet/coverage.opencover.xml coverlet/coverage.opencover.xml
keep lcov coverlet/coverage.info coverlet/coverage.info
keep coverlet-json coverlet/coverage.json coverlet/coverage.json

# coverlet.collector writes the same Cobertura as coverlet.msbuild (only the timestamp differed), so it is not kept.

# Microsoft's collector, bundled with Microsoft.NET.Test.Sdk.
step dotnet test --no-build -v q tests/Sample.Tests --collect "Code Coverage;Format=cobertura" --results-directory ms-cobertura
step bash -c 'cp ms-cobertura/*/*.cobertura.xml ms.cobertura.xml'
keep cobertura ms.cobertura.xml microsoft-codecoverage/coverage.cobertura.xml
step dotnet test --no-build -v q tests/Sample.Tests --collect "Code Coverage;Format=xml" --results-directory ms-xml
step bash -c 'cp ms-xml/*/*.xml ms.xml'
keep ms-coverage-xml ms.xml microsoft-codecoverage/coverage.xml

# dotnet-coverage wrapping dotnet test without settings: the test host is not instrumented,
# and the tool still writes a report claiming 100%. Kept because users hit it.
step dotnet-coverage collect -f cobertura -o empty.cobertura.xml dotnet test --no-build -v q tests/Sample.Tests
keep cobertura empty.cobertura.xml dotnet-coverage/empty-run.cobertura.xml
note "dotnet-coverage/empty-run.cobertura.xml has no packages but line-rate=1 and branch-rate=1"
