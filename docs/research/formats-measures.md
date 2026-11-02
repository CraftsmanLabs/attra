# What each candidate format records, and where formats disagree

Research for [#10](https://github.com/CraftsmanLabs/attra/issues/10), part of [Map: attra coverage v1](https://github.com/CraftsmanLabs/attra/issues/8). Terms (report, format, coverage set, measure, merge, patch coverage) are from [`GLOSSARY.md`](../../GLOSSARY.md).

Researched 2026-11-02. Every claim links to a spec, an official doc, or the emitter's source, pinned to a commit or tag where possible. Where something wasn't checked against a source, it says so.

## Short answer

- Only line coverage is close to universal. Branch, function, region and condition data exist in some formats, and where two formats both have them they usually count different things. You can't compare a branch total from one tool with a branch total from another.
- Hit counts aren't universal either. coverage.py (every output), Go `set` mode, JaCoCo and V8 binary mode record only hit or not hit. Several emitters put something other than an execution count in a field named `hits` or `count`.
- How a format says "this line can't run" varies: leave it out, write `null`, list it as excluded, or have no way to say it at all (V8). Only coverage.py JSON, SimpleCov and LCOV's branch/MC/DC flags record lines the user excluded as a separate state.
- At least three emitters write a zero or 100% for a measure they never collected: coverage.py's Cobertura XML, kcov's Cobertura XML and Istanbul's percentages. If attra reads those numbers as measurements, it invents data.
- The same format means different things depending on the emitter. Istanbul's Clover `truecount` is not what the Clover schema defines, kcov's Cobertura `hits` for compiled code counts addresses rather than executions, and coverlet's OpenCover columns are made up. The parser has to know which tool wrote the report.
- File identity takes at least five forms: absolute path, path relative to a root the report declares, language namespace (Go import path, JVM package plus file name, Dart `package:` URI), a URL, and a basename alone.
- Two formats can't yield line coverage without the source text: V8 JSON (character offsets) and coverage.py's `.coverage` SQLite file (it stores only what ran, not what could have run).
- Commit metadata is almost absent. Only SimpleCov 1.x `coverage.json` records a git commit. Test names exist in LCOV (`TN`), coverage.py contexts, SimpleCov contexts, OpenCover tracked methods and Clover test projects.

## Sources

Fetched 2026-11-02. Short names are used in the tables.

| Short name | Source |
|---|---|
| lcov-master | [lcov `docs/man/geninfo.rst` @1ad5aed](https://github.com/linux-test-project/lcov/blob/1ad5aed5ef7f/docs/man/geninfo.rst?plain=1#L1547), "TRACEFILE FORMAT" section (unreleased after v2.6) |
| lcov-2.6 | [lcov `docs/man/geninfo.rst` @v2.6](https://github.com/linux-test-project/lcov/blob/v2.6/docs/man/geninfo.rst?plain=1) (released 2026-10-03). Also checked v2.2, v2.3 and v2.4 for when records first appeared |
| cobertura-dtd | [`coverage-04.dtd`](https://github.com/cobertura/web/blob/5ade495c8f8f/htdocs/xml/coverage-04.dtd) |
| jacoco-dtd | [JaCoCo `report.dtd` @2fa50fa](https://github.com/jacoco/jacoco/blob/2fa50fafca91/org.jacoco.report/src/org/jacoco/report/xml/report.dtd), [JaCoCo coverage counters doc](https://www.jacoco.org/jacoco/trunk/doc/counters.html) |
| clover-xsd | [OpenClover `clover.xsd` @9e14d04](https://github.com/openclover/clover/blob/9e14d047f3d8/clover-core/src/main/resources/clover.xsd) |
| php-clover | [php-code-coverage `Report/Clover.php` @4063552](https://github.com/sebastianbergmann/php-code-coverage/blob/4063552c678c/src/Report/Clover.php), [`Node/File.php`](https://github.com/sebastianbergmann/php-code-coverage/blob/4063552c678c/src/Node/File.php#L199-L320) |
| covpy-json / covpy-xml / covpy-sql | coverage.py @474bba1: [`jsonreport.py`](https://github.com/coveragepy/coveragepy/blob/474bba1f6cdf/coverage/jsonreport.py), [`xmlreport.py`](https://github.com/coveragepy/coveragepy/blob/474bba1f6cdf/coverage/xmlreport.py), [`sqldata.py`](https://github.com/coveragepy/coveragepy/blob/474bba1f6cdf/coverage/sqldata.py) (schema version 7) |
| istanbul | istanbuljs @28ffdbc: [`istanbul-lib-coverage/lib/file-coverage.js`](https://github.com/istanbuljs/istanbuljs/blob/28ffdbc31459/packages/istanbul-lib-coverage/lib/file-coverage.js), [`istanbul-lib-instrument/src/source-coverage.js`](https://github.com/istanbuljs/istanbuljs/blob/28ffdbc31459/packages/istanbul-lib-instrument/src/source-coverage.js), [`visitor.js`](https://github.com/istanbuljs/istanbuljs/blob/28ffdbc31459/packages/istanbul-lib-instrument/src/visitor.js), [`percent.js`](https://github.com/istanbuljs/istanbuljs/blob/28ffdbc31459/packages/istanbul-lib-coverage/lib/percent.js), reporters [`clover/index.js`](https://github.com/istanbuljs/istanbuljs/blob/28ffdbc31459/packages/istanbul-reports/lib/clover/index.js) and [`cobertura/index.js`](https://github.com/istanbuljs/istanbuljs/blob/28ffdbc31459/packages/istanbul-reports/lib/cobertura/index.js); positions per [ESTree](https://github.com/estree/estree/blob/master/es5.md#node-objects) |
| v8 | [devtools-protocol `js_protocol.pdl` @92be9c2](https://github.com/ChromeDevTools/devtools-protocol/blob/92be9c279a8f/pdl/js_protocol.pdl) (Profiler domain), [V8 blog "JavaScript code coverage"](https://github.com/v8/v8.dev/blob/031a6578036d/src/blog/javascript-code-coverage.md), [Node `NODE_V8_COVERAGE` docs @24f2323](https://github.com/nodejs/node/blob/24f23230b7e5/doc/api/cli.md#node_v8_coveragedir), [v8-to-istanbul @46b9724](https://github.com/istanbuljs/v8-to-istanbul/blob/46b972458b40/lib/source.js) |
| go | [`golang.org/x/tools/cover/profile.go` @803bc5e](https://github.com/golang/tools/blob/803bc5e8b0fc/cover/profile.go#L52-L110), [`cmd/go` `-covermode` doc @babb75b](https://github.com/golang/go/blob/babb75be8cd5/src/cmd/go/alldocs.go#L3420-L3429), [`go/token.Position`](https://github.com/golang/go/blob/babb75be8cd5/src/go/token/position.go#L26-L31), [go.dev/doc/build-cover](https://go.dev/doc/build-cover) |
| llvm | llvm-project @3bd152d: [`CoverageExporterJson.cpp`](https://github.com/llvm/llvm-project/blob/3bd152ddbb6d/llvm/tools/llvm-cov/CoverageExporterJson.cpp), [`CoverageExporterLcov.cpp`](https://github.com/llvm/llvm-project/blob/3bd152ddbb6d/llvm/tools/llvm-cov/CoverageExporterLcov.cpp), [`CoverageMapping.h`](https://github.com/llvm/llvm-project/blob/3bd152ddbb6d/llvm/include/llvm/ProfileData/Coverage/CoverageMapping.h#L230-L258), [`CoverageMapping.cpp` `LineCoverageStats`](https://github.com/llvm/llvm-project/blob/3bd152ddbb6d/llvm/lib/ProfileData/Coverage/CoverageMapping.cpp#L1571-L1615) |
| gcov | [GCC `gcov.texi` @a6c50b0](https://github.com/gcc-mirror/gcc/blob/a6c50b0dde12/gcc/doc/gcov.texi#L304-L530) (`--json-format`) |
| simplecov | SimpleCov [v1.3.2](https://github.com/simplecov-ruby/simplecov/tree/v1.3.2): [`coverage-v1.3.schema.json`](https://github.com/simplecov-ruby/simplecov/blob/v1.3.2/schemas/coverage-v1.3.schema.json), [`result_hash_formatter.rb`](https://github.com/simplecov-ruby/simplecov/blob/v1.3.2/lib/simplecov/formatter/json_formatter/result_hash_formatter.rb), [`result.rb`](https://github.com/simplecov-ruby/simplecov/blob/v1.3.2/lib/simplecov/result.rb); `main` is at schema 1.4 ([CHANGELOG](https://github.com/simplecov-ruby/simplecov/blob/main/CHANGELOG.md)); legacy 0.x JSON from [`simplecov_json_formatter` @13bddf2](https://github.com/codeclimate-community/simplecov_json_formatter/blob/13bddf2dab7c/lib/simplecov_json_formatter/source_file_formatter.rb); Ruby [`Coverage` docs @e83592b](https://github.com/ruby/ruby/blob/e83592ba14cf/ext/coverage/coverage.c#L640-L740) |
| opencover | OpenCover model @ca344ea (repo archived; last push 2021-11-15): [`SequencePoint.cs`](https://github.com/OpenCover/opencover/blob/ca344ea6d465/main/OpenCover.Framework/Model/SequencePoint.cs), [`BranchPoint.cs`](https://github.com/OpenCover/opencover/blob/ca344ea6d465/main/OpenCover.Framework/Model/BranchPoint.cs), [`InstrumentationPoint.cs`](https://github.com/OpenCover/opencover/blob/ca344ea6d465/main/OpenCover.Framework/Model/InstrumentationPoint.cs), [`Method.cs`](https://github.com/OpenCover/opencover/blob/ca344ea6d465/main/OpenCover.Framework/Model/Method.cs), [`File.cs`](https://github.com/OpenCover/opencover/blob/ca344ea6d465/main/OpenCover.Framework/Model/File.cs), [`Module.cs`](https://github.com/OpenCover/opencover/blob/ca344ea6d465/main/OpenCover.Framework/Model/Module.cs); coverlet's writer [`OpenCoverReporter.cs` @345b63c](https://github.com/coverlet-coverage/coverlet/blob/345b63cc18ab/src/coverlet.core/Reporters/OpenCoverReporter.cs) |
| kcov | kcov @bbaa197: [`cobertura-writer.cc`](https://github.com/SimonKagstrom/kcov/blob/bbaa197381a3/src/writers/cobertura-writer.cc), [`codecov-writer.cc`](https://github.com/SimonKagstrom/kcov/blob/bbaa197381a3/src/writers/codecov-writer.cc), [`json-writer.cc`](https://github.com/SimonKagstrom/kcov/blob/bbaa197381a3/src/writers/json-writer.cc), [`file-parser.hh`](https://github.com/SimonKagstrom/kcov/blob/bbaa197381a3/src/include/file-parser.hh) |
| tarpaulin | tarpaulin @96b59d9: [`traces.rs`](https://github.com/xd009642/tarpaulin/blob/96b59d92ad78/src/traces.rs#L12-L70), [`report/json.rs`](https://github.com/xd009642/tarpaulin/blob/96b59d92ad78/src/report/json.rs), [`report/lcov.rs`](https://github.com/xd009642/tarpaulin/blob/96b59d92ad78/src/report/lcov.rs), [README](https://github.com/xd009642/tarpaulin/blob/96b59d92ad78/README.md) |
| dart | dart-lang/tools `pkgs/coverage` @1579f8d: [`formatter.dart`](https://github.com/dart-lang/tools/blob/1579f8d690d2/pkgs/coverage/lib/src/formatter.dart#L84-L141), [`hitmap.dart`](https://github.com/dart-lang/tools/blob/1579f8d690d2/pkgs/coverage/lib/src/hitmap.dart#L360-L382), [`collect.dart`](https://github.com/dart-lang/tools/blob/1579f8d690d2/pkgs/coverage/lib/src/collect.dart#L213); Flutter [`coverage_collector.dart` @80e556c](https://github.com/flutter/flutter/blob/80e556c0432f/packages/flutter_tools/lib/src/test/coverage_collector.dart#L217-L231) |
| codecov | [Codecov Custom Coverage Format doc](https://docs.codecov.com/docs/codecov-custom-coverage-format); Codecov's parser [`apps/worker/services/report/languages/v1.py` @27fc195](https://github.com/codecov/umbrella/blob/27fc195c144b/apps/worker/services/report/languages/v1.py) |

## Measures matrix

Key: **count** means an execution count, **bool** means hit or not hit only, **derived** means the reader has to compute it from other records, **–** means not recorded.

| Format | Line | Statement / region | Branch | Function | Condition / MC/DC | Counts or bool |
|---|---|---|---|---|---|---|
| LCOV | `DA` count | – | `BRDA` per edge; `-` = never evaluated | `FN`+`FNDA`, or `FNL`+`FNA` (2.2+) with aliases | `MCDC` (2.3+), sensitized t/f per condition | count; `MCDC` taken may be count or bool depending on the tool (lcov-master L2281) |
| Cobertura XML | `line@hits` | – | per line `condition-coverage="P% (c/t)"`, optional `<condition>` | `<method>` with lines and `line-rate`, no entry count | – | count by spec; varies by emitter (see per-format notes) |
| JaCoCo XML | per line `mi`/`ci` (instructions missed/covered) | INSTRUCTION counter | per line `mb`/`cb` | METHOD counter; method `line` = first line | – | neither: instruction and branch counts, no execution counts |
| Clover XML | `line type="stmt" count` | stmt | `line type="cond" truecount falsecount` | `line type="method" count signature` | – | count by spec |
| coverage.py JSON | `executed_lines` / `missing_lines` / `excluded_lines` | – | `executed_branches` / `missing_branches` as line→line arcs | `functions` / `classes` regions (format 3): line sets per named region, no entry flag | – | bool |
| coverage.py XML | Cobertura `hits` = 0 or 1 | – | `condition-coverage`, plus a nonstandard `missing-branches` attribute | none (empty `<methods/>`) | – | bool |
| coverage.py `.coverage` | executed lines only (numbits per file and context) | – | executed arcs only | – | – | bool; no "missing" set at all |
| Istanbul `coverage-final.json` | derived from statements | `statementMap` + `s` | `branchMap` + `b`, N-way, typed | `fnMap` + `f` | `bT` (truthiness per logical leaf, opt-in) | count |
| V8 JSON | – (byte ranges only) | nested `ranges` per function | – (block ranges) | `functions[].functionName` and first range | – | count with `callCount`, else bool |
| Go coverprofile | derived from blocks | blocks with `NumStmt` | – | – | – | `set` = bool; `count`/`atomic` = count |
| llvm-cov export JSON | derived from `segments` | regions (code, gap, skipped, expansion) | `branches` true/false counts per leaf condition | `functions[]` per instantiation | `mcdc_records` | count |
| gcov JSON | `lines[].count` | `functions[].blocks` / `blocks_executed` | `lines[].branches` CFG edges (needs `-b`) | `functions[].execution_count` | `lines[].conditions` (GCC 14 condition coverage) | count |
| SimpleCov `.resultset.json` | Ruby `Coverage` lines array | – | Ruby branches hash | Ruby methods hash | – | count (`oneshot_lines` variant is bool) |
| SimpleCov `coverage.json` | `lines` | – | `branches` list | `methods` list (1.x) | – | count |
| OpenCover XML | derived from `SequencePoint` | sequence points with columns | `BranchPoint` with `path` | `Method@visited`, `MethodPoint@vc` | – | count (`vc`) |
| kcov | Cobertura / Codecov JSON per line | – | – | – | – | count for interpreted code; for compiled code, addresses hit on the line |
| tarpaulin JSON | `traces[].stats.Line` | – | type exists, not implemented ("Branch coverage: NOT IMPLEMENTED") | – (its LCOV derives `FN`) | type exists, unused | count |
| Dart / Flutter | LCOV `DA`; hitmap `hits` | – | LCOV `BRDA:line,0,0,n`, one per branch-target line | `FN`/`FNDA` keyed by line | – | count |
| Codecov custom JSON | per line int | – | per line string `"c/t"` or bool (a partial; which branch is unknown) | – | – | count, or a fraction |

Second matrix: how each format marks lines and records metadata.

| Format | Lines that can't run | User-excluded code | File identity | Test name | Tool / version | Time | Commit |
|---|---|---|---|---|---|---|---|
| LCOV | no `DA` record | branches/conditions keep their records but drop out of `BRF`/`MCF`; `U` flag = unreachable | `SF` path; geninfo writes absolute paths from the `.gcno` (lcov-master L2385) | `TN` before each section | – | – | `VER` per file, set by a user script |
| Cobertura | no `<line>` | – | `class@filename`, relative to one of `<sources>` | – | `coverage@version` (whose version varies) | `coverage@timestamp`, unit not given | – |
| JaCoCo | no `<line>` (no instructions on it) | – (bytecode filters drop synthetic code) | `package@name` (VM notation, `/`) + `sourcefile@name` | – (`sessioninfo` = agent session id) | – | `sessioninfo@start`/`@dump` | – |
| Clover | no `<line>` | – | `file@name` (schema: basename) + `file@path` (schema: original path) | test methods in `<testproject>`, `testduration`/`testsuccess` | `coverage@clover` | `coverage@generated`, `project@timestamp` (schema: seconds) | – |
| coverage.py JSON | not listed | `excluded_lines` | key = path relative to the run | `contexts` per line (with `--show-contexts`) | `meta.version`, `meta.format` | `meta.timestamp` (ISO, no time zone) | – |
| coverage.py `.coverage` | unknown (needs source) | unknown | `file.path` as measured | `context` table | `meta.version` | `meta.when` | – |
| Istanbul | not in `statementMap` | ignored code is never instrumented, so it's indistinguishable from non-code | `path` (usually absolute) | – | – | – | – |
| V8 | no notion; every byte inside a range has a count, comments included | – (c8/v8 ignore comments are applied later by v8-to-istanbul) | `url` (`file://` URL or Node internal name) | – | – | – | – |
| Go | not in any block | – | import path + file name | – | – | – | – |
| llvm-cov export | segment with `hasCount=false`, or no segment | skipped region (preprocessor) | `filename` as compiled; functions carry a `filenames` list indexed by `fileId` | – | format `version` only | – | – |
| gcov JSON | no `lines[]` entry | – | `file` plus root `current_working_directory` | – | `gcc_version`, `format_version` | – | – |
| SimpleCov resultset | `nil` in the array | – (applied when formatting) | absolute path | command name key | – | `timestamp` (epoch seconds) | – |
| SimpleCov `coverage.json` 1.x | `null` | `"ignored"` | project-relative key, plus `meta.root` | `command_name(s)`, `contexts` | `simplecov_version`, `schema_version` | `meta.timestamp` (ISO, ms) | `meta.commit` |
| OpenCover | no sequence point | skipped modules/methods | `File@fullPath` via `fileid` | `TrackedMethods` (tests) and per-point `TrackedMethodRefs` | `CoverageSession@Version` | – | – |
| kcov Cobertura | no `<line>` | – | path with the common prefix stripped; `<source>` = common path | – | `version="1.9"` (fixed string) | epoch seconds | – |
| tarpaulin JSON | not in `traces` | – | `path` as an array of path components (absolute) | – | – | – | – |
| Dart LCOV | no `DA` | – | `SF` relative to `basePath` (Flutter passes the current directory) | – | – | – | – |
| Codecov custom | absent or `null` | – | key as written | – | – | – | – |

## Per-format notes

### LCOV tracefile

- Record grammar (lcov-master L1547-L1600): `TN:` before `SF:`, coverpoints, `end_of_record`. `TN` names the testcase for that one section, so one tracefile can hold several sections for the same `SF` under different test names.
- `DA:<line>,<count>[,[<checksum>][,<end>]]`. `<end>` (the last line of a multi-line statement) is master-only. v2.6 has `DA:<line>,<count>[,<checksum>]` (lcov-2.6 L931).
- Functions changed in 2.2: `FNL:<index>,<start>[,<end>]` plus one or more `FNA:<index>,<count>,<name>` aliases. Older `FN:<start>[,<end>],<name>` plus `FNDA:<count>,<name>` is still read. Since 2.2, `FNF`/`FNH` count function groups, not aliases (lcov-master, Function coverage). Master adds call-graph records (`FNC`, `FNM`, flag letters) that no released version has.
- `BRDA:<line>,[e][f][U]<block>[^<location>],<branch>,<taken>`. `<taken>` is `-` when the expression was never evaluated, otherwise a count. `<branch>` is an arbitrary string (a number from gcc/llvm, or an expression such as `!enable`). Excluded branches stay as `BRDA` records but aren't counted in `BRF`/`BRH` (L2129-L2240). `^<location>` is master-only.
- Merging branches is a heuristic. lcov matches blocks by "signature" and order of appearance, because "gcov (and other tools) do not produce sufficient information to uniquely identify branch expressions" (L2195-L2230).
- `MCDC:<line>,[U]<groupSize>,<sense>,<taken>,<index>,<expression>` appeared in 2.3 (not in v2.2's man page, present in v2.3). The docs say "some tools may treat `<taken>` as the number of times… where others may treat it as a boolean" (L2281).
- Master makes `LF/LH`, `FNF/FNH`, `BRF/BRH` and `MCF/MCH` mandatory beside their coverpoints. It defines `BRF:0` as "the producer counted this file's branches and found none, which is a different statement from a file which carries no `BRF:` record" (L1580-L1625). Released v2.6 has neither rule. Under the master rule, tarpaulin (writes `FNF` without `FNH`) and Dart (writes `BRDA` without `BRF`/`BRH`) produce non-conforming tracefiles; see their sections.
- Emitter variants checked:
  - `llvm-cov export -format=lcov` writes `FN`/`FNDA`/`FNF`/`FNH`, `DA`, `BRDA:<line>,<pairIndex>,<branchIndex>,<n or ->` and `BRF`/`BRH`. It writes `-` for both arms when both counts are zero ([CoverageExporterLcov.cpp L181-L240](https://github.com/llvm/llvm-project/blob/3bd152ddbb6d/llvm/tools/llvm-cov/CoverageExporterLcov.cpp#L181-L240)). No MC/DC in its LCOV output.
  - tarpaulin writes an empty `TN:`, `FN:<line of first trace inside the function>,<name>`, `FNDA` = that trace's line count, `FNF` with no `FNH`, and no branches ("TODO: add support for branching") ([lcov.rs L18-L90](https://github.com/xd009642/tarpaulin/blob/96b59d92ad78/src/report/lcov.rs#L18-L90)).
  - Dart `package:coverage` writes `FN:<line>,<name>`, `FNDA` only for functions with a non-zero count, `FNF`/`FNH`, `DA`, `LF`/`LH`, then `BRDA:<line>,0,0,<hits>` for each branch-target line. That is one "branch" per line, with no pairing and no `BRF`/`BRH` (dart formatter.dart L113-L140). Flutter calls it with `basePath` set to the current directory, so `SF` paths are relative (Flutter coverage_collector.dart L220-L230).

### Cobertura XML

- The DTD defines `coverage` (rates, counts, `version`, `timestamp`, all `#REQUIRED`), `sources/source`, `package`, `class@filename`, `method@name,signature` and `line@number,hits,branch,condition-coverage` with optional `conditions/condition@number,type,coverage` (cobertura-dtd). There are no columns and no function entry count. Method coverage is only `line-rate` over the method's lines.
- The DTD gives no unit for `timestamp`, and emitters disagree. coverage.py writes milliseconds (`int(time.time() * 1000)`, covpy-xml L112), kcov writes `strftime("%s")` epoch seconds (kcov-cobertura L172-L174), and Istanbul writes `Date.now()` milliseconds.
- `version` is the emitter's version, not the format's: coverage.py's own version (L111), kcov's fixed `"1.9"` (L186), Istanbul's fixed `'0.1'` (istanbul cobertura L49).
- **Measures not collected show up as numbers:**
  - coverage.py without branch measurement writes `branches-covered="0" branches-valid="0" branch-rate="0"` (covpy-xml L165-L172), and its `rate()` returns `"1"` when `num == 0` (L35-L40).
  - kcov always writes `branch-rate="1.0" branches-covered="0" branches-valid="0"` and `branch-rate="1.0"` on every class (kcov-cobertura L159, L186). kcov has no branch coverage.
  - Istanbul's `branch-rate` is `pct / 100`, and `percent()` returns 100 when the total is 0 ([percent.js](https://github.com/istanbuljs/istanbuljs/blob/28ffdbc31459/packages/istanbul-lib-coverage/lib/percent.js)).
- `hits` means different things by emitter:
  - coverage.py: always 0 or 1 (`str(int(line not in analysis.missing))`, covpy-xml L235). A comment in the code asks whether execution counts could be recorded.
  - kcov: for compiled binaries, a line has several breakpoint addresses. `hits` is the number hit, up to `m_possibleHits` (`HITS_LIMITED`), and is forced to 1 only for `HITS_SINGLE` parsers (kcov-cobertura L113-L116, file-parser.hh L30-L35).
  - Istanbul: the line's statement count (derived; see Istanbul), plus `<method>` hits taken from the function count.
- coverage.py adds a nonstandard `missing-branches="12,exit"` attribute listing missed arc destinations (L245-L247).
- File identity: coverage.py writes `class@filename` relative to whichever `<source>` matched and adds that source to `<sources>` (L195-L205). Istanbul writes `path.relative(projectRoot, path)` with `<source>` = projectRoot. kcov strips the common path prefix and writes it as `<source>`.

### JaCoCo XML

- Per line: `nr`, `mi`, `ci`, `mb`, `cb`, meaning missed and covered **instructions** and **branches** (jacoco-dtd). There are no execution counts anywhere in the format.
- Counters `INSTRUCTION|BRANCH|LINE|COMPLEXITY|METHOD|CLASS` with `missed`/`covered` at method, class, sourcefile, package, group and report level.
- Semantics (JaCoCo counters doc): a line is executed when at least one of its instructions ran, and partial when some but not all did. Branch coverage covers `if`/`switch` only; "exception handling is not considered as branches". A method counts as executed if at least one instruction ran. Constructors and static initializers count as methods, including generated ones with no source.
- Line-level data needs debug info. Instruction and branch counters are "always available", so a report can have counters but no `<line>` elements.
- File identity: `package@name` in VM notation (`com/foo/bar`) plus `sourcefile@name` (`Baz.java`). The source root (`src/main/java`, `src/main/kotlin`, …) isn't recorded.
- `sessioninfo@id,start,dump` records agent sessions, not tests.

### Clover XML

- The schema defines `line@num`, `type` (`method|stmt|cond`), `count` (stmt and method), `truecount`/`falsecount` (cond: "the number of times the true branch was executed"), plus `signature`, `complexity`, `testduration`, `testsuccess` and `visibility` (clover-xsd L101-L141). `project` and `testproject` are separate, and the `timestamp` doc says "seconds since UTC". `file@name` is documented as "the file name e.g. Foo.java" and `file@path` as "the filesystem-specific original path".
- Emitters differ from the schema:
  - Istanbul writes `truecount = covered branch paths on the line` and `falsecount = total − covered` (istanbul clover L136-L143). Those are counts of branch arms, not executions of the true and false outcomes. It also hard-codes `clover: '3.2.0'` and writes `generated` and `timestamp` as `Date.now()` milliseconds (L53-L58).
  - PHPUnit (php-code-coverage) puts the whole path in `file@name` and writes no `path` (php-clover L70-L71). It writes `generated` as `time()` seconds (L44-L53) and adds `name` and `crap` attributes the schema doesn't define (L159-L171). `stmt count` is `array_sum` over per-test values (L146). Whether each value is an execution count or "executed at least once" depends on the driver: `File::collectsHitCounts()` "Whether the values … are exact execution counts … or only mean 'executed at least once'" (php File.php L311-L319). The method `count` is the maximum line count within the method (L102-L106), and `coveredmethods` counts methods with 100% line coverage (L96-L99), not methods entered.

### coverage.py

- JSON (format 3; "1" had no number, "2" added `meta.format`, "3" added regions; covpy-json L30-L33). `meta` holds `format`, `version`, `timestamp` (`datetime.now().isoformat()`, local time with no zone), `branch_coverage` and `show_contexts`. Each file is keyed by `relative_filename()` and lists `executed_lines`, `missing_lines`, `excluded_lines` and a `summary`. With branches it adds `executed_branches` and `missing_branches` as `[from, to]` pairs, where a negative `to` means exit. `contexts` (line → list of context labels) appears with `--show-contexts`. `functions` and `classes` map a qualified name to a region with its own executed, missing and excluded lines and `start_line`. The `""` key holds lines outside any region (L119-L165). No counts.
- **When branches weren't measured, the branch keys are missing rather than zero** (L101-L103, L130-L137). In this format, absence is a reliable "not recorded".
- XML: Cobertura with the quirks listed above.
- `.coverage` SQLite (schema 7): tables `meta` (`has_arcs`, `sys_argv`, `version`, `when`, `hash`), `file(path)`, `context`, `line_bits(file_id, context_id, numbits)`, `arc(file_id, context_id, fromno, tono)` and `tracer` (covpy-sql SCHEMA). It records **only what ran**. There is no table of statements or of missing lines, so producing line coverage means running coverage.py's source analysis on the file at that commit.

### Istanbul / nyc `coverage-final.json`

- Per file: `path`, `statementMap` + `s` (counts), `fnMap` (`name`, `decl`, `loc`, deprecated `line`) + `f`, `branchMap` (`loc`, `type`, `locations[]`, deprecated `line`) + `b` (array of counts per location). With `reportLogic`, `bT` holds counts per logical leaf, for binary expressions only. Optional `inputSourceMap` and the instrumenter's `hash` (istanbul source-coverage.js; visitor.js).
- Branch types emitted by the instrumenter: `if`, `cond-expr`, `binary-expr` (one location per leaf of `&&`/`||`/`??`), `switch` (one per case) and `default-arg` (visitor.js L472-L594). Branches with zero locations are pruned in `freeze()`.
- Positions follow ESTree: `line >= 1`, `column >= 0`.
- Line coverage is **derived**. For each statement, take its start line and keep the maximum count among statements starting on that line (file-coverage.js L221-L238). A statement spanning lines counts only on its first line.
- Ignored code (`/* istanbul ignore next|if|else|file */`) is never instrumented (visitor.js L7-L10, L540-L552), so it's absent, exactly like non-code.
- Istanbul's own merge matches items by location key and adds hits from the nearest containing range for items that exist only on one side (file-coverage.js L57-L175). It's a location-based heuristic.
- Unnamed functions get the name `(anonymous_N)`, where N is the function index (source-coverage.js L45-L46).

### V8 coverage JSON (`NODE_V8_COVERAGE`)

- Node writes `{"result": [ScriptCoverage...]}` plus an optional, experimental `source-map-cache` (Node cli.md). `ScriptCoverage = {scriptId, url, functions[]}`, `FunctionCoverage = {functionName, ranges[], isBlockCoverage}` and `CoverageRange = {startOffset, endOffset, count}` (js_protocol.pdl, Profiler).
- Ranges nest. The V8 blog example's comment calls offsets "Byte offset, inclusive" / "exclusive", but v8-to-istanbul treats them as JavaScript string indices (`this.eof = sourceRaw.length`) and subtracts the CommonJS wrapper length (v8-to-istanbul source.js L6-L11, v8-to-istanbul.js L214-L220). Treat them as UTF-16 code unit offsets into the script as V8 saw it. That's an inference from the consumer; the protocol doesn't say.
- Counts are execution counts only with `callCount: true`. Block granularity needs `detailed: true`, and best-effort mode "might lose data on garbage-collected (GC) functions" (V8 blog; js_protocol.pdl `startPreciseCoverage`).
- No lines, no idea of non-executable code, no exclusions. Turning this into line coverage needs the exact script source (and source maps for transpiled code).

### Go coverprofile

- First line `mode: set|count|atomic`, then `name.go:line.column,line.column numberOfStatements count` (go profile.go L55-L58). `set` is "bool: does this statement run?"; `count` and `atomic` are counts. The default is `set`, or `atomic` under `-race` (cmd/go docs L3420-L3429).
- `name.go` is the **import path** plus file name (`encoding/base64/base64.go`). Columns are `go/token` columns, "starting at 1 (byte count)".
- Statements only, in blocks. No functions (`go tool cover -func` computes them from source) and no branches. A line can belong to several blocks.
- Blocks repeat when profiles are concatenated. The reference parser merges duplicates by OR for `set` and by sum otherwise, and rejects a `NumStmt` mismatch (profile.go L91-L107).
- Since Go 1.20 binaries write binary `covmeta`/`covcounters` files to `GOCOVERDIR`, which `go tool covdata textfmt` converts to this text format (go.dev/doc/build-cover).

### llvm-cov export JSON

- `{"version": "3.1.0", "type": "llvm.coverage.json.export", "data": [{files, functions, totals}]}`.
  - A segment is `[line, col, count, hasCount, isRegionEntry, isGapRegion]`.
  - A region is `[lineStart, colStart, lineEnd, colEnd, count, fileId, expandedFileId, kind]`.
  - A branch is `[lineStart, colStart, lineEnd, colEnd, trueCount, falseCount, fileId, expandedFileId, kind]`.
  - An MC/DC record holds the decision region, true/false decision counts, a per-condition "independence pair covered" boolean, and test vectors (`conditions` true/false/null, `executed`, `result`).
  - The summary has `lines`, `functions`, `instantiations`, `regions`, `branches` and `mcdc`.
  - Source: llvm CoverageExporterJson.cpp L1-L50, L82-L200, L242-L300.
- Region kinds: `CodeRegion`, `ExpansionRegion` (macro or `#include`), `SkippedRegion` (preprocessor-skipped), `GapRegion`, `BranchRegion`, `MCDCDecisionRegion`, `MCDCBranchRegion` (CoverageMapping.h L230-L258).
- Line coverage is **derived**. A line is mapped if a counted region starts on it or a counted segment wraps it, and its count is the maximum among non-gap region starts on the line and the wrapped segment (CoverageMapping.cpp L1571-L1615).
- `functions[]` has one entry per instantiation (templates, generics), with its mangled `name`, `count`, `regions`, `branches`, `mcdc_records` and `filenames`.
- Counts are clamped to `INT64_MAX` because JSON stores int64 (L70-L76). Branch regions where both outcomes are constant-folded are left out of function output (L205-L210).
- Export options change the shape. `-summary-only` drops segments, branches and expansions, and `-skip-expansions` drops expansions (L248-L265).

### gcov JSON (`gcov --json-format`)

- One `.gcov.json.gz` per data file. The root holds `current_working_directory`, `data_file`, `format_version` (version "2" added `calls`), `gcc_version` and `files[]`. Each file has `file`, `functions[]` and `lines[]` (gcov.texi L304-L345).
- Functions: `name`, `demangled_name`, `start_line`/`start_column`, `end_line`/`end_column` (1-based), `execution_count`, `blocks`, `blocks_executed`.
- Lines: `line_number`, `count`, `unexecuted_block` ("not all statements on the line are executed"), `function_name`, `block_ids`, `branches[]` (`count`, `fallthrough`, `throw`, `source_block_id`, `destination_block_id`; only with `-b`), `calls[]`, and `conditions[]` (`count`, `covered`, `not_covered_true`, `not_covered_false`).
- Branches are control-flow edges between basic blocks, not source-level decisions.
- Headers compiled into several translation units appear in several JSON files and have to be combined.

### SimpleCov

- `.resultset.json`: `{<command_name>: {"coverage": {<abs path>: {...}}, "timestamp": <epoch s>, ...}}`, read back by `Result.from_hash` (simplecov result.rb L124-L130). 1.x adds `tracked_files`, `run_id`, `worker_id` and `contexts`. File values are Ruby's `Coverage.result` shapes:
  - `lines`: an array where index N is line N+1 and `nil` means "coverage was disabled for that line (e.g. lines like `else` and `end`)".
  - `branches`: `[:if, id, l1, c1, l2, c2] => {[:then, …] => n}`.
  - `methods`.
  - Alternatively `oneshot_lines`, which lists the lines that ran with no counts.
  - Source: Ruby coverage.c L640-L740.
- `coverage.json`, legacy 0.x (`simplecov_json_formatter` gem): `meta.simplecov_version` only, files keyed by **absolute** filename, `lines` (int, `null` or `"ignored"`) and optional `branches`.
- `coverage.json`, 1.x (schema 1.3 in v1.3.2, 1.4 on main):
  - `meta` holds `schema_version`, `simplecov_version`, `command_name(s)`, `project_name`, `timestamp`, `root`, **`commit`** (from `git rev-parse HEAD`) and the `line_coverage`, `branch_coverage` and `method_coverage` flags.
  - Files are keyed **project-relative**.
  - `lines` exists "if and only if `meta.line_coverage` is true", and the same holds for branches and methods (schema `source_file`).
  - A branch is `{type, start_line, end_line, coverage, inline, report_line}`. A method is `{name, start_line, end_line, coverage}`. `source` lines can be embedded.
  - `contexts` "present exactly when … every merged result recorded one". The code comment explains it's there "so consumers can tell 'recorded and empty' from 'not recorded'" (result_hash_formatter.rb).

### OpenCover XML

- Session → `Modules/Module@hash` → `Files/File@uid,fullPath` and `Classes/Class/Methods/Method`. `Method` has `@visited`, `cyclomaticComplexity`, `nPathComplexity`, `sequenceCoverage`, `branchCoverage`, `crapScore`, `isConstructor`, `isStatic`, `isGetter` and `isSetter`.
- `SequencePoint` has `vc`, `uspid`, `ordinal`, `offset`, `sl`, `sc`, `el`, `ec`, `bec` and `bev`. `bec` is "the number of branch exits" and `bev` the "visit count of merged branches".
- `BranchPoint` has `vc`, `uspid`, `ordinal`, `offset`, `sl`, `path`, `offsetend` and `fileid`.
- Test methods are listed in `TrackedMethods`, and each instrumentation point can carry `TrackedMethodRefs` (opencover model files).
- OpenCover itself is archived. coverlet is the live emitter of this format, and it fills fields OpenCover measured with made-up values:
  - every sequence point gets `sc="1" ec="2"`, one per line;
  - `Module@hash` is a random GUID;
  - `nPathComplexity` is set to the cyclomatic complexity;
  - `MethodPoint@vc` is the number of covered lines;
  - source: coverlet OpenCoverReporter.cs L43, L87-L113, L129-L138.

### kcov

- Writers: Cobertura, Codecov JSON, a JSON summary (`coverage.json`), SonarQube XML, Coveralls and HTML (kcov `src/writers`). Line coverage only.
- Codecov writer: per line, an integer count for interpreted code (`HITS_UNLIMITED`) or yes/no data (`HITS_SINGLE`). For compiled code it writes the string `"hits/possible"` (kcov-codecov L130-L150), which Codecov's parser reads as a partial branch (see below).
- `coverage.json` is summary only, per file and in total. Per-file numbers are JSON **strings** (`"covered_lines": "%d"`), the totals are numbers, and the file name isn't escaped. `percentCovered` isn't reset for a file with zero code lines, so such a file repeats the previous file's percentage (kcov json-writer L115-L155).

### tarpaulin

- `tarpaulin-report.json`: `{files: [{path: [components…], content: <full source>, traces: [{line, address: [...], length, stats: {"Line": n}}], covered, coverable}], coverage, covered, coverable}` (tarpaulin json.rs).
- `CoverageStat` also has `Branch(LogicState)` and `Condition(Vec<LogicState>)` variants (traces.rs L32-L40). The CLI help says "Branch coverage: NOT IMPLEMENTED" (README L72).
- Other outputs are LCOV (above), Cobertura XML, HTML and Markdown.

### Dart / Flutter

- The hitmap JSON is `{"type": "CodeCoverage", "coverage": [{source, script, hits: [line, count, line, count, …], funcHits, funcNames, branchHits}]}`. `source` is the script URI, usually `package:` or `file:` (collect.dart L213, hitmap.dart L360-L382).
- The LCOV output is described under LCOV above.

### Codecov custom JSON

- The documented shape is `{"coverage": {"<file>": {"<line>": 0 | n | "c/t" | null}}}`, where `"1/2"` means a "partial hit, one missing branch".
- Codecov's parser also accepts:
  - a list form where **the index is the line number** (index 0 is skipped: `enumerate(lines[1:], start=1)`);
  - a `{"lines": [...]}` form where **index 0 is line 1**, made by prepending a dummy element;
  - top-level `RSpec` / `MiniTest` keys, which is a SimpleCov resultset.
- It treats any string or bool value as branch data (codecov v1.py L25-L80). A fraction says how many branches on the line ran, never which ones.

## Disagreements the data model must reconcile

Each item names the formats involved and what the coverage set needs so it doesn't lose or invent data.

1. **Count, bool, or something else in a count field.** Exact counts: LCOV, Istanbul, llvm, gcov, Go count/atomic, SimpleCov, OpenCover `vc`, Clover (spec), V8 with `callCount`. Hit/not-hit: coverage.py (all three outputs), Go `set`, Ruby `oneshot_lines`, V8 binary mode. Something else: JaCoCo instruction and branch tallies, kcov addresses hit per line, PHPUnit's sum of per-test values, Istanbul-Clover's covered-branch-arm counts, coverlet's `MethodPoint@vc` (covered lines). The model needs a per-observation count kind (exact count / at least once / not an execution count) and must never turn a bool into a count. Merging a count with a bool can only give a bool.

2. **What a line is.** Native per-line records: LCOV, Cobertura, Clover, JaCoCo, gcov, SimpleCov, coverage.py, kcov, tarpaulin, Codecov. Derived from spans, each with a different rule: Istanbul (maximum over statements by start line), llvm (maximum over region starts plus the wrapped segment, ignoring gaps), Go (blocks overlap lines; the rule isn't fixed by the format), OpenCover (sequence points `sl`..`el`), V8 (character ranges, needs source). Two tools can report different line coverage for the same run. The model has to keep native spans where a format has them, and when it derives lines, record which derivation rule it used.

3. **Four states, not two.** Per line (and per branch and function) the formats can say: observed with a value; cannot run (LCOV, Cobertura, Clover, JaCoCo, Go, gcov and Istanbul by leaving it out; SimpleCov and Codecov with `null`; llvm with `hasCount=false`); excluded by the user (coverage.py `excluded_lines`, SimpleCov `"ignored"`, LCOV excluded `BRDA`/`MCDC` and the `U` flag, llvm skipped regions for preprocessor-removed code); not recorded (file or measure missing from the report). Istanbul folds "excluded" into "cannot run", and V8 can't express either. The coverage set needs all four, plus a way to mark "this format can't tell excluded from non-code".

4. **Totals for measures that weren't collected.** coverage.py Cobertura writes `branches-valid="0" branch-rate="0"`, kcov writes `branch-rate="1.0"`, and Istanbul gives `pct` = 100 for an empty total. In contrast, coverage.py JSON leaves the branch keys out, SimpleCov 1.x leaves the sections out, and LCOV master defines `BRF:0` as measured-none and a missing `BRF` as not recorded. A Cobertura branch total of zero can't prove branches were measured, so a reader must not create branch data from it. Rates and percentages in any format are derived and should be ignored when detail records exist.

5. **What one branch is.** For `if (a && b)` tools count different things:
   - LCOV `BRDA` is per edge, with a free-form `<branch>` label.
   - Cobertura and JaCoCo give per-line covered/total only.
   - Clover gives true/false per `cond` line.
   - Istanbul gives one N-location branch per `if`, `switch` or logical expression, typed.
   - llvm gives a true/false pair per leaf condition.
   - gcov gives control-flow edges between basic blocks, with fallthrough and throw flags.
   - coverage.py gives line-to-line arcs.
   - SimpleCov gives `then`/`else`/`when` arms with line spans.
   - OpenCover gives IL branch paths.
   - Dart gives one branch-target line.
   - Codecov gives a `c/t` fraction.

   Branch totals aren't comparable across tools, and a per-line fraction can't be split back into identified branches. The model has to tag branch data with its identity scheme and only merge branches under the same scheme. Patch coverage for branches can only be reported within one scheme.

6. **What a function is and what "covered" means.**
   - LCOV identifies functions by name with aliases (2.2+) and a start line.
   - Istanbul uses a name (or `(anonymous_N)`) plus declaration and body spans.
   - llvm has one record per instantiation, with mangled names.
   - gcov has mangled and demangled names plus spans.
   - JaCoCo uses name, JVM descriptor and first line, and includes generated constructors and initializers.
   - Cobertura uses name and signature, Clover uses signature, SimpleCov uses `Foo#bar` with lines, and OpenCover uses the full signature with return type.
   - Dart keys functions by line. tarpaulin derives them.
   - Go and Codecov have none. coverage.py has named regions but no "entered" flag.

   "Covered" means entered for LCOV, Istanbul, llvm, gcov and JaCoCo, but "100% of lines covered" in PHPUnit's Clover `coveredmethods`. The model needs function identity as (file, span or start line, optional name) and must not treat a coverage.py region or a PHPUnit method count as "function entered".

7. **Statements, blocks and regions.** Istanbul statements, Go blocks with `NumStmt`, llvm regions (code, gap, skipped, expansion), V8 ranges, OpenCover sequence points, gcov basic blocks, and Clover `stmt` (which is really per line). Granularity and counting rules differ: Go counts statements per block, Istanbul counts one per statement node. The model can keep a "region" measure as spans with counts tagged by scheme, but must not compare region totals across tools.

8. **Conditions and MC/DC.** llvm `mcdc_records` (independence pairs plus test vectors), gcov `conditions` (outcomes not seen true or false, by term index), LCOV `MCDC` (sensitized per condition and sense; `taken` may be a count or a bool), Istanbul `bT` (truthiness of logical leaves, which isn't MC/DC). Cobertura's `condition-coverage` is branch data despite its name. A "condition" measure needs a kind (MC/DC independence, condition outcome, truthiness).

9. **Positions.** Lines are 1-based in every record format, but the array forms disagree: Ruby/SimpleCov index 0 = line 1, Codecov list form index = line number, Dart uses flat `[line, count]` pairs. Columns: Istanbul 0-based (ESTree), Go 1-based bytes, gcov 1-based, OpenCover from PDBs (coverlet fakes them). V8 has no lines, only character offsets that include the CommonJS wrapper. LCOV and Cobertura have no columns. The model should store spans with an explicit base and unit, or store lines only and drop columns explicitly.

10. **File identity.**
    - Absolute paths: geninfo `SF`, Istanbul `path`, OpenCover `fullPath`, SimpleCov resultset and legacy JSON, tarpaulin component arrays.
    - Relative to a root the report records: Cobertura `filename` plus `<sources>`, SimpleCov 1.x plus `meta.root`, gcov plus `current_working_directory`.
    - Relative to an unrecorded root: coverage.py JSON, Dart LCOV, kcov after prefix stripping.
    - Language namespace: Go import path, JaCoCo package plus basename, Dart `package:` URIs.
    - URL: V8 `file://`.
    - One record spanning several files: llvm `filenames` plus `fileId`, OpenCover `fileid`, LCOV `SF` index (master), Cobertura with many `<class>` elements sharing a `filename`.

    This feeds the "Path normalization" open item on the map: some forms can only be resolved with repo knowledge (Go module path, JVM source roots).

11. **Tests and other contexts.** LCOV `TN` (several sections per file, one per test), coverage.py contexts (per line), SimpleCov command names and context bitmaps, OpenCover tracked methods, Clover test project and test methods, JaCoCo sessions (not tests). Most formats have none. If the coverage set has an optional context dimension, LCOV `TN` sections can be merged with their test names kept rather than lost. Without one, sections are summed and the names dropped.

12. **Metadata.** Commit: only SimpleCov 1.x `meta.commit`. LCOV `VER` is a per-file version string from a user script, not necessarily a commit. Tool version is in coverage.py `meta.version`, gcov `gcc_version`, SimpleCov `simplecov_version` and OpenCover `Version`. Cobertura `version` and Clover `clover` hold whatever the emitter writes (`"0.1"`, `"1.9"`, `"3.2.0"`). llvm records only the export format version. Timestamps come in milliseconds (coverage.py and Istanbul Cobertura, Istanbul Clover), seconds (kcov Cobertura, PHPUnit Clover, SimpleCov resultset), or ISO strings with a zone (SimpleCov 1.x) or without one (coverage.py JSON). The "same commit only" rule for merge can't rely on report metadata. The commit has to come from the user or CI, and a SimpleCov commit that disagrees can be checked against it.

13. **Redundant and summary-only data.** LCOV `LF/LH/FNF/FNH/BRF/BRH/MCF/MCH`, Cobertura rates and counts, JaCoCo counters, Clover metrics, llvm summaries, coverage.py summaries and totals. lcov itself recomputes these from coverpoints. Some reports are summary-only: llvm `-summary-only`, kcov `coverage.json`, JaCoCo without debug info. The model should recompute summaries from detail, and keep summary-only input as a separate, weaker kind of observation that can be summarized and gated but not merged or used for patch coverage.

14. **Merge rules inside formats.** Go sums duplicate blocks, or ORs them in `set` mode. Istanbul matches by location with a nearest-container fallback. lcov matches branch blocks by signature and order. gcov splits headers across translation units. llvm keeps instantiations separate (`instantiations` summary). SimpleCov merges resultsets by command name. The attra merge needs a stable identity key for each measure and scheme. Where there is none (LCOV branches from different tools), it can merge only at line level.

15. **Formats that need source to interpret.** V8 (offsets to lines; no idea of non-code), coverage.py `.coverage` (no statement set), Istanbul with `inputSourceMap` (transpiled code), Go function coverage, llvm expansions (macros). Two formats embed source: tarpaulin JSON always, SimpleCov 1.x by default. Reading V8 or `.coverage` means attra reads source at the commit, which it can (it's in a git repo), but that's a design decision for the format list.

16. **Format versions drift, and new releases add records.**
    - LCOV added `FNL`/`FNA` in 2.2 and `MCDC` in 2.3. Master adds `^location`, `DA` end lines, `SF` indexes, `FNC`/`FNM` and strict summary pairs.
    - llvm export is at 3.1.0.
    - coverage.py JSON is at format 3.
    - gcov JSON is at format 2.
    - SimpleCov JSON is at schema 1.0–1.4.
    - Cobertura has no format version.

    Parsers must check the version where one exists and accept unknown record types without failing.

## What this changes for other tickets

- **#13 corpus:** collect by emitter, not just by format. At minimum: Cobertura from coverage.py, kcov, Istanbul, gcovr and coverlet; Clover from OpenClover, PHPUnit and Istanbul; LCOV from geninfo, llvm-cov, tarpaulin, Dart/Flutter and Istanbul; OpenCover from coverlet. Include source trees for V8 and `.coverage` samples, plus reports with branch measurement switched off.
- **#14 format list:** V8 JSON and `.coverage` SQLite need source analysis, which is far more work than parsing. OpenCover's main emitter is now coverlet. Cobertura and Clover need emitter detection to read correctly.
- **#15 data model:** items 1–5 above are the minimum: count kind, native spans with a recorded line-derivation rule, four line states, measure presence taken only from explicit evidence, and branch identity schemes.
- **#12 adoption detection:** knowing the emitter matters as much as knowing the format, since the same file name (`coverage.xml`, `clover.xml`, `lcov.info`) holds different data from different tools.
- **Path normalization (map, not specified):** Go import paths and JaCoCo package paths need module or source-root knowledge from the repo.

## Not verified

- Exact `hits` semantics for gcovr's and coverlet's Cobertura output, and for OpenClover's own Clover writer (only the schema was read). These belong in the #13 corpus.
- Whether llvm export columns are 1-based (likely, but not checked in source here), and which older export versions use shorter segment or branch arrays.
- How Go blocks map to lines in tools other than the reference parser.
