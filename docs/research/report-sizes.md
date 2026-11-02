# Real-world report sizes and how fast existing tools parse them

Research for [#11](https://github.com/CraftsmanLabs/attra/issues/11), part of [Map: attra coverage v1](https://github.com/CraftsmanLabs/attra/issues/8). It feeds [Design the coverage set data model](https://github.com/CraftsmanLabs/attra/issues/15).

Gathered 2026-11-02. Each number is marked as **measured** (I ran it; the method is given) or **reported** (someone else's number, linked).

## Summary

- The largest real workloads I could get:
  - Home Assistant's CI: 20 Cobertura reports from coverage.py, 83 MB, 2.15M line records, 10,947 files, 634k lines after merging.
  - Kubernetes' unit test job: one 24 MB Go coverprofile, 320k blocks, 3,742 files, 713k lines.
- Codecov's public totals for large repos top out at about the same size: 10.6k files and 634k lines for Home Assistant, 9.4k files and 405k lines for Sentry. The largest reported cases are about 800k lines (LLVM, used as an lcov test case) and a 200 MB upload to Codecov.
- Existing tools took between 0.5 s and 230 s, and between 40 MB and 950 MB of memory, to merge or summarize these workloads. A plain native parser of about 70 lines did the same parse and merge in 0.1 to 0.3 s with 38 MB.
- So the proposed budgets come from what a simple native program achieves, with headroom, and not from what existing tools do.
- Report bytes are a poor measure of workload. The same coverage takes about 10 bytes per line in LCOV, 34 in a Go coverprofile, 38 in coverage.py's Cobertura and over 90 in Istanbul JSON. So the budgets count line records, with bytes per second as a secondary check for each format.
- Reports from different CI shards of the same repo use different path roots. Merging Home Assistant's 20 reports by their literal paths gives 21,080 files and 1.24M lines instead of 10,947 and 634k. Paths have to be normalized before merging.

## Proposed budgets

Reference machine: a GitHub-hosted standard Linux runner for public repos, which has 4 CPUs and 16 GB RAM. Private repos get 2 CPUs and 8 GB ([GitHub docs](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)).

Times are wall clock, with the reports already in the page cache. A "line record" is one (file, line, count) entry in an input report. The "Home Assistant workload" is the 20 real reports described under Report sizes.

| Budget | Target | Measured baseline (M1 Max, 1 thread) | Existing tools on the same data |
|---|---|---|---|
| Parse, line-based formats (LCOV, Go coverprofile) | at least 200 MB/s per core | 320 to 800 MB/s | gocovmerge on Kubernetes: about 33 MB/s |
| Parse, XML and JSON formats (Cobertura, JaCoCo, Istanbul, llvm-cov) | at least 100 MB/s per core | 330 to 365 MB/s (Cobertura, simple scanner) | ReportGenerator on Kubernetes as Cobertura: about 9 MB/s |
| Merge | at most 100 ns per input line record | 42 ns (Home Assistant, 2.15M records, `qsort`) | `lcov -a`: about 2,800 ns |
| Home Assistant workload: parse, merge and summary | under 1 s and under 100 MB peak memory | 0.12 s and 38 MB (LCOV); 0.3 s (real Cobertura) | coverage.py combine: 0.5 s, 42 MB (its data files hold executed lines only); nyc: 3.1 s, 950 MB; lcov: 6.1 s, 147 MB; ReportGenerator: 12 s, 224 MB (as LCOV) to minutes (real Cobertura) |
| Memory | at most 32 bytes per distinct (file, line) in the coverage set, plus a bounded input buffer. Peak memory does not grow with input bytes | 16 bytes per record, holding every input record | nyc: about 440 bytes per input record |
| Overhead per report | at most 1 ms per input report | not measured separately | coverage.py combine: about 26 ms per data file |
| Scale ceiling (must complete) | 1 GB of input and 10M distinct lines in under 10 s and under 1 GB memory | extrapolated from the linear measurements | reported failures: nyc out of heap; a 200 MB Codecov upload dropped |
| Startup on a tiny report | under 10 ms | | |

Why these numbers:

- **Throughput.** The baseline parser reaches 300 to 800 MB/s with no SIMD and no threads. Budgets of 200 MB/s (100 MB/s for XML and JSON) leave room for full validation, a conforming XML tokenizer and error reporting. At those rates the largest real workload still finishes well under a second. Parsing several reports on separate threads is extra headroom; the budget does not depend on it.
- **Merge cost per input record.** Merging shards multiplies records. Home Assistant has 2.15M input records for 634k distinct lines, 3.4 records per line. Counting input records covers both one huge report and many overlapping ones.
- **Memory.** All the tools measured except coverage.py and gocovmerge build objects per line or per file, and used 150 to 950 MB on these workloads. A structure-of-arrays coverage set with interned paths needs 16 bytes per line: a 4-byte file id, a 4-byte line number and an 8-byte count. A 32-byte budget leaves room for branch and function data. Merging while streaming ties peak memory to the number of distinct lines, not to input size.
- **Overhead per report.** Real repos produce thousands of small reports. One user had 8,500 coverage.py data files and combine took 45 to 95 minutes; another found 68,000 ([coveragepy#1483](https://github.com/coveragepy/coveragepy/issues/1483)). At 1 ms per report, 10,000 reports cost 10 s.
- **Scale ceiling.** A Codecov user uploaded a report of about 200 MB ([codecov/feedback#640](https://github.com/codecov/feedback/issues/640)), and Codecov accepts up to 150 uploads per commit ([Codecov FAQ, v4.6 docs](https://docs.codecov.com/v4.6/docs/frequently-asked-questions)). 1 GB is about 5x the largest single report I found reported. Linear scaling from the measurements puts it at a few seconds.

## Report sizes

### Real reports I downloaded (measured)

| Repo and job | Format and emitter | Reports | Bytes | Files | Line records | Distinct lines after merge |
|---|---|---|---|---|---|---|
| [kubernetes/kubernetes](https://github.com/kubernetes/kubernetes) `ci-kubernetes-coverage-unit`, build 2117263867791806464, commit `512785fb` | Go coverprofile (`mode: atomic`) | 1 | 24,135,170 | 3,742 | 320,330 blocks (442,995 statements) | 712,627 (block line ranges expanded); 362,476 hit |
| same build, after `gopherage filter` drops generated code | Go coverprofile | 1 | 14,853,689 | | | |
| [home-assistant/core](https://github.com/home-assistant/core) CI run [41474819007](https://github.com/home-assistant/core/actions/runs/41474819007), `dev` branch | Cobertura XML from coverage.py 7.17.0 | 20 (10 test shards, 10 database variants) | 82,880,301 | 10,947 | 2,153,870 | 634,208; 580,460 hit (91.52%) |
| same run, largest report (shard 1) | Cobertura XML | 1 | 24,628,822 | 10,947 | 634,208 | |

Sources and method:

- Kubernetes publishes the job's artifacts in a public bucket. The build list is at `https://storage.googleapis.com/storage/v1/b/kubernetes-ci-logs/o?prefix=logs/ci-kubernetes-coverage-unit/`, and the profile is at `.../2117263867791806464/artifacts/combined-coverage.out`. The job's `prowjob.json` shows it runs `make test KUBE_COVER=y`, then `gopherage filter` and `gopherage junit`. The seven most recent finished builds were all 24.1 MB, and their filtered profiles 14.9 MB.
- Home Assistant uploads one `coverage-*` artifact for each pytest shard and each database variant, then sends them to Codecov. I downloaded them with `gh run download 41474819007 -R home-assistant/core -p 'coverage-*'` and counted `<class>` and `<line>` elements with a streaming XML parse.
- My merged Home Assistant numbers match Codecov's own totals for the repo: 634,294 lines, 580,508 hits, 91.52%. Those come from `https://api.codecov.io/api/v2/github/home-assistant/repos/core/totals/`, fetched the same day for a nearby commit. The match is a check that the merge is right.
- Home Assistant's shard 1 lists every file in the source tree, mostly at 0 hits (line-rate 11.85%). Its `<source>` is `/home/runner/work/core/core/homeassistant`, with paths like `__init__.py`. The other shards use `/home/runner/work/core/core`, with paths like `homeassistant/__main__.py`. coverage.py picks the source root separately for each run, so one CI run gives the same file two different names.

### Codecov's public totals for large repos (reported by Codecov)

Codecov's API reports tracked files and lines for public repos at `GET https://api.codecov.io/api/v2/github/{owner}/repos/{repo}/totals/`. It needs no token. I fetched these on 2026-11-02. The ten largest by file count of the 60 repos I queried:

| Repo | Files | Lines tracked |
|---|---|---|
| home-assistant/core | 10,613 | 634,294 |
| getsentry/sentry | 9,442 | 404,944 |
| apache/shardingsphere | 4,376 | 91,341 |
| open-telemetry/opentelemetry-collector-contrib | 3,142 | 325,428 |
| saltstack/salt | 2,527 | 357,655 |
| zulip/zulip | 2,374 | 251,694 |
| apache/dubbo | 1,953 | 89,286 |
| apache/pulsar | 1,952 | 154,582 |
| ansible/ansible | 1,859 | 125,837 |
| mastodon/mastodon | 1,740 | 43,919 |

Other data points:

- scipy: 1,582 files, 275k lines.
- pandas: 1,327 files, 294k lines.
- nodejs/node: 428 files, 196k lines.

Several large repos returned no totals, among them kubernetes, envoy, mypy, vscode and rust, so this list undercounts the largest projects. Kubernetes alone (713k lines, measured above) is larger than any repo on the list.

### Sizes other people reported

- An lcov user: a tracefile with about 700 files, 300k+ lines, 20k+ functions and 100k+ branches ([lcov#284](https://github.com/linux-test-project/lcov/issues/284)).
- The lcov maintainer: they test lcov on LLVM, "about 800K LOC". In the same thread, a user has a single generated SWIG C++ file of 77k lines ([lcov#329](https://github.com/linux-test-project/lcov/issues/329)).
- ReportGenerator users:
  - a 55 MB Cobertura file from Rx.NET ([ReportGenerator#255](https://github.com/danielpalme/ReportGenerator/issues/255))
  - a report with more than 16k classes ([#375](https://github.com/danielpalme/ReportGenerator/issues/375))
  - an OpenCover report with 3,365 classes and 72,967 sequence points ([#170](https://github.com/danielpalme/ReportGenerator/issues/170))
- coverage.py users: 8,500 parallel data files from one test run, and 68,000 in another project's `.tox` directory ([coveragepy#1483](https://github.com/coveragepy/coveragepy/issues/1483)).
- A self-hosted Codecov user: a raw upload of about 200 MB ([codecov/feedback#640](https://github.com/codecov/feedback/issues/640)).

### Bytes per line record, by format (measured)

The same coverage takes very different amounts of space in different formats. I converted the two real datasets into other formats with `convert.py` (method under "How fast existing tools are") and divided each file's size by its line records.

| Format | Kubernetes (712,627 lines) | Home Assistant (2,153,870 records) |
|---|---|---|
| LCOV (`SF`/`DA` only) | 7.3 MB, 10 B/line | 21.1 MB, 10 B/record |
| Go coverprofile (real) | 24.1 MB, 34 B/line (75 B/block) | |
| Cobertura, coverage.py's real output | | 82.9 MB, 38 B/record |
| Cobertura, minimal (one package) | 22.7 MB, 32 B/line | 69.8 MB, 32 B/record |
| Istanbul JSON, one statement per line, no functions or branches | 67.4 MB, 95 B/line | 199.0 MB, 92 B/record |
| coverage.py SQLite data files | | 6.0 MB in total; they store only executed lines, as bitmaps |

The Istanbul sizes are a lower bound, because real Istanbul files also carry column ranges, function maps and branch maps. I did not measure real JaCoCo, llvm-cov export JSON, Clover, OpenCover or SimpleCov reports; [#13](https://github.com/CraftsmanLabs/attra/issues/13) builds that corpus.

## How fast existing tools are

### Measured

Setup:

- **Machine:** Apple M1 Max (10 cores), 32 GB RAM, macOS 26.3. Files were on a local SSD and already in the page cache.
- **Measurement:** wall time and peak memory (RSS) from `/usr/bin/time -l`, single runs. Repeat runs of lcov, nyc, coverage.py and the baseline were within 10%, apart from the baseline's first, cold run.
- **Versions:** lcov 2.6, coverage.py 7.17.0 (C extension), nyc 17.1.0 on Node 24.22.0, ReportGenerator 5.5.12 on .NET 10.0.9, and the latest gocovmerge built with Go 1.26.0.

Inputs: only Kubernetes' coverprofile and Home Assistant's Cobertura files are real. Each tool reads only some formats, so I converted the real data into each tool's format with [`convert.py`](report-sizes-scripts/convert.py), keeping files, lines and hit counts:

- **LCOV:** one `SF` record per file, with `DA:line,count` and `LF`/`LH`.
- **Istanbul JSON:** one statement per line.
- **coverage.py data files:** one per Home Assistant shard, written with coverage.py's own `CoverageData` API. They hold only executed lines, so they carry less data than the other formats.
- **Go blocks:** each block is expanded to every line it spans, keeping the highest count for each line.

The converted files match the real data's files, lines and counts, but lack each format's extras (branches, functions, columns). Real files in those formats would take somewhat longer to read.

| Tool and operation | Input | Wall | Peak RSS |
|---|---|---|---|
| `lcov -a` (20 inputs) `-o merged` | Home Assistant, 20 LCOV files, 21 MB | 6.1 s | 147 MB |
| `lcov --summary` | merged Home Assistant LCOV, 6.5 MB | 2.0 s | 88 MB |
| `lcov --summary` | Kubernetes LCOV, 7.3 MB | 1.4 s | 67 MB |
| `genhtml --synthesize-missing` (no sources present) | merged Home Assistant LCOV | 27.1 s | 696 MB |
| `genhtml --synthesize-missing` | Kubernetes LCOV | 20.9 s | 546 MB |
| `coverage combine --keep` | Home Assistant, 20 data files, 6 MB | 0.5 s | 42 MB |
| `coverage combine --keep` | 200 distinct data files (random halves of the 20 shards, [`covpy_many.py`](report-sizes-scripts/covpy_many.py)), 57 MB | 5.3 s | 47 MB |
| `nyc merge` | Home Assistant, 20 Istanbul JSON files, 199 MB | 3.1 to 3.5 s | 920 to 960 MB |
| `nyc report --reporter=text-summary` | the same 20 files, unmerged | 3.0 s | 808 MB |
| `nyc report --reporter=text-summary` | merged Home Assistant JSON, 48 MB | 1.3 s | 406 MB |
| `nyc report --reporter=lcovonly` | Kubernetes Istanbul JSON, 67 MB | 2.6 s | 473 MB |
| `gocovmerge` | Kubernetes profile, 1 file | 0.73 s | 43 MB |
| `gocovmerge` | Kubernetes profile split into 20 per-package profiles | 1.09 s | 44 MB |
| `gocovmerge` | Kubernetes profile given twice (full overlap) | 0.77 s | 70 MB |
| ReportGenerator, TextSummary | Kubernetes LCOV | 1.0 s | 188 MB |
| ReportGenerator, TextSummary | Kubernetes minimal Cobertura, 22.7 MB | 2.5 s | 581 MB |
| ReportGenerator, TextSummary | Home Assistant, 20 LCOV files | 12.0 s | 224 MB |
| ReportGenerator, TextSummary | Home Assistant shard 10, real coverage.py Cobertura, 9.8 MB, 4,720 files | 99.7 s (2.4 s CPU) | 193 MB |
| ReportGenerator, TextSummary | Home Assistant shard 1, real Cobertura, 24.6 MB, 10,947 files | 229 s (5.3 s CPU) | 342 MB |
| **Baseline C parser** (below): parse and merge | Home Assistant, 20 LCOV files | 0.12 s | 38 MB |
| **Baseline:** parse and merge | Home Assistant, 20 real Cobertura files, 83 MB | 0.29 s | |
| **Baseline:** parse | Kubernetes coverprofile | 0.03 s | 38 MB |

Notes:

- **ReportGenerator on coverage.py's Cobertura output:**
  - It spent almost all its time waiting rather than computing: 229 s of wall time against 5.3 s of CPU. A `sample` of the process showed the main thread waiting and worker threads yielding.
  - The same Home Assistant data as LCOV took 12 s.
  - Two changes made no difference: running from an empty directory with `numberOfReportsParsedInParallel=1` (99.4 s), and raising the .NET thread pool minimum to 64 threads (98.7 s).
  - Its Cobertura parser handles each `<package>` in turn (shard 10 has 795) and runs a `Parallel.ForEach` over each package's classes ([CoberturaParser.cs](https://github.com/danielpalme/ReportGenerator/blob/0d522036e9921041665129f6a386b7c56158054d/src/ReportGenerator.Core/Parser/CoberturaParser.cs#L63-L135)).
  - I did not find the root cause.
  - Others have reported single files taking minutes: 500 s for a 55 MB file, down to 50 s after a fix ([#255](https://github.com/danielpalme/ReportGenerator/issues/255)), and 10 to 15 minutes for 16k classes ([#375](https://github.com/danielpalme/ReportGenerator/issues/375)).
- **lcov `--parallel`** failed on this machine (a Perl module was missing), so the lcov numbers are for a single process. Upstream, `--parallel` has been reported to make genhtml slower. For 700 files and 300k lines, genhtml took 24 s with lcov 1.14, 75 s with 2.0, and 157 s with 2.0 `--parallel` ([lcov#284](https://github.com/linux-test-project/lcov/issues/284)).
- **coverage.py combine** costs little per line, because its data files store executed line numbers as bitmaps in SQLite. Its cost is per data file: about 26 ms each here. That is what hurts users with thousands of files. After [#1483](https://github.com/coveragepy/coveragepy/issues/1483), combine skips data files whose contents are identical.
- **nyc** loads all the JSON into JavaScript objects. Its 920 MB peak for 2.15M records is about 440 bytes per record. It has run out of heap reading reports on a 72-core machine, because it read too many reports in parallel ([nyc#1309](https://github.com/istanbuljs/nyc/issues/1309)).
- **Codecov:**
  - Its worker parses uploads in Python (log lines in [codecov/feedback#640](https://github.com/codecov/feedback/issues/640)).
  - Its newer Rust library, `codecov-rs`, converts reports to a SQLite format "inspired by coverage.py". Its README advises that parsers "should not load their entire input or output into RAM" and should stream or use mmap instead ([codecov-rs README](https://github.com/codecov/codecov-rs/blob/665e89f3a09df27c678c1fccd928d722702262ed/README.md)).
  - I found no published parse-time numbers.
  - Its documented limit is 150 uploads per commit ([FAQ](https://docs.codecov.com/v4.6/docs/frequently-asked-questions)).
  - A self-hosted user's 200 MB upload was never processed: the worker looked for it before the upload had finished, and gave up instead of retrying ([codecov/feedback#640](https://github.com/codecov/feedback/issues/640)).

### Reported by others

| Tool | Workload | Time or memory | Source |
|---|---|---|---|
| genhtml 1.14 / 2.0 / 2.0 `--parallel` | ~700 files, 300k+ lines, 100k+ branches, 16 cores | 24 s / 75 s / 157 s | [lcov#284](https://github.com/linux-test-project/lcov/issues/284) |
| genhtml 2.2 | 270k-line C++ library with a 77k-line generated file | spiked to 70% of 32 GB and the machine stopped responding; 2.1 stayed under 6% | [lcov#329](https://github.com/linux-test-project/lcov/issues/329) |
| coverage.py combine 4.0a6 / 5.0 | 8,500 data files | 45 min / 95 min | [coveragepy#1483](https://github.com/coveragepy/coveragepy/issues/1483) |
| ReportGenerator before / after 4.2.1 | 55 MB Cobertura | 500 s / 50 s | [ReportGenerator#255](https://github.com/danielpalme/ReportGenerator/issues/255) |
| ReportGenerator | 16k classes, HTML report | 10 to 15 min | [ReportGenerator#375](https://github.com/danielpalme/ReportGenerator/issues/375) |
| ReportGenerator 3.1 / 4.0 | OpenCover report, 3,365 classes | 6 s / 160 s (caused by history charts; fixed in 4.0.1) | [ReportGenerator#170](https://github.com/danielpalme/ReportGenerator/issues/170) |
| ReportGenerator 4.1 | 1.35 MB Visual Studio coverage XML | used all RAM on a 32 GB machine, because of one bogus line number, 0xF00F00 | [ReportGenerator#251](https://github.com/danielpalme/ReportGenerator/issues/251) |
| nyc report | many reports on 72 cores | JavaScript heap out of memory | [nyc#1309](https://github.com/istanbuljs/nyc/issues/1309) |

Two of these failures were memory blowups caused by odd input, not by size: one bogus line number (0xF00F00) in a 1.35 MB file, and one 77k-line generated file. These are the failure modes to design against: a data model sized by the largest line number, or a renderer that builds structures for every line of a huge file.

## Baseline parser (measured)

[`parse.c`](report-sizes-scripts/parse.c) is 70 lines of C, compiled with `clang -O2` (Apple clang 21). It shows what a simple native program achieves, which gives the budgets a floor grounded in measurement. It is not a design for attra.

What it does:

- Maps each file into memory with `mmap` and scans it once, reading:
  - LCOV: `SF` and `DA` lines.
  - Go coverprofile: `file:sl.sc,el.ec n count` lines, expanding each block to the lines it spans.
  - Cobertura: `<class filename=...>` and `<line number=... hits=...>`. This is a scanner, not a conforming XML parser.
- Interns paths in an open-addressing hash table, so each record carries a 4-byte file id.
- Appends records to one flat array of `{u64 key = file<<32 | line, u64 hits}`.
- Merges by sorting on the key (`qsort`) and summing the hits of equal keys.

| Input | Bytes | Records | Parse | MB/s | Merge |
|---|---|---|---|---|---|
| Kubernetes coverprofile, warm | 24.1 MB | 714,837 | 0.030 s | 800 | 0.004 s |
| Kubernetes coverprofile, first run | 24.1 MB | 714,837 | 0.075 s | 320 | 0.004 s |
| Kubernetes LCOV | 7.3 MB | 712,627 | 0.023 s | 320 | 0.004 s |
| Kubernetes minimal Cobertura | 22.7 MB | 712,627 | 0.064 s | 356 | 0.004 s |
| Home Assistant, 20 LCOV files, warm | 21.1 MB | 2,153,870 | 0.028 s | 750 | 0.090 s |
| Home Assistant, 20 real Cobertura files | 82.9 MB | 2,153,870 | 0.227 s | 365 | 0.067 s |

Peak memory was 38 MB for both Home Assistant LCOV and Kubernetes. The Kubernetes merge is fast because its records arrive already sorted. Home Assistant's 2.15M unsorted records take 90 ms in `qsort`, 42 ns per record. A radix sort or accumulating per file would be faster.

When the baseline merges Home Assistant's real Cobertura files by their literal paths, it finds 21,080 files and 1,235,472 lines instead of 10,947 and 634,208. The shards use two different source roots (see Report sizes). The LCOV run used paths normalized by `convert.py`, and it matches Codecov's totals.

## What this means for other tickets

- **[#15, data model](https://github.com/CraftsmanLabs/attra/issues/15):**
  - Even for the largest repos found, a structure-of-arrays coverage set fits in tens of megabytes, so raw size is not the hard part.
  - The hard parts are bounding memory against hostile or odd input (huge line numbers, huge generated files) and keeping the cost per report small.
  - Line numbers should be stored sparsely for each file, not as arrays indexed by line number.
- **Path normalization (listed under "Not yet specified" on the map):** a single Home Assistant CI run writes two different source roots, so merges are wrong without normalization. It has to happen before paths are interned.
- **[#13, corpus](https://github.com/CraftsmanLabs/attra/issues/13):** two large public sources are easy to fetch:
  - Kubernetes' coverage job, in the `kubernetes-ci-logs` bucket, over anonymous HTTP.
  - Home Assistant's `coverage-*` artifacts, with `gh run download`. These artifacts expire.
  
  Codecov's totals API also ranks repos by size for free.
- **[#14, format list](https://github.com/CraftsmanLabs/attra/issues/14):** coverage.py users often have SQLite data files rather than XML. Reading those directly avoids an 80 MB XML round trip, but needs SQLite.

## Reproducing

The scripts are in [`report-sizes-scripts/`](report-sizes-scripts/). The downloaded and generated reports, about 500 MB, are not committed.

1. **Kubernetes:** run `curl -O https://storage.googleapis.com/kubernetes-ci-logs/logs/ci-kubernetes-coverage-unit/<build>/artifacts/combined-coverage.out`. Take `<build>` from `.../ci-kubernetes-coverage-unit/latest-build.txt`. A build still in progress has no artifacts yet, so if it has none, take an earlier one from the bucket listing.
2. **Home Assistant:** run `gh run list -R home-assistant/core -w CI -b dev -s success`, then `gh run download <id> -R home-assistant/core -p 'coverage-*' -D ha`.
3. **Convert:** run `python convert.py go combined-coverage.out gen/k8s 20` and `python convert.py ha ha gen/ha`. The second needs `coverage` installed, to write the data files.
4. **Baseline:** build with `clang -O2 -o parse parse.c`, then run `./parse lcov gen/ha/*.info`, `./parse cob ha/*/coverage.xml` and `./parse go combined-coverage.out`.
5. **Tools:** `bench.sh <label> <command...>` prints wall time and peak memory. The commands are in the measured table above. lcov 2.6 needs `--ignore-errors empty,empty` for line-only input. nyc needs `--exclude-after-remap=false` and `--temp-dir=<dir>` (with `=`) to read JSON whose paths are outside the working directory. ReportGenerator needs `DOTNET_ROOT` set when .NET comes from Homebrew.
