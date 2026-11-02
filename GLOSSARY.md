# Attra

Attra is a code quality CLI for humans and their agents. This glossary covers `attra coverage`, which reads, combines and acts on coverage reports produced by other tools.

## Coverage

**Report**:
A file of coverage data in some external format, produced by a tool other than attra.
_Avoid_: Coverage file, result

**Format**:
The schema a report is written in, such as LCOV or Cobertura.
_Avoid_: Type, flavor

**Coverage set**:
Attra's normalized record of which code ran, for exactly one commit, built from one or more reports. For each source file and measure it records what was observed, and records "not recorded" rather than zero where nothing was observed.
_Avoid_: Coverage data, profile, snapshot

**Measure**:
One kind of coverage, such as line, branch, function, region or condition.
_Avoid_: Metric, coverage type

**Merge**:
Combining two coverage sets for the same commit into one, losing nothing either recorded and inventing nothing neither recorded.
_Avoid_: Combine, aggregate, union

**Patch coverage**:
Coverage of the lines changed between a base commit and the commit a coverage set describes.
_Avoid_: Diff coverage, delta coverage

## Adoption

**Adoption**:
Moving a repo onto `attra coverage`, whether by migration or by setup.
_Avoid_: Onboarding, integration

**Migration**:
Adoption that replaces a repo's existing coverage setup.
_Avoid_: Conversion, switch-over

**Setup**:
Adoption in a repo that has no coverage today.
_Avoid_: Install, bootstrap
