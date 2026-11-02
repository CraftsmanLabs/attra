# Coverage formats in use and the tools that emit them

Research for [#9](https://github.com/CraftsmanLabs/attra/issues/9), part of [Map: attra coverage v1](https://github.com/CraftsmanLabs/attra/issues/8). Sources were read on 2026-11-02. Terms follow `GLOSSARY.md`: report, format, coverage set, measure, merge, patch coverage.

## Short answer

Proposed v1 read list, in build order:

1. **LCOV tracefile**
2. **Cobertura XML**
3. **JaCoCo XML**
4. **Go coverprofile**
5. **Istanbul JSON** (`coverage-final.json`)
6. **llvm-cov export JSON**

These six cover all eight of the most-used languages on GitHub. Every one of them is the native or default format of at least one major emitter. Four (LCOV, Cobertura, JaCoCo, Go) are accepted by both Codecov and Coveralls. The last two keep data that LCOV and Cobertura drop: statement and branch spans with columns (Istanbul), and regions plus MC/DC (llvm-cov).

Second tier, after v1: Clover XML, OpenCover XML, coverage.py JSON, SimpleCov `coverage.json`, gcov JSON. Each one serves an ecosystem whose main tools can already write a v1 format. The reasoning is at the end.

## Which languages

The eight most-used programming languages on GitHub by monthly contributors in Octoverse 2025 are TypeScript, Python, JavaScript, Java, C#, PHP, C++ and Go. The published top ten also includes Shell (7th) and HCL (9th), which are left out here because they are not general-purpose languages ([Octoverse 2025](https://github.blog/news-insights/octoverse/octoverse-a-new-developer-joins-github-every-second-as-ai-leads-typescript-to-1/)). C, Rust, Ruby, Kotlin, Swift and Dart are covered briefly because their tools change the picture.

## What each language's tools emit

"Default" means what the tool writes when no format is chosen.

| Language | Main tools | Formats they write natively |
|---|---|---|
| TypeScript, JavaScript | Istanbul (nyc, Jest's `babel` provider, Vitest's `istanbul` provider), V8 coverage (c8, Jest's `v8` provider, Vitest's `v8` provider, which is Vitest's default) | All of them report through `istanbul-reports`: `clover`, `cobertura`, `json` (Istanbul JSON), `json-summary`, `lcov`, `lcovonly`, `teamcity`, `text`, `html` and others ([istanbul-reports/lib](https://github.com/istanbuljs/istanbuljs/tree/main/packages/istanbul-reports/lib)). Jest's default reporters are `clover`, `json`, `lcov`, `text` ([Jest config](https://github.com/jestjs/jest/blob/main/docs/Configuration.md)). Vitest's default is `text`, `html`, `clover`, `json`, and its default provider is `v8` ([Vitest coverage config](https://github.com/vitest-dev/vitest/blob/main/docs/config/coverage.md)). c8 writes Istanbul-compatible output ([c8 README](https://github.com/bcoe/c8/blob/main/README.md)). |
| Python | coverage.py (pytest-cov wraps it) | Its own SQLite data file `.coverage`, plus `coverage json`, `coverage xml` (Cobertura) and `coverage lcov` (since 6.3) ([cmd_json](https://github.com/coveragepy/coveragepy/blob/main/doc/commands/cmd_json.rst), [cmd_xml](https://github.com/coveragepy/coveragepy/blob/main/doc/commands/cmd_xml.rst), [cmd_lcov](https://github.com/coveragepy/coveragepy/blob/main/doc/commands/cmd_lcov.rst)). |
| Java, Kotlin | JaCoCo (Maven and Gradle plugins), Kover (Kotlin, Gradle) | JaCoCo writes XML, CSV, HTML and the binary `jacoco.exec` ([report.dtd](https://github.com/jacoco/jacoco/blob/master/org.jacoco.report/src/org/jacoco/report/xml/report.dtd)). Kover writes HTML and XML reports and can use JaCoCo as its engine ([Kover README](https://github.com/Kotlin/kotlinx-kover/blob/main/README.md)). Kover's XML follows the JaCoCo layout, but the README only says "XML". |
| C# | coverlet (`coverlet.collector`, `coverlet.msbuild`, `coverlet.MTP`), Microsoft Code Coverage (`dotnet-coverage`, `Microsoft.Testing.Extensions.CodeCoverage`) | coverlet writes `json` (its own format), `lcov`, `opencover`, `cobertura`, `teamcity` ([coverlet MSBuild docs](https://github.com/coverlet-coverage/coverlet/blob/master/Documentation/MSBuildIntegration.md)). The VSTest collector defaults to Cobertura, and MSBuild and the global tool default to coverlet JSON ([VSTest docs](https://github.com/coverlet-coverage/coverlet/blob/master/Documentation/VSTestIntegration.md), [global tool docs](https://github.com/coverlet-coverage/coverlet/blob/master/Documentation/GlobalTool.md)). Microsoft's tools write `coverage` (binary, the default), `xml` and `cobertura` ([dotnet-coverage](https://learn.microsoft.com/en-us/dotnet/core/additional-tools/dotnet-coverage), [MTP code coverage](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-platform-extensions-code-coverage)). |
| PHP | PHPUnit with php-code-coverage | `--coverage-clover`, `--coverage-openclover`, `--coverage-cobertura`, `--coverage-crap4j`, `--coverage-html`, `--coverage-jsonl`, `--coverage-php`, `--coverage-xml` ([PHPUnit CLI builder](https://github.com/sebastianbergmann/phpunit/blob/main/src/TextUI/Configuration/Cli/Builder.php), [php-code-coverage reports](https://github.com/sebastianbergmann/php-code-coverage/tree/main/src/Report)). |
| C, C++ | gcov (GCC), lcov/geninfo, gcovr, llvm-cov (Clang), kcov | gcov writes text `.gcov` files and, with `--json-format`, gzipped JSON (`format_version` "2") ([gcov.texi](https://github.com/gcc-mirror/gcc/blob/master/gcc/doc/gcov.texi)). lcov writes LCOV tracefiles. gcovr writes `txt` (default), `html`, `csv`, `json`, `json-summary`, `markdown`, `clover`, `cobertura`, `coveralls`, `jacoco`, `lcov`, `sonarqube` ([gcovr README](https://github.com/gcovr/gcovr/blob/main/README.rst)). `llvm-cov export` writes JSON or LCOV ([llvm-cov docs](https://github.com/llvm/llvm-project/blob/main/llvm/docs/CommandGuide/llvm-cov.md)). kcov writes HTML, Cobertura XML and a summary JSON, and has Codecov, Coveralls and SonarQube writers ([kcov README](https://github.com/SimonKagstrom/kcov/blob/master/README.md), [kcov writers](https://github.com/SimonKagstrom/kcov/tree/master/src/writers)). |
| Go | `go test -coverprofile`, `go build -cover` | Text coverprofile. Since Go 1.20, `go build -cover` binaries write binary `covmeta`/`covcounters` files to `GOCOVERDIR`, and `go tool covdata textfmt` turns them back into a coverprofile ([Go integration coverage](https://go.dev/doc/build-cover)). |
| Rust | cargo-llvm-cov, tarpaulin | cargo-llvm-cov: `--json` and `--lcov` (straight from `llvm-cov export`), `--cobertura` (converted from LCOV), `--codecov` (converted from llvm JSON) ([cargo-llvm-cov README](https://github.com/taiki-e/cargo-llvm-cov/blob/main/README.md)). tarpaulin: `Json`, `Stdout`, `Xml` (Cobertura), `Html`, `Lcov` ([tarpaulin README](https://github.com/xd009642/tarpaulin/blob/develop/README.md)). |
| Swift | SwiftPM, Xcode | `swift test` produces JSON and LCOV by running `llvm-cov export` ([SwiftPM CoverageOptions.swift](https://github.com/swiftlang/swift-package-manager/blob/main/Sources/Commands/Coverage/CoverageOptions.swift)). Xcode output goes through `xccov`; Codecov has dedicated Xcode processors for it ([Codecov languages](https://github.com/codecov/umbrella/tree/main/apps/worker/services/report/languages)). |
| Ruby | SimpleCov | HTML and `coverage.json` built in. Cobertura and LCOV come from plugin gems ([SimpleCov Formatters.md](https://github.com/simplecov-ruby/simplecov/blob/main/docs/Formatters.md)). |
| Dart, Flutter | `package:coverage`, `flutter test --coverage` | Dart VM JSON converted to LCOV ([package:coverage README](https://github.com/dart-lang/tools/blob/main/pkgs/coverage/README.md)). `flutter test --coverage` writes `coverage/lcov.info` by default ([flutter_tools test.dart](https://github.com/flutter/flutter/blob/master/packages/flutter_tools/lib/src/commands/test.dart)). |

## The formats one by one

### LCOV tracefile

- **Spec:** the "Tracefile format" section of the `geninfo` man page ([geninfo.rst](https://github.com/linux-test-project/lcov/blob/master/docs/man/geninfo.rst)). It is the closest thing to a real spec in this survey, and it keeps changing.
- **Records:** `TN`, `SF`, `VER`, functions (`FN`/`FNDA` before 2.2; `FNL`/`FNA` from 2.2, with old records still read), `FNF`/`FNH`, `BRDA`, `BRF`/`BRH`, `MCDC` and `MCF`/`MCH`, `DA`, `LF`/`LH`, `end_of_record`.
- **Version history, checked against tagged man pages:** `FNL` first appears in v2.2 and `MCDC` in v2.3 ([v2.2 geninfo.1](https://github.com/linux-test-project/lcov/blob/v2.2/man/geninfo.1), [v2.3 geninfo.1](https://github.com/linux-test-project/lcov/blob/v2.3/man/geninfo.1)). The latest release, v2.6 (2026-10-03), has `FNL`, `FNA`, `MCDC` and `DA:<line>,<count>[,<checksum>]` ([v2.6 geninfo.rst](https://github.com/linux-test-project/lcov/blob/v2.6/docs/man/geninfo.rst)). The master branch has more that is not released yet: callgraph records (`FNC`, `FNM`), a `^<location>` suffix on `BRDA` and `MCDC`, file indexes on `SF`, and a statement end line on `DA`.
- **Measures:** line (with counts), function, branch, MC/DC.
- **Not recorded vs zero:** `BRDA`'s taken field is `-` when "the corresponding expression was never evaluated" and a number otherwise ([geninfo.rst](https://github.com/linux-test-project/lcov/blob/master/docs/man/geninfo.rst)). This is the only format here that writes "not recorded" explicitly at the branch level.
- **Emitters:** lcov/geninfo, `llvm-cov export -format=lcov`, Istanbul `lcov`/`lcovonly`, coverage.py, coverlet, gcovr, cargo-llvm-cov, tarpaulin, SwiftPM, Dart `format_coverage`, Flutter, `simplecov-lcov`. Most third-party emitters write the pre-2.2 subset. coverage.py, for example, writes `FN`/`FNDA`, `BRDA` and `DA` with an optional MD5 checksum ([coverage.py lcovreport.py](https://github.com/coveragepy/coveragepy/blob/main/coverage/lcovreport.py)).
- **Read by:** Codecov, Coveralls, ReportGenerator, Azure Pipelines.

### Cobertura XML

- **Spec:** `coverage-04.dtd` from the original Cobertura project ([DTD](https://github.com/cobertura/web/blob/master/htdocs/xml/coverage-04.dtd)). The Cobertura tool itself is dormant: the repository's last push was 2023-05-29 (GitHub API). The format lives on as an interchange format defined by that DTD and by what emitters actually write.
- **Shape:** `coverage > packages > package > classes > class(filename) > lines > line(number, hits, branch, condition-coverage) > conditions > condition`. The per-line branch detail is a string such as `condition-coverage="50% (1/2)"`. Individual branches have no identity.
- **Measures:** line (with counts), plus branch counts per line. Methods exist but carry only rates.
- **Not recorded vs zero:** the DTD makes `line-rate`, `branch-rate`, `branches-covered`, `branches-valid` and `complexity` required on `<coverage>` ([DTD](https://github.com/cobertura/web/blob/master/htdocs/xml/coverage-04.dtd)). An emitter that did not measure branches still has to write something. coverage.py writes `branch-rate="0"` with `branches-valid="0"` when branch measurement is off ([xmlreport.py](https://github.com/coveragepy/coveragepy/blob/main/coverage/xmlreport.py)). kcov writes `branch-rate="1.0"` with `branches-valid="0"` ([kcov cobertura-writer.cc](https://github.com/SimonKagstrom/kcov/blob/master/src/writers/cobertura-writer.cc)). A reader must not trust the rate attributes. It should trust only the `<line>` elements, and treat branches as recorded only when `branch="true"` lines exist.
- **Dialects:** coverage.py writes `hits` as 0 or 1 only, never a real count ("Q: can we get info about the number of times a statement is executed?" in [xmlreport.py](https://github.com/coveragepy/coveragepy/blob/main/coverage/xmlreport.py)). It also adds a `missing-branches` attribute that is not in the DTD. kcov collapses hits to 1 in single-hit mode.
- **Emitters:** coverage.py, coverlet (default for the VSTest collector), Microsoft Code Coverage, Istanbul, PHPUnit, gcovr, kcov, tarpaulin, cargo-llvm-cov (converted from LCOV), `simplecov-cobertura`, ReportGenerator.
- **Read by:** Codecov, Coveralls, GitLab (one of only two formats it accepts) ([GitLab code coverage](https://docs.gitlab.com/ci/testing/code_coverage/)), Azure Pipelines ([PublishCodeCoverageResults@2](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/publish-code-coverage-results-v2)), ReportGenerator.

### JaCoCo XML

- **Spec:** `report.dtd`, public ID `-//JACOCO//DTD Report 1.1//EN` ([report.dtd](https://github.com/jacoco/jacoco/blob/master/org.jacoco.report/src/org/jacoco/report/xml/report.dtd)). Actively released; 0.8.16 came out 2026-10-26.
- **Shape:** `report > group* > package > (class > method > counter) | (sourcefile > line(nr, mi, ci, mb, cb) > counter)`. Counter types are `INSTRUCTION`, `BRANCH`, `LINE`, `COMPLEXITY`, `METHOD`, `CLASS`.
- **Measures:** instruction, branch, line, method, class. Lines record missed and covered instruction and branch counts, **not execution counts**. A line is covered when `ci > 0`. Which branch on a line was taken is not recorded.
- **Paths:** a `sourcefile` has only a local name inside a package in VM notation (`com/example`), so the path relative to some source root has to be reconstructed. Azure's docs say so directly: "JaCoCo reports don't use absolute paths" ([PublishCodeCoverageResults@2](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/publish-code-coverage-results-v2)).
- **Emitters:** JaCoCo, Kover, gcovr.
- **Read by:** Codecov, Coveralls, GitLab, ReportGenerator.

### Go coverprofile

- **Spec:** only the emitter and reader source. The parser in `golang.org/x/tools/cover` documents it: the first line is `mode: set|count|atomic`, then one line per block, `name.go:line.column,line.column numberOfStatements count` ([profile.go](https://github.com/golang/tools/blob/master/cover/profile.go)).
- **Measures:** statement blocks with start and end columns. In `set` mode the count is 0 or 1. There is no branch or function measure in the file. `go tool cover -func` derives function coverage from the source.
- **Merge rule from the reference parser:** a block that appears more than once at the same span is merged with OR in `set` mode and summed otherwise, and a mismatched `NumStmt` is an error ([profile.go](https://github.com/golang/tools/blob/master/cover/profile.go)).
- **Paths:** file names are import paths such as `encoding/base64/base64.go`, not filesystem paths ([profile.go](https://github.com/golang/tools/blob/master/cover/profile.go)).
- **Emitters:** `go test -coverprofile`, `go tool covdata textfmt` ([Go integration coverage](https://go.dev/doc/build-cover)).
- **Read by:** Codecov, Coveralls.

### Istanbul JSON (`coverage-final.json`)

- **Spec:** a prose description in the repository ([raw-output.md](https://github.com/istanbuljs/istanbuljs/blob/main/docs/raw-output.md)) plus the code in `istanbul-lib-coverage` ([file-coverage.js](https://github.com/istanbuljs/istanbuljs/blob/main/packages/istanbul-lib-coverage/lib/file-coverage.js)). It has no versioned schema, although each file object carries a `_coverageSchema` hash.
- **Shape:** an object keyed by absolute path. Each value holds `statementMap`, `fnMap` and `branchMap` (start and end line and column for each item) and counters `s`, `f`, `b` (one array per branch, one count per arm). An optional `bT` holds counts for logical truthiness. Branch types are `if`, `binary-expr`, `cond-expr`, `switch`, `default-arg`.
- **Measures:** statement, function, branch, all with counts and source spans. Line coverage is derived from statements.
- **Emitters:** nyc, Jest, Vitest, c8, everything else built on `istanbul-reports` (the `json` reporter).
- **Read by:** Codecov (the `NodeProcessor` matches any JSON object whose values are all objects) ([node.py](https://github.com/codecov/umbrella/blob/main/apps/worker/services/report/languages/node.py)). Coveralls has no Istanbul parser ([coverage-reporter parsers](https://github.com/coverallsapp/coverage-reporter/tree/master/src/coverage_reporter/parsers)).

### llvm-cov export JSON

- **Spec:** a block comment in the exporter source, and nothing else. The type is `llvm.coverage.json.export` and the current version is `3.1.0` ([CoverageExporterJson.cpp](https://github.com/llvm/llvm-project/blob/main/llvm/tools/llvm-cov/CoverageExporterJson.cpp)).
- **Shape:** `data[] > files[] > {segments, branches, mcdc_records, expansions, summary}` and `functions[]`. Rows are positional arrays. A segment is `[line, col, count, hasCount, isRegionEntry, isGapRegion]`. A region is `[lineStart, colStart, lineEnd, colEnd, count, fileID, expandedFileID, kind]`. A branch adds a false-count after the count ([CoverageExporterJson.cpp](https://github.com/llvm/llvm-project/blob/main/llvm/tools/llvm-cov/CoverageExporterJson.cpp)).
- **Measures:** line, function, instantiation, region, branch, MC/DC. Segments carry an explicit `hasCount` flag, so "not recorded" is explicit here too.
- **Size:** this is the most verbose format here, and the docs offer `-summary-only`, `-skip-expansions` and `-skip-functions` to shrink it ([llvm-cov docs](https://github.com/llvm/llvm-project/blob/main/llvm/docs/CommandGuide/llvm-cov.md)). This matters for the map's performance budgets.
- **Emitters:** `llvm-cov export`, so Clang (C, C++, Objective-C), Rust (`-C instrument-coverage`, through cargo-llvm-cov) and Swift (SwiftPM).
- **Read by:** neither Codecov nor Coveralls directly. cargo-llvm-cov converts it to Codecov's custom JSON instead ([cargo-llvm-cov README](https://github.com/taiki-e/cargo-llvm-cov/blob/main/README.md)).

### Clover XML

- **Spec:** `clover.xsd` from OpenClover ([clover.xsd](https://github.com/openclover/clover/blob/master/clover-core/src/main/resources/clover.xsd)).
- **Shape:** `coverage(clover, generated) > project > package > file(name, path) > class > metrics` plus `line(num, type=method|stmt|cond, count, truecount, falsecount)`.
- **Measures:** statement and method with counts, and conditionals with true and false counts.
- **Dialects:** PHPUnit has two writers. `Clover` is the long-standing one. It writes `crap` and `namespace` attributes and leaves out `package`, `path` and `signature`. `OpenClover` writes the schema's `package`, `path`, `signature` and `clover` version attribute ([Clover.php](https://github.com/sebastianbergmann/php-code-coverage/blob/main/src/Report/Clover.php), [OpenClover.php](https://github.com/sebastianbergmann/php-code-coverage/blob/main/src/Report/OpenClover.php)). Istanbul and gcovr also write Clover.
- **Detection:** Clover and Cobertura both use a root element named `<coverage>`. Codecov tells them apart by whether `generated` is present ([clover.py](https://github.com/codecov/umbrella/blob/main/apps/worker/services/report/languages/clover.py), [cobertura.py](https://github.com/codecov/umbrella/blob/main/apps/worker/services/report/languages/cobertura.py)).
- **Read by:** Codecov, Coveralls (`clover`, "via PHPUnit"), ReportGenerator.

### OpenCover XML

- **Spec:** none published. The OpenCover repository has no XSD in its tree, and it was archived after its last push in November 2021 (GitHub API). The format is now defined by its emitters, mainly coverlet's `OpenCoverReporter` ([OpenCoverReporter.cs](https://github.com/coverlet-coverage/coverlet/blob/master/src/coverlet.core/Reporters/OpenCoverReporter.cs)).
- **Shape:** `CoverageSession > Modules > Module > Files/Classes > Class > Methods > Method > SequencePoints/BranchPoints`. Sequence points carry `vc` (visit count), `sl`, `sc`, `el`, `ec`. Branch points carry `vc`, `sl`, `path`, `offset`.
- **Measures:** sequence point (statement) with counts and spans, branch point, method.
- **Read by:** Codecov (`CSharpProcessor` matches root `CoverageSession`) ([csharp.py](https://github.com/codecov/umbrella/blob/main/apps/worker/services/report/languages/csharp.py)), ReportGenerator. Coveralls does not read it.

### coverage.py JSON

- **Spec:** the emitter code only. `FORMAT_VERSION = 3` ([jsonreport.py](https://github.com/coveragepy/coveragepy/blob/main/coverage/jsonreport.py)). The docs describe the command, not the schema ([cmd_json](https://github.com/coveragepy/coveragepy/blob/main/doc/commands/cmd_json.rst)).
- **Shape:** `meta` (with `branch_coverage` and `show_contexts`), `files.<path>` with `executed_lines`, `missing_lines`, `excluded_lines`, `executed_branches` and `missing_branches` as `[from, to]` arcs, per-function and per-class regions, and optional `contexts` (which test ran each line).
- **Measures:** line and branch as sets. **coverage.py records no execution counts in any output.** Its LCOV writes `DA:<line>,0|1` ([lcovreport.py](https://github.com/coveragepy/coveragepy/blob/main/coverage/lcovreport.py)). Compared with its LCOV and Cobertura output, the JSON adds exact arcs, excluded lines and contexts.
- **Read by:** Codecov (detected by `meta.show_contexts`) ([pycoverage.py](https://github.com/codecov/umbrella/blob/main/apps/worker/services/report/languages/pycoverage.py)). Coveralls reads the SQLite `.coverage` file by shelling out to `coverage xml` ([coveragepy_parser.cr](https://github.com/coverallsapp/coverage-reporter/blob/master/src/coverage_reporter/parsers/coveragepy_parser.cr)).

### SimpleCov `coverage.json`

- **Spec:** a published, versioned JSON Schema (2020-12), currently `coverage-v1.4.schema.json`. The project says released schema files never change ([Formatters.md](https://github.com/simplecov-ruby/simplecov/blob/main/docs/Formatters.md), [schema](https://github.com/simplecov-ruby/simplecov/blob/main/schemas/coverage-v1.4.schema.json)). This is new with SimpleCov 1.x (1.3.2 released 2026-09-30). The project calls `.resultset.json` a private cache and says not to build on it.
- **Measures:** line counts, where each entry is an integer count, `null` for a non-executable line, or `"ignored"`. Branches and methods have counts. There are optional per-test contexts. This is the most explicit three-way "count / not code / excluded" encoding in this survey.
- **Read by:** Codecov's SimpleCov processor expects the older third-party `simplecov-json` gem's shape ([simplecov.py](https://github.com/codecov/umbrella/blob/main/apps/worker/services/report/languages/simplecov.py)), and Codecov's docs tell Ruby users to emit LCOV or Cobertura instead ([Codecov supported formats](https://docs.codecov.com/docs/supported-report-formats)). Coveralls has a `simplecov` parser.

### gcov JSON

- **Spec:** documented in the GCC manual: `format_version` "2", gzipped `.gcov.json.gz`, with per-line `count`, `branches`, `calls` and `conditions` ([gcov.texi](https://github.com/gcc-mirror/gcc/blob/master/gcc/doc/gcov.texi)). The manual tells consumers to use this format rather than the text output.
- **Read by:** gcovr and lcov, which convert it to the formats above. Codecov and Coveralls read the text `.gcov` form.

### kcov output

kcov is not a format of its own. Its JSON is a summary only: per-file `percent_covered` and totals, no per-line data ([json-writer.cc](https://github.com/SimonKagstrom/kcov/blob/master/src/writers/json-writer.cc)). Its useful machine output is Cobertura, which has the caveats above. kcov matters because it collects coverage from DWARF without compiler flags, for "compiled languages, Python and Bash" ([kcov README](https://github.com/SimonKagstrom/kcov/blob/master/README.md)). It also matters for Shell, which no other tool here handles.

### Formats owned by uploaders and platforms

These exist, but attra would only ever write them: Codecov's custom JSON, the Coveralls JSON API (`source_files`), SonarQube generic coverage XML (per-line `covered` boolean plus branch counts, **no hit counts**) ([Sonar generic test data](https://docs.sonarsource.com/sonarqube-server/analyzing-source-code/test-coverage/generic-test-data)), and Microsoft's binary `.coverage`.

## What uploaders and platforms accept

| Format | Codecov | Coveralls | GitLab | Azure Pipelines v2 |
|---|---|---|---|---|
| LCOV | yes | yes | no | yes (`.lcov`) |
| Cobertura | yes | yes | yes | yes |
| JaCoCo | yes | yes | yes | yes (documented as needing `pathToSources`) |
| Go coverprofile | yes | yes | no | not listed |
| Clover | yes | yes | no | not listed |
| Istanbul JSON | yes (NodeProcessor) | no | no | not listed |
| OpenCover | yes (CSharpProcessor) | no | no | not listed |
| coverage.py | JSON | SQLite via `coverage xml` | no | "pycov" |
| SimpleCov | `simplecov-json` dialect only | yes | no | no |
| gcov text | yes | yes | no | no |
| llvm-cov JSON | no | no | no | no |

Sources: Codecov's docs list processors by name and language ([supported report formats](https://docs.codecov.com/docs/supported-report-formats)). The processors' detection code is in the open-source worker, now in [`codecov/umbrella`](https://github.com/codecov/umbrella/tree/main/apps/worker/services/report/languages); the old `codecov/worker` repository is archived. Codecov detects formats by content (root tag, first line, JSON keys), not by file name. Coveralls lists `lcov`, `simplecov`, `cobertura`, `jacoco`, `gcov`, `luacov`, `golang`, `python`, `coveralls`, `clover` ([coverage-reporter README](https://github.com/coverallsapp/coverage-reporter/blob/master/README.md), [parsers](https://github.com/coverallsapp/coverage-reporter/tree/master/src/coverage_reporter/parsers)). GitLab accepts "a Cobertura or JaCoCo XML report" ([GitLab](https://docs.gitlab.com/ci/testing/code_coverage/)). Azure Pipelines lists ".coverage, .covx, .covb, .cjson, .xml, .lcov, pycov, etc." ([Azure](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/publish-code-coverage-results-v2)). ReportGenerator, the converter most .NET teams use, reads OpenCover, dotCover, Visual Studio, NCover, Cobertura, JaCoCo, Clover, Scoverage, Mono, gcov and LCOV ([ReportGenerator](https://github.com/danielpalme/ReportGenerator)).

## How widely each is used

There is no public count of reports by format, and none is invented here. The proxies below are first-party download counters. They count CI installs as well as people, so they show order of magnitude only.

- **JavaScript:** `istanbul-reports`, the package behind every JS reporter including LCOV, Clover, Cobertura and Istanbul JSON, had 100,573,983 npm downloads in the week 2026-10-26 to 2026-11-01. `@vitest/coverage-v8` had 58,712,529 that week ([npm downloads API](https://api.npmjs.org/downloads/point/last-week/istanbul-reports)).
- **Python:** `coverage` had 78,403,881 downloads in the last week and `pytest-cov` had 57,753,109 ([pypistats](https://pypistats.org/api/packages/coverage/recent)).
- **.NET:** `coverlet.collector` has 1,122,444,255 total NuGet downloads, `Microsoft.CodeCoverage` has 1,966,296,766, and `Microsoft.Testing.Extensions.CodeCoverage` has 41,034,374 (NuGet search API). Both main paths can produce Cobertura.
- **Ruby:** `simplecov` has 515,659,420 total downloads. Its LCOV and Cobertura plugin gems have 52,125,675 and 71,086,195 (RubyGems API). So a minority of Ruby users install a plugin to get an interchange format.
- **Defaults that put files in repos without anyone choosing them:** Jest writes `clover.xml`, `coverage-final.json` and `lcov.info` by default. Vitest writes `clover.xml` and `coverage-final.json` by default. Flutter writes `lcov.info`. Coverlet's VSTest collector writes Cobertura. Go has exactly one text format.

## Why this v1 list

The map asks for breadth bounded by a decided list, with each format done exactly before the next. Five criteria decide the order: how many languages a format reaches, whether a language has any other way out, whether CI platforms require the format, whether the format keeps data others drop, and how well it is specified.

1. **LCOV** is the one format every ecosystem in this survey can write: JS, Python, C#, C/C++, Rust, Swift, Dart and Ruby (by plugin). Codecov, Coveralls and Azure read it, and it has the most complete spec. Downsides: the spec is moving (2.2, 2.3, and unreleased master changes), so the parser has to accept 1.x records, 2.x records and the unknown records later versions add.
2. **Cobertura** is the second interchange format, and the only one besides JaCoCo that GitLab accepts. It is the default for coverlet's VSTest collector, coverage.py `xml`, kcov and tarpaulin `--out xml`. Its required rate attributes force emitters to make up branch numbers, so the parser should build the coverage set from `<line>` elements alone.
3. **JaCoCo** is the only machine-readable format for the JVM (Java 4th, Kotlin through Kover). Without it, Java is not covered. GitLab and both uploaders accept it.
4. **Go coverprofile** is the only format Go writes. The Go toolchain itself has no LCOV or Cobertura writer, so this format is the only way Go gets in.
5. **Istanbul JSON** carries statement, function and branch counts with columns for TypeScript and JavaScript, the top languages. JS projects can also emit LCOV, but LCOV loses statement spans and branch types, and Jest and Vitest already write Istanbul JSON by default. It is cheap to parse and lets the coverage set hold span-level data from day one.
6. **llvm-cov export JSON** is the only source of region and MC/DC measures with columns, and it is the native output for Clang C/C++, Rust and Swift. Without it, the measure model would be designed around line and branch only. Uploaders don't read it, but that matters for writing, not reading.

Why the second tier waits:

- **Clover:** PHPUnit can write Cobertura, and Jest and Vitest also write LCOV and Istanbul JSON. Clover adds no measure those lack. It comes in two dialects (PHPUnit's Clover and OpenClover).
- **OpenCover:** no spec, upstream archived, and both main .NET tool families write Cobertura. Its value is per-sequence-point counts and spans for C#.
- **coverage.py JSON:** Python already reaches attra through Cobertura and LCOV, and coverage.py has no counts in any output. The JSON adds exact arcs, excluded lines and per-test contexts, which matter for patch coverage precision. It is a good first addition after v1.
- **SimpleCov `coverage.json`:** Ruby is outside the top eight, but this is the best-specified JSON format in the survey and the only one with an explicit "not code / excluded / count" encoding. Also a good early addition.
- **gcov JSON:** gcovr and lcov already turn it into v1 formats, and C/C++ users of Clang get llvm-cov.

## Findings that affect other tickets

- **Data model, "not recorded" vs zero.** Formats differ in what "covered" means. JaCoCo has instruction counts per line and no execution counts. coverage.py and Sonar have only booleans. Go `set` mode has only booleans. LCOV, Istanbul, llvm-cov, OpenCover and SimpleCov have real counts. The coverage set needs to know whether a count is a real count or a 0/1 flag, or merges will add booleans to counts. LCOV's `-`, llvm's `hasCount` and SimpleCov's `null` and `"ignored"` are explicit "not recorded" markers that the model has to keep. Cobertura's required rate attributes are an explicit source of invented data.
- **Measures.** The union across v1 formats is line, statement, function, branch, region, MC/DC, plus JaCoCo's instruction, class and complexity. Branch identity varies. LCOV and llvm have per-branch identity. Cobertura and JaCoCo have only per-line totals. Istanbul has per-arm counts with types. Converting branches from Cobertura or JaCoCo to LCOV cannot produce real `BRDA` block and branch IDs.
- **Merge.** Go's reference parser already defines a merge for duplicate blocks (OR in `set` mode, sum otherwise, error on a `NumStmt` mismatch). LCOV merges branch blocks by signature and order and documents that this can be ambiguous with macros and templates ([geninfo.rst](https://github.com/linux-test-project/lcov/blob/master/docs/man/geninfo.rst)).
- **Path normalization.** Istanbul keys are absolute paths. Go uses import paths. JaCoCo has package plus local file name. Cobertura has `<sources>` roots plus `filename`. Clover has an OS-specific `path`. gcov JSON records `current_working_directory`. Each needs its own rule.
- **Format detection.** Cobertura and Clover share the `<coverage>` root element. Codecov uses `generated` to tell them apart. Detection by content, as Codecov does it, is a tested precedent.
- **Conversion targets.** Writing LCOV plus Cobertura reaches Codecov, Coveralls, GitLab (Cobertura) and Azure. Writing Cobertura without branch data means writing required `branch-rate` attributes, which conflicts with "never invent data". The writer will need a documented convention for that case.
- **Size budgets.** llvm-cov export JSON is the largest and is made of positional arrays. Istanbul JSON is also large. Measure real files from both before setting budgets.
- **.NET CI.** Microsoft.Testing.Platform 2.4 added a first-class coverage result model with thresholds, and a failed threshold exits with code `14` ([MTP code coverage](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-platform-extensions-code-coverage)). That overlaps with attra's gates in .NET repos, which matters for migration.
- **Go collection is changing.** Since Go 1.20 there is a binary `GOCOVERDIR` format, but `go tool covdata textfmt` still produces the coverprofile, so v1 can stay with the text format.
- **Zig.** kcov is the existing route for compiled languages without compiler instrumentation, and it writes Cobertura with fabricated branch rates. Zig users who adopt attra before the rewrite spike lands will likely arrive with kcov Cobertura.
