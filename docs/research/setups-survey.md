# Existing coverage setups adoption must detect

Research for [#12](https://github.com/CraftsmanLabs/attra/issues/12), part of [Map: attra coverage v1](https://github.com/CraftsmanLabs/attra/issues/8). It feeds [#17](https://github.com/CraftsmanLabs/attra/issues/17), which decides how adoption splits between attra and the user's agent. Sources were read on 2026-11-02. Terms follow `GLOSSARY.md`: report, format, coverage set, merge, patch coverage, adoption, migration, setup. Which formats each tool writes is covered in the [formats survey](https://github.com/CraftsmanLabs/attra/blob/research/formats-survey/docs/research/formats-survey.md) and not repeated here.

## Short answer

- A coverage setup has three parts, and adoption has to find all three: a **producer** (the test run with coverage turned on), a **report** (a file on disk in some format), and a **consumer** (an upload step to a hosted service, or a local threshold check). Hosted services are only the consumer. Most of the hard detection is in the producer.
- **Codecov dominates.** `codecov/codecov-action` appears in about 187,000 workflow files on GitHub. The next upload actions are SonarQube's (about 16,500, not all of which carry coverage) and Coveralls' (about 14,600). Qlty, Codacy and DeepSource are each under 2,000. Code Climate's action still appears in about 3,500 files, but Code Climate's API was turned off on 2025-07-18, so those steps are dead. Counts and method are below.
- **Consumers are easy to detect and replace deterministically.** Each service has one official action with a fixed `uses:` name and a documented input list, plus a fixed config file name. A tool can find them by exact match and parse them.
- **Producers are where judgment is needed.** In a sample of 137 live workflows that use Codecov, 31 (23%) had no visible coverage command in the workflow at all. Coverage was turned on inside `npm test`, a Makefile, tox, a test helper, or another action. Config for Jest, Vitest, nyc and Gradle is often executable code (`jest.config.js`, `build.gradle.kts`), which a deterministic tool can read only when it is a plain literal.
- **Report paths are often implicit.** 57 of 143 Codecov steps in the sample (40%) set no `files:` input, so the action finds reports itself with 24 glob patterns and also runs `coverage xml` and `gcov` on its own. Attra can copy those patterns, but it sees the repo, not the CI workspace. Knowing which file actually got uploaded needs either a run in CI or the agent's reading of the build.
- **Gates live in two places**: the service config (`codecov.yml` `coverage.status`) and the tool config (`fail_under`, `coverageThreshold`, `thresholds`, `jacocoTestCoverageVerification`, `--fail-under-lines`, SimpleCov `minimum`). Fixed-number thresholds map across deterministically. Codecov's default `target: auto` compares against the base commit's coverage, which attra can only reproduce if it has a base coverage set to compare against.
- **Deterministic**: finding upload steps and service configs, reading their inputs, reading static tool config, applying documented default output paths, removing dead Code Climate steps, rewriting an upload step whose `files:` is explicit, and mapping numeric thresholds.
- **Judgment**: where coverage is turned on when it is hidden in scripts or code config, which report a search-based uploader actually sent, whether to keep the hosted service (attra v1 has no dashboard or history), how to treat Codecov flags, carryforward and `target: auto`, and setups where the test command is custom.

## How prevalence was measured

Counts come from the GitHub REST code search API (`GET /search/code`, field `total_count`), run on 2026-11-02 with `gh api -X GET search/code -f q='<query>'`. That API searches the default branch of non-fork repos and its counts are estimates, so treat them as orders of magnitude and compare them only with each other. A count is of files, not repos. Queries for action names were limited to `path:.github/workflows`.

The sample is the first 200 results of `"codecov/codecov-action" path:.github/workflows`, sorted by GitHub's best match. 63 of the 200 were not live workflows (`.yml.disabled`, `.bak`, `.md`, `actions.lock` and similar), which says best-match ranking favors files that mention the name heavily and that detection must only read `*.yml` and `*.yaml` directly in `.github/workflows/`. GitHub only runs workflows from that directory ([workflow syntax](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions)). The remaining 137 live files were checked with regular expressions, so the figures from them are rough.

| Query | Files |
|---|---|
| `"codecov/codecov-action"` in workflows | 186,624 |
| `"SonarSource/sonarqube-scan-action"` in workflows | 16,480 |
| `"coverallsapp/github-action"` in workflows | 14,592 |
| `"SonarSource/sonarcloud-github-action"` in workflows (deprecated) | 11,984 |
| `"paambaati/codeclimate-action"` in workflows (dead service) | 3,456 |
| `"codacy/codacy-coverage-reporter-action"` in workflows | 1,956 |
| `"qltysh/qlty-action/coverage"` in workflows | 948 |
| `"cc-test-reporter"` in workflows (dead service) | 623 |
| `"deepsource report"` in workflows | 252 |
| `"deepsourcelabs/test-coverage-action"` in workflows | 91 |
| `filename:codecov.yml` / `filename:.codecov.yml` | 50,816 / 14,944 |
| `filename:sonar-project.properties` / with the word `coverage` | 63,488 / 33,408 |
| `filename:.coveralls.yml` | 13,120 |
| `filename:.codeclimate.yml` | 12,400 |
| `filename:.deepsource.toml` | 6,496 |
| `filename:.codacy.yml` | 1,920 |
| `filename:qlty.toml path:.qlty` | 610 |
| `"--cov"` in workflows (pytest-cov) | 185,088 |
| `"--cov-report"` in workflows | 104,704 |
| `"--coverage"` in workflows (Jest, Vitest, gcc and others) | 57,216 |
| `"-coverprofile"` in workflows | 35,520 |
| `"coverage run"` in workflows | 20,800 |
| `"XPlat Code Coverage"` in workflows (coverlet collector) | 10,496 |
| `"cargo llvm-cov"` in workflows | 10,320 |
| `"jacocoTestReport"` in workflows | 7,016 |
| `"cargo tarpaulin"` in workflows | 3,416 |
| `"CollectCoverage=true"` in workflows (coverlet msbuild) | 3,024 |
| `"kcov"` in workflows | 694 |

Thresholds and tool config, outside workflows: `filename:codecov.yml target` 25,472; `fail_under filename:pyproject.toml` 28,864; `fail_under filename:.coveragerc` 3,680; `coverageThreshold filename:jest.config.js` 41,024 (of 348,160 `jest.config.js` files); `thresholds coverage filename:vitest.config.ts` 42,624; `jacocoTestCoverageVerification filename:build.gradle` 8,752; `"jacoco-maven-plugin" filename:pom.xml` 122,880; `SimpleCov.start language:ruby` 40,320. `"coverlet.collector" extension:csproj` returned 332,800, but that number does not measure use, because `dotnet new xunit` adds the package by default (see coverlet below).

What the sample of 137 live Codecov workflows showed:

- 143 Codecov steps. 86 set `files:` or `file:`, 57 rely on search. 34 set `flags:`. 79 pass a token, 2 use OIDC.
- Pinned versions: v4 33, v5 25, v1 23, v3 17, v7 15, a commit SHA 14, v2 9, v6 8, `main` 1. About a third pin a major version older than v4, so adoption must read every input name across action versions, not only the current `action.yml`.
- 31 files had no visible coverage command. Examples: `yarn test` with coverage set in Jest config, Julia's `julia-actions/julia-processcoverage` (22 of the 200 files), MATLAB's `matlab-actions/run-command`.
- Other coverage actions in the same files: `codecov/test-results-action`, `py-cov-action/python-coverage-comment-action`, `coverallsapp/github-action`, `actions-rs/grcov`. Five files also sent coverage to Coveralls, so one repo can feed two consumers from one report.
- 117 of 200 used a `matrix`, which means several jobs each produce a report for the same commit. That is a merge in glossary terms.

## Hosted services

Each row lists the official action, the inputs that matter for migration, the config files, and the signals that show the service is in use.

### Codecov

- **Action**: `codecov/codecov-action`, latest v7.1.1. A composite action that downloads and runs the Codecov CLI ([action.yml](https://github.com/codecov/codecov-action/blob/main/action.yml)).
- **Inputs that matter**: `files` (explicit reports, added to the search results unless `disable_search` is set), `directory`, `exclude`, `disable_search`, `flags`, `name`, `token`, `use_oidc`, `fail_ci_if_error`, `plugins`, `root_dir`, `network_prefix`/`network_filter`, `report_type` (`coverage` or `test_results`), `working-directory` ([action.yml](https://github.com/codecov/codecov-action/blob/main/action.yml)).
- **Search**: when `files` is not the only source, the CLI looks for 24 patterns, including `*coverage*.*`, `lcov.info`, `*.lcov`, `cobertura.xml`, `jacoco*.xml`, `cover.out`, `coverage-final.json`, `*.gcov` and `clover.xml`, minus a long exclude list ([file_finder.py](https://github.com/codecov/codecov-cli/blob/main/codecov_cli/services/upload/file_finder.py)).
- **Plugins run by default**: `xcode`, `gcov` and `pycoverage` ([upload.py](https://github.com/codecov/codecov-cli/blob/main/codecov_cli/commands/upload.py)). The `pycoverage` plugin finds `.coverage` data files, runs `coverage combine` and `coverage xml` itself ([pycoverage.py](https://github.com/codecov/codecov-cli/blob/main/codecov_cli/plugins/pycoverage.py)). So a repo can upload Python coverage to Codecov without ever writing a report file.
- **Config**: `codecov.yml` or `.codecov.yml`, in the repo root, `dev/` or `.github/` ([Codecov YAML](https://docs.codecov.com/docs/codecov-yaml)). Gates are in `coverage.status.project` and `coverage.status.patch`, each with `target` (`auto` or a percent), `threshold` (allowed drop), `flags`, `paths`, `informational`, `only_pulls` and `if_ci_failed` ([commit status](https://docs.codecov.com/docs/commit-status)).
- **Signals**: the `uses:` line; `codecov.yml` in one of three places; `CODECOV_TOKEN` in workflow secrets references; a Codecov badge in the README.

### Coveralls

- **Action**: `coverallsapp/github-action`, latest v2.3.8. Composite, runs the universal `coverage-reporter` ([action.yml](https://github.com/coverallsapp/github-action/blob/main/action.yml)).
- **Inputs**: `file`, `files`, `format` (lcov, simplecov, cobertura, jacoco, gcov, golang, python), `flag-name`, `parallel`, `parallel-finished`, `carryforward`, `base-path`, `compare-ref`, `compare-sha`, `allow-empty`, `fail-on-error`. `path-to-lcov` is marked deprecated ([action.yml](https://github.com/coverallsapp/github-action/blob/main/action.yml)).
- **Search**: each parser has globs, for example `lcov.info` and `**/*/lcov.info`, `cobertura.xml` and `*coverage.xml`, `**/*/jacoco*.xml`, `.resultset.json`, and `.coverage` ([parsers](https://github.com/coverallsapp/coverage-reporter/tree/master/src/coverage_reporter/parsers)). The Python parser reads coverage.py's SQLite file by shelling out to `coverage xml` ([coveragepy_parser.cr](https://github.com/coverallsapp/coverage-reporter/blob/master/src/coverage_reporter/parsers/coveragepy_parser.cr)). The Go parser has no globs and only matches files it is given ([golang_parser.cr](https://github.com/coverallsapp/coverage-reporter/blob/master/src/coverage_reporter/parsers/golang_parser.cr)).
- **Config**: `.coveralls.yml`, read by default ([coverage-reporter README](https://github.com/coverallsapp/coverage-reporter/blob/master/README.md)).
- **Parallel builds**: one step per job with `parallel: true`, and a final job with `parallel-finished: true` ([action.yml](https://github.com/coverallsapp/github-action/blob/main/action.yml)). Migration has to remove the finishing job too.
- **Signals**: the `uses:` line; `.coveralls.yml`; a `coveralls` CLI call.

### Qlty (successor to Code Climate)

- **Action**: `qltysh/qlty-action/coverage`, latest release v2.5.0. A Node action that wraps `qlty coverage publish` ([coverage/action.yml](https://github.com/qltysh/qlty-action/blob/main/coverage/action.yml), [Qlty quickstart](https://docs.qlty.sh/coverage/quickstart)).
- **Inputs**: `files`, `format` (clover, cobertura, coverprofile, jacoco, lcov, qlty, simplecov, dotcover, xccov-json), `add-prefix`, `strip-prefix`, `tag`, `token` or `oidc`, `total-parts-count`, `command` (`publish` or `complete`), `incomplete`, `validate` ([coverage/action.yml](https://github.com/qltysh/qlty-action/blob/main/coverage/action.yml)).
- **Config**: `.qlty/qlty.toml`, present in the action's own repo ([qlty-action tree](https://github.com/qltysh/qlty-action/tree/main/.qlty)). The quickstart documents no coverage keys in it; the upload is configured in the workflow.
- **Signals**: the `uses:` line; `QLTY_COVERAGE_TOKEN`; `qlty coverage publish`.

### Code Climate

- **Status**: dead. The Code Climate API "was disabled on July 18, 2025", and remaining `cc-test-reporter` uploads fail CI ([Qlty migration guide](https://docs.qlty.sh/migration/coverage)). The community action `paambaati/codeclimate-action` is archived and points to Qlty ([README](https://github.com/paambaati/codeclimate-action/blob/main/README.md)).
- **Inputs** of the old action: `coverageCommand`, `workingDirectory`, `coverageLocations` (lines of `<path>:<type>`), `prefix`, with the reporter ID in `CC_TEST_REPORTER_ID` ([action.yml](https://github.com/paambaati/codeclimate-action/blob/main/action.yml), [README](https://github.com/paambaati/codeclimate-action/blob/main/README.md)).
- **Note for migration**: `coverageCommand` is the test command itself. Removing the step removes the test run, so migration must keep the command and only drop the upload.
- **Signals**: `paambaati/codeclimate-action`, `cc-test-reporter` (`before-build`, `after-build`, `format-coverage`, `upload-coverage`), `CC_TEST_REPORTER_ID`, `.codeclimate.yml`.

### SonarQube Server and SonarQube Cloud

- **Action**: `SonarSource/sonarqube-scan-action`, latest v8.4.0, with `args` and `projectBaseDir` ([action.yml](https://github.com/SonarSource/sonarqube-scan-action/blob/master/action.yml)). `SonarSource/sonarcloud-github-action` is archived and deprecated in favor of it ([README](https://github.com/SonarSource/sonarcloud-github-action/blob/master/README.md)). Maven and Gradle projects often scan with `mvn sonar:sonar` or the Gradle Sonar plugin instead of the action.
- **Sonar does not collect coverage.** It reads report paths from analysis parameters, one per language: `sonar.python.coverage.reportPaths` (Cobertura), `sonar.javascript.lcov.reportPaths`, `sonar.go.coverage.reportPaths`, `sonar.coverage.jacoco.xmlReportPaths`, `sonar.cs.opencover.reportsPaths` / `sonar.cs.cobertura.reportsPaths` / `sonar.cs.vscoveragexml.reportsPaths` / `sonar.cs.dotcover.reportsPaths`, `sonar.ruby.coverage.reportPaths` (SimpleCov JSON), `sonar.rust.lcov.reportPaths` / `sonar.rust.cobertura.reportPaths`, `sonar.php.coverage.reportPaths` (Clover), `sonar.cfamily.*`, and the language-neutral `sonar.coverageReportPaths` (Sonar generic XML) ([test coverage parameters](https://docs.sonarsource.com/sonarqube-cloud/enriching/test-coverage/test-coverage-parameters/)).
- **Config**: `sonar-project.properties`, the action's `args: -Dsonar...=...`, Maven `<properties>`, or the Gradle `sonar {}` block.
- **Signals**: the scan action or plugin, plus any `*.reportPath(s)` key. A scan without those keys is static analysis only and has nothing for coverage migration to replace. Half of the `sonar-project.properties` files found contain the word `coverage`.
- **Migration note**: Sonar also runs static analysis, and its quality gate is set in Sonar's server, not in the repo. Migration can only ever replace its coverage input, so it is closer to "make attra write a report Sonar reads" than "remove Sonar". That needs Sonar generic XML or another Sonar-readable format among attra's conversion targets.

### Codacy

- **Action**: `codacy/codacy-coverage-reporter-action`, latest v1.3.0. Composite: it runs `bash <(curl -Ls https://coverage.codacy.com/get.sh) report ... --partial` and then `final` ([action.yml](https://github.com/codacy/codacy-coverage-reporter-action/blob/master/action.yml)). Many repos call `get.sh` directly.
- **Inputs**: `project-token` or `api-token`, `coverage-reports` (comma separated), `language`, `force-coverage-parser` ([action.yml](https://github.com/codacy/codacy-coverage-reporter-action/blob/master/action.yml)).
- **Formats and names**: OpenCover, dotCover, Cobertura, LCOV, JaCoCo, PHPUnit XML and Clover, Go ([Codacy coverage reporter docs](https://docs.codacy.com/coverage-reporter/)).
- **Signals**: the `uses:` line, `coverage.codacy.com/get.sh`, `CODACY_PROJECT_TOKEN` or `CODACY_API_TOKEN`. `.codacy.yml` configures analysis and is not a coverage signal by itself.

### DeepSource

- **Action**: `deepsourcelabs/test-coverage-action`, latest v1.1.3, a Docker action with `key` (language: python, go, javascript, ruby, java, kotlin, scala, php, csharp, cxx, rust, swift), `coverage-file`, `dsn`, `fail-ci-on-error` ([action.yml](https://github.com/deepsourcelabs/test-coverage-action/blob/master/action.yml)).
- **CLI**: `deepsource report --analyzer test-coverage --key <key> --value-file <report>`, with `--use-oidc` on GitHub Actions or `DEEPSOURCE_DSN`. The analyzer is enabled in the dashboard ([DeepSource test coverage](https://docs.deepsource.com/docs/analyzers-test-coverage)).
- **Signals**: the action, `deepsource report`, `DEEPSOURCE_DSN`. `.deepsource.toml` alone does not mean coverage is sent.

## How each language turns coverage on

For each tool: how it is turned on, where its config lives, where the report lands by default, how thresholds are set. Formats are in the [formats survey](https://github.com/CraftsmanLabs/attra/blob/research/formats-survey/docs/research/formats-survey.md).

### Python: coverage.py and pytest-cov

- **On**: `coverage run -m pytest` then `coverage xml|lcov|json`, or `pytest --cov=<pkg> --cov-report=xml`. pytest-cov reports include term, term-missing, html, xml, json, markdown and lcov, and `--cov-fail-under MIN` sets a gate ([pytest-cov config](https://pytest-cov.readthedocs.io/en/latest/config.html)).
- **Hidden switches**: the flags often sit in `addopts`, in `[tool.pytest.ini_options]` of `pyproject.toml` or `[tool:pytest]` of `setup.cfg` ([pytest-cov config](https://pytest-cov.readthedocs.io/en/latest/config.html)), so a bare `pytest` in CI can produce coverage. Also check `tox.ini` and `noxfile.py`.
- **Config**: `.coveragerc`, then `.coveragerc.toml`, `setup.cfg` (`[coverage:run]`), `tox.ini` (`[coverage:run]`), `pyproject.toml` (`[tool.coverage.run]`) ([coverage.py config](https://coverage.readthedocs.io/en/latest/config.html)).
- **Defaults**: data file `.coverage`, XML `coverage.xml`, LCOV `coverage.lcov`. Gate: `[report] fail_under`, exit code 2 when below ([coverage.py config](https://coverage.readthedocs.io/en/latest/config.html)).
- **Deterministic?** Yes for INI and TOML. Python's own config formats are static.

### JavaScript and TypeScript: Jest, Vitest, nyc, c8

- **Jest**: `collectCoverage` defaults to `false`; `--coverage` turns it on. Default reporters are `clover`, `json`, `lcov`, `text`; `coverageProvider` is `babel` or `v8`; `coverageThreshold` is the gate. Config is `jest.config.js|ts|mjs|mts|cjs|cts|json` or the `jest` key in `package.json` ([Jest config](https://jestjs.io/docs/configuration)). The output directory defaults to `<rootDir>/coverage` ([normalize.ts](https://github.com/jestjs/jest/blob/main/packages/jest-config/src/normalize.ts)).
- **Vitest**: `coverage.enabled` defaults to `false`, provider defaults to `v8`, reporters to `text`, `html`, `clover`, `json`, directory to `./coverage`; gates are under `coverage.thresholds` ([Vitest coverage config](https://vitest.dev/config/coverage)). Config is `vitest.config.*` or the `test` block of `vite.config.*`.
- **nyc**: config in `package.json`, `.nycrc`, `.nycrc.json`, `.nycrc.yaml`, `.nycrc.yml` (and JS variants); `reporter` defaults to `['text']`; `check-coverage` gates ([nyc README](https://github.com/istanbuljs/nyc/blob/main/README.md)).
- **c8**: looks for `.c8rc`, `.c8rc.json`, `.nycrc`, `.nycrc.json`; `--reporter` defaults to `text`; `--check-coverage` with `--lines` and friends gates ([c8 README](https://github.com/bcoe/c8/blob/main/README.md)).
- **Hidden switches**: `package.json` scripts (`"test": "jest --coverage"`) and CI calls like `npm test` or `pnpm test:cov`. Scripts are static JSON and can be read.
- **Deterministic?** Partly. `package.json`, `.nycrc*`, `.c8rc*` and `jest.config.json` are data. `jest.config.js|ts` and `vitest.config.ts` are programs. A tool can parse the common literal-object shape, but anything computed needs the agent, or running the tool's own config printer (for example `jest --showConfig`).

### Go

- **On**: `go test -coverprofile=<file>`, which implies `-cover`. `-covermode` is `set` (default), `count` or `atomic` ([Go blog: The cover story](https://go.dev/blog/cover)). Integration binaries built with `go build -cover` write to `GOCOVERDIR` instead (see formats survey).
- **Config**: none; everything is in the command, often inside a Makefile target.
- **Gates**: none built in. Repos script one around `go tool cover -func` ([Go blog](https://go.dev/blog/cover)).
- **Deterministic?** Yes when the command is in the workflow. The output path is always on the command line.

### Rust: cargo-llvm-cov and tarpaulin

- **cargo-llvm-cov**: `cargo llvm-cov --lcov --output-path lcov.info`, with `--json`, `--cobertura`, `--codecov` as alternatives; without `--output-path` the report goes to stdout. Gates: `--fail-under-lines`, `--fail-under-functions`, `--fail-under-regions`, `--fail-under-file-lines`, `--fail-uncovered-lines` ([cargo-llvm-cov README](https://github.com/taiki-e/cargo-llvm-cov/blob/main/README.md)).
- **tarpaulin**: `cargo tarpaulin --out Xml|Lcov|Json|Html`, `--output-dir`, `--fail-under`; config in `.tarpaulin.toml` or `tarpaulin.toml` ([tarpaulin README](https://github.com/xd009642/tarpaulin/blob/develop/README.md)).
- **Deterministic?** Yes. Flags and TOML are static. A stdout redirect (`> lcov.info`) has to be followed.

### Java and Kotlin: JaCoCo

- **Gradle**: apply `jacoco`; tasks `jacocoTestReport` and `jacocoTestCoverageVerification` (with `violationRules { rule { limit { ... } } }`) ([Gradle JaCoCo plugin](https://docs.gradle.org/current/userguide/jacoco_plugin.html)). Only the HTML report is on by default; XML must be turned on with `xml.required = true`, and lands at `build/reports/jacoco/<test task>/<report task>.xml`, so `build/reports/jacoco/test/jacocoTestReport.xml` for the default task ([JacocoPlugin.java](https://github.com/gradle/gradle/blob/master/platforms/jvm/jacoco/src/main/java/org/gradle/testing/jacoco/plugins/JacocoPlugin.java)). Multi-project builds often use the `jacoco-report-aggregation` plugin.
- **Maven**: `jacoco-maven-plugin` with goals `prepare-agent`, `report`, `check`, `merge`, `report-aggregate` and others ([JaCoCo Maven](https://www.jacoco.org/jacoco/trunk/doc/maven.html)). `report` defaults to `HTML,XML,CSV` in `${project.reporting.outputDirectory}/jacoco` (normally `target/site/jacoco/jacoco.xml`), reading `${project.build.directory}/jacoco.exec` ([report goal](https://www.jacoco.org/jacoco/trunk/doc/report-mojo.html)).
- **Deterministic?** Maven, yes: `pom.xml` is XML. Gradle, partly: `build.gradle` and `build.gradle.kts` are programs, and convention plugins in `buildSrc` or included builds often hold the JaCoCo setup. Asking Gradle (`./gradlew properties`, a tiny init script) is more reliable than parsing.

### C# and .NET: coverlet

- **Three packages**: `coverlet.collector` (`dotnet test --collect:"XPlat Code Coverage"`, writes `coverage.cobertura.xml` under `TestResults/<guid>/`), `coverlet.msbuild` (`dotnet test /p:CollectCoverage=true`, writes coverlet's own `coverage.json` in the test project unless `CoverletOutputFormat` is set), and `coverlet.console` ([coverlet README](https://github.com/coverlet-coverage/coverlet/blob/master/README.md)). The collector and msbuild packages do not work with Microsoft Testing Platform; `coverlet.MTP` replaces them there ([coverlet README](https://github.com/coverlet-coverage/coverlet/blob/master/README.md)).
- **Trap**: the README says `coverlet.collector` is already present in projects made with `dotnet new xunit` ([coverlet README](https://github.com/coverlet-coverage/coverlet/blob/master/README.md)). A `PackageReference` to it does not mean coverage is collected. The signal is the `--collect` argument or a `.runsettings` file that enables it.
- **Deterministic?** Mostly. `.csproj` and `.runsettings` are XML. The `<guid>` directory means the report path is a glob, not a name.

### Ruby: SimpleCov

- **On**: `require 'simplecov'; SimpleCov.start` at the top of the test helper (`spec/spec_helper.rb`, `test/test_helper.rb`, `rails_helper.rb`), or config in a `.simplecov` file at the root. The HTML and JSON formatters are now built in. Thresholds live in a `coverage :line do minimum 90 end` block in current versions, with older spellings still accepted ([SimpleCov README](https://github.com/simplecov-ruby/simplecov/blob/main/README.md)).
- **Trap**: Code Climate used to turn SimpleCov on implicitly; Qlty says it no longer does, so Ruby repos need explicit setup ([Qlty migration guide](https://docs.qlty.sh/migration/coverage)).
- **Deterministic?** No in general. Config is Ruby code, and the report exists only if the helper is loaded. A tool can grep for `SimpleCov.start` and common formatter names; the rest is for the agent.

### C, C++ and other compiled code: kcov, gcov

- **kcov**: wraps a binary at run time, `kcov <out-dir> <cmd>`, and writes Cobertura XML and JSON; `kcov --merge` combines earlier runs ([kcov README](https://github.com/SimonKagstrom/kcov/blob/master/README.md)).
- **gcov and lcov**: turned on by compiler flags (`--coverage`, `-fprofile-arcs -ftest-coverage`) usually set in CMake or Meson options, then `lcov --capture` or `gcovr`. Codecov runs `gcov` itself by default, so a C++ repo can upload coverage with no report step at all ([upload.py](https://github.com/codecov/codecov-cli/blob/main/codecov_cli/commands/upload.py)).
- **Deterministic?** kcov, yes when the command is in the workflow. gcov setups, mostly no: the switch is in build files, and the report step may be done by the uploader.

## What a deterministic tool can do

1. **Find consumers.** Exact match on `uses:` for the actions above, any version or SHA, in `.github/workflows/*.y{a,}ml` only, plus the CLI strings (`cc-test-reporter`, `coverage.codacy.com/get.sh`, `deepsource report`, `qlty coverage publish`, `coveralls`). Read each step's `with:`, `env:` and `if:`.
2. **Find service config.** `codecov.yml`/`.codecov.yml` in three places, `.coveralls.yml`, `.codeclimate.yml`, `.qlty/qlty.toml`, `sonar-project.properties` and Sonar keys in `pom.xml`, `build.gradle*` and action `args`.
3. **Find producers that are written down.** Coverage flags in workflow `run:` lines and `package.json` scripts; static config in `pyproject.toml`, `setup.cfg`, `tox.ini`, `.coveragerc`, `.nycrc*`, `.c8rc*`, `jest.config.json`, `tarpaulin.toml`, `pom.xml`, `.csproj`, `.runsettings`.
4. **Resolve report paths** from explicit inputs, or from documented defaults when nothing overrides them (coverage.py `coverage.xml`, Jest and Vitest `coverage/`, Maven `target/site/jacoco/jacoco.xml`, coverlet collector `TestResults/*/coverage.cobertura.xml`).
5. **Copy the uploaders' search** when no path is given. Codecov's and Coveralls' globs are published in their source and can be run against a CI workspace.
6. **Rewrite** an upload step whose reports are known into an `attra coverage` step, keeping the producer, `if:` conditions and matrix.
7. **Map fixed gates**: a numeric `target`, `fail_under`, `coverageThreshold.global`, `--fail-under-lines`, Codecov `patch` targets onto attra's patch coverage.
8. **Remove dead steps**: Code Climate uploads, keeping any `coverageCommand` as a plain `run:` step.
9. **Report what it found** as structured output, including what it could not resolve, so the agent starts from facts.

## What needs judgment

1. **Hidden producers**: coverage turned on in Makefiles, tox and nox, shell scripts, other actions (Julia, MATLAB), or code config (`jest.config.ts`, `build.gradle.kts`, Ruby helpers). 23% of the Codecov sample.
2. **Which file was really uploaded** when an uploader searched. A dry run in CI settles it. Codecov has a `dry_run` input that skips the upload ([action.yml](https://github.com/codecov/codecov-action/blob/main/action.yml)); attra could also run its own copy of the search in CI once and print what it found.
3. **Keep or drop the service.** Hosted dashboards and history are out of scope for v1, so migration that removes Codecov or Coveralls removes features the team may use: PR comments, badges, history. The likely default is "add attra beside the service and offer to remove it", which the user or agent decides.
4. **Codecov semantics that do not map one to one**: `target: auto` and `threshold` (relative to base coverage), `flags` (named slices of one commit's coverage), `carryforward` (reuse an older commit's coverage for a missing flag), `paths` and `component_management`, `informational`. Carryforward combines coverage across commits, which the map's merge rule forbids.
5. **Sonar**: keep it and feed it, since its coverage gate is configured on the server.
6. **Monorepos and matrices**: deciding which reports belong to one coverage set and where paths are rooted (`root_dir`, `base-path`, `add-prefix`, `strip-prefix` all exist because paths do not line up).
7. **Setup** in a repo with no coverage: choosing the tool, adding a dependency, picking a format attra reads, and editing the test command. Each step is a lookup table for common stacks, but the test command is the repo's own.

## Things that may change other tickets

- **Producer, not uploader, is the hard part.** #17 should expect the deterministic side to own consumers and static config and the agent to own hidden producers.
- **Codecov runs coverage tools itself.** Its default `pycoverage` and `gcov` plugins mean some repos have no report file anywhere. Migrating them means adding a report step, not just swapping the upload.
- **Code Climate is dead but still present** in thousands of workflow files. That is an easy first win for migration, and a clear case for a deterministic fix.
- **Sonar needs attra to write a format it reads.** That is relevant to the "Conversion targets" open question on the map.
- **Codecov's `target: auto`, flags and carryforward** touch patch coverage, the merge rule and storage. `auto` needs a base coverage set, which in a CI-only v1 means fetching the base commit's report from somewhere, such as an Actions artifact.
- **Old action versions are common.** About a third of sampled Codecov steps pin v1 to v3, whose inputs differ from v7, so parsing must cover every major version's inputs.
- **`coverlet.collector` is in the xunit template by default**, so presence of the package is a false positive for "coverage is on".
