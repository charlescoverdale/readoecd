# CRAN submission comments — readoecd 0.3.0

## R CMD check results

0 errors | 0 warnings | 3 notes

Checked on: macOS Sequoia 15.6.1 (aarch64), R 4.5.2.
Also submitted to win-builder (R-devel and R-release).

### Note 1: New submission

Expected for a first CRAN submission.

### Note 2: pandoc not available

> Files 'README.md' or 'NEWS.md' cannot be checked without 'pandoc' being installed.

This is a local environment issue — pandoc is not installed in the check environment.
README.md and NEWS.md are both well-formed Markdown. CRAN's servers have pandoc installed.

### Note 3: HTML Tidy version

> Skipping checking HTML validation: 'tidy' doesn't look like recent enough HTML Tidy.

This is a local environment issue — the installed HTML Tidy binary is older than required
for the check. CRAN's servers have a recent version of HTML Tidy.

## Network-dependent examples and tests

All examples that make live API calls are wrapped in `\donttest{}`. The single exception,
`check_oecd_api()`, uses `\dontrun{}` as it is a connectivity diagnostic whose outcome
depends on real-time API availability.

All network-dependent tests use `skip_on_cran()` and `skip_if_offline()`, so the test
suite passes cleanly on CRAN without any network calls.

## Spell check

`devtools::spell_check()` flags only legitimate technical terms and proper nouns:
COICOP, EAG, Gini, IDD, ISCED, NAAG, OECD, PDB, SDMX, SNA, UOE — all standard
abbreviations used by the OECD in their official documentation.

## OECD API

Data is downloaded from the OECD Data Explorer REST API (sdmx.oecd.org). This is the
official public API provided by the OECD. No authentication or API key is required.
