# Report corpus

Real coverage reports, written by the real tools, for every candidate format in [Map: attra coverage v1](https://github.com/CraftsmanLabs/attra/issues/8). The corpus is organized by **emitter**, the tool that wrote the report, because one format means different things from different emitters. It is what the data-model work inspects, and later the golden test corpus for attra's parsers.

[`reports/INDEX.md`](reports/INDEX.md) lists every report by format and emitter, with each tool's exact version.

## Regenerating

```sh
corpus/generate.sh            # every emitter (needs Docker)
corpus/generate.sh go node    # some emitters
corpus/fetch-large.sh         # large real-world reports into corpus/large/ (git-ignored)
python3 -m unittest corpus/scripts/test_scripts.py
```

Each emitter in `emitters/<emitter>/` has a `Dockerfile` that pins its image and tool versions, and a `run.sh` that copies a sample into the container, runs the tool, and keeps its reports. `run.sh` uses the helpers in `emitters/lib.sh` (`tool`, `step`, `keep`, `note`), which log what ran. `scripts/manifest.py` turns that log into `reports/<emitter>/manifest.json`: tool versions, every command with its working directory, each report's format, size and sha256, and notes. `scripts/index.py` then writes `reports/INDEX.md`.

Reports are written inside the container under `/work/<sample>`, so absolute paths in them start there. Regenerating changes timestamps and some generated ids, so expect diffs in those fields even when nothing else changed.

To add an emitter, add `emitters/<name>/Dockerfile` and `run.sh`, and add a sample under `samples/` if no existing one fits. An optional `emitters/<name>/docker-args` holds extra `docker run` flags (kcov needs ptrace).

## Samples

Every sample is the same small program in a different language, so reports can be compared line by line. Each has:

- **Branches:** `classify(n)` with a compound condition and an if/else chain. Tests take only the "negative even" and "positive" arms.
- **Partial line:** `size(n)`, a ternary or one-line `if` where only the "small" side runs.
- **Multi-line statement:** `total(a, b, c)`, one call spread over several lines.
- **Uncalled function:** `never_called`, plus an unused function in the second source root.
- **User-excluded code:** `excluded(n)`, behind the tool's own marker (`LCOV_EXCL_*`, `pragma: no cover`, `istanbul ignore` / `c8 ignore`, `[ExcludeFromCodeCoverage]`, `@codeCoverageIgnore`, `:nocov:`, `coverage:ignore-*`, `cfg(not(tarpaulin_include))`). Go, Swift, JaCoCo and llvm-cov have no source exclusion marker, so those samples omit it.
- **Second source root:** a separate directory, package, crate, assembly or target.
- **Large generated file:** `samples/gen-big.sh` writes 1000 one-branch functions (4,500 to 7,500 lines), half of them called. Its header marks it as generated (Go's `Code generated ... DO NOT EDIT.` form for Go).

Language extras: C/C++ has a macro, a template instantiated twice, a `static inline` header function, and a three-condition decision for MC/DC. Rust has a macro and a generic. Swift has a generic. Java has a switch, a lambda and a record. C# has an async method. JS has a default argument and a short-circuit `||` chain. Go has a closure and a package no test imports.

## What the corpus holds

| Format | Emitters |
|---|---|
| LCOV | lcov geninfo (default, and branch + MC/DC), gcovr, llvm-cov, cargo-llvm-cov, tarpaulin, nyc, c8, Node test runner, coverage.py (line and branch), coverlet, simplecov-lcov (0.22 and 1.x), Dart `format_coverage` and `test_with_coverage` (branch + function), Swift llvm-cov |
| Cobertura XML | gcovr, coverage.py (line and branch), nyc, c8, coverlet, Microsoft.CodeCoverage, dotnet-coverage (empty run), PHPUnit (Xdebug, Xdebug path coverage, PCOV), simplecov-cobertura, cargo-llvm-cov, tarpaulin, kcov (shell and compiled) |
| JaCoCo XML | JaCoCo 0.8.16 (also CSV and the binary `jacoco.exec`) |
| Clover XML | OpenClover, PHPUnit Clover and OpenClover writers (Xdebug, path coverage, PCOV), nyc, c8 |
| Go coverprofile | `go test` in set, count and atomic modes, `-coverpkg=./...`, and `go tool covdata textfmt` from GOCOVERDIR data (binary data and `covdata func` kept too) |
| Istanbul JSON | nyc, c8 (`coverage-final.json`), plus nyc's `coverage-summary.json` |
| llvm-cov export JSON | clang 19 (format 2.0.1: full, summary-only, without expansions and functions), cargo-llvm-cov (3.1.0), SwiftPM (3.0.1) |
| OpenCover XML | coverlet |
| coverage.py | JSON (line, branch, contexts) and the `.coverage` SQLite data file |
| gcov JSON | GCC 15 `gcov --json-format` with branches and conditions |
| SimpleCov | `.resultset.json` and `coverage.json`, 0.22.0 and 1.3.2, line and branch (+ method on 1.x) |
| Others | V8 `NODE_V8_COVERAGE`, tarpaulin JSON, coverlet JSON, gcovr JSON, Dart VM hitmap JSON, kcov `coverage.json` and SonarQube XML, Codecov JSON (kcov, cargo-llvm-cov), Microsoft `.coverage` XML |

### Large real-world reports

`fetch-large.sh` downloads two real workloads named by the report-sizes research into `corpus/large/`, with a `SOURCE.txt` naming the build, commit and URL:

- **kubernetes:** the newest `ci-kubernetes-coverage-unit` build's `combined-coverage.out` (Go coverprofile, atomic mode, about 24 MB) from Prow's public bucket.
- **home-assistant:** every `coverage-*` artifact (coverage.py Cobertura, one per pytest shard and database variant, about 80 MB) from the newest successful `CI` run on `dev`. Needs `gh` logged in. GitHub expires the artifacts after about a week, so the script always takes the newest run.

They're too large to commit and change daily, so tests that need them should fetch them and skip when absent.

## Findings

Facts the corpus settled that the [formats-measures research](https://github.com/CraftsmanLabs/attra/blob/research/formats-measures/docs/research/formats-measures.md) left unchecked, plus new ones it surfaced. Each names the report that shows it.

Answers to the research's "Not verified" list:

- **gcovr Cobertura `hits` are execution counts.** `classify()` runs twice and its first line has `hits="2"` (`gcc/gcovr/cobertura.xml`).
- **coverlet Cobertura `hits` are execution counts** (`hits="2"` on the same line, `dotnet/coverlet/coverage.cobertura.xml`).
- **OpenClover's Clover `count` values are execution counts:** the `classify` method line and its first statement both have `count="2"`, and `cond` lines carry `truecount`/`falsecount` (`jvm/openclover/clover.xml`).
- **llvm-cov export columns are 1-based.** The first segment in `classify.c` starts at line 4, column 18. That column is the `(` that opens the body of `#define TWICE(x) ((x) + (x))`, which is the 18th character of the line (`llvm/llvm-cov/export.json`).

New:

- **Microsoft.CodeCoverage writes Cobertura with hit-or-not flags.** The same line that coverlet records as `hits="2"` has `hits="1"`. (`dotnet/microsoft-codecoverage/coverage.cobertura.xml`).
- **One file, several Cobertura classes.** Both .NET emitters put an async method's state machine in its own `<class>` with the same `filename`, named `Classify.<LaterAsync>d__5` by Microsoft and `Classify/<LaterAsync>d__5` by coverlet. Per-file data has to be gathered across classes (`dotnet/`).
- **An empty run can claim 100%.** `dotnet-coverage collect` wrapped around `dotnet test` without settings instruments nothing, yet writes `line-rate="1" branch-rate="1"` with no packages (`dotnet/dotnet-coverage/empty-run.cobertura.xml`). A reader must treat an empty report as "not recorded", not as fully covered.
- **c8 counts the excluded function as called.** `excluded()` never runs, but c8 records it with count 1. Apparently the `c8 ignore` comments removed its own zero-count range, so it inherits the module's count. nyc leaves it out. c8 also creates a statement for every line, comments included (`node/c8/coverage-final.json`).
- **nyc and c8 describe branches differently for the same run.** nyc gives 7 typed branches (`if`, `binary-expr`, `cond-expr`, `default-arg`). c8 gives 13 untyped one-location branches from V8 block ranges (`node/nyc/`, `node/c8/`).
- **coverlet and gcovr disagree on the same condition.** For `if (n < 0 && n % 2 == 0)` called with -2 and 5, gcovr reports `condition-coverage="75% (3/4)"` and coverlet `100% (4/4)`. The C# compiler emits different IL branches than GCC's CFG edges, so per-line branch fractions aren't comparable across tools even when the source matches.
- **kcov's compiled-code `hits` confirmed as addresses.** The first line of `classify()` (called twice) has `hits="1"`, and the `if` line has `hits="3"`. kcov's Codecov JSON for the same run writes `"3/3"`, an address fraction that Codecov reads as branch coverage (`kcov/compiled/`).
- **Go profiles list packages no test touches.** With Go 1.27, `go test ./...` profiles include `util` and `util/internal` blocks at zero. The GOCOVERDIR data from one test binary lists only the packages that binary links, so `covdata textfmt` omits `util/internal` (`go/coverprofile/`).
- **llvm-cov export versions in the wild differ:** 2.0.1 from clang 19, 3.0.1 from Swift 6.3, and 3.1.0 from Rust 1.99. A parser needs all three.
- **Tool versions can't be trusted from `--version`.** Debian's lcov 2.3.1 package prints `LCOV version 2.0-1`, yet writes the 2.2+ `FNL`/`FNA` records and 2.3's `MCDC` (`gcc/lcov/branch-mcdc.info`).
- **Some reports cover far more than the project.** The Dart VM hitmap from `dart test --coverage` covers about 320 libraries, mostly `package:` dependencies (`dart/dart-test/`). SwiftPM's own export includes the test target. coverage.py JSON with `--show-contexts` grew to 60 MB for the generated file alone, so the contexts report leaves that file out.
- **Xdebug path coverage is memory-hungry:** about 450 MB for the 1000-function file, above PHP's default 128 MB limit.

## Gaps

Emitters and variants not collected yet:

- Kotlin through JaCoCo or Kover, Scala (scoverage), Flutter (as opposed to plain Dart), grcov, and Bazel's combined LCOV.
- Istanbul's logical-expression truthiness (`bT`), V8 binary (non-`callCount`) mode, and coverage.py dynamic contexts per test function.
- Codecov's custom JSON as written by hand, and Sonar generic coverage XML from tools other than kcov.
- Windows paths and OpenCover from tools other than coverlet (OpenCover itself is Windows-only).
