# CRAN submission comments — readoecd 0.1.0

## R CMD check results

0 errors | 0 warnings | 2 notes

### Note 1: New submission

Expected for a first submission.

### Note 2: pandoc not available

> Files 'README.md' or 'NEWS.md' cannot be checked without 'pandoc' being installed.

This is an environment issue — pandoc is not installed in the local check environment.
README.md and NEWS.md are both well-formed Markdown. CRAN's servers have pandoc installed.

## Network-dependent examples and tests

All examples that make live API calls are wrapped in `\donttest{}`. The single exception,
`check_oecd_api()`, uses `\dontrun{}` as it is a connectivity diagnostic whose outcome
depends on real-time API availability.

All network-dependent tests use `skip_on_cran()` and `skip_if_offline()`, so the test
suite passes cleanly on CRAN.

## OECD API

Data is downloaded from the OECD Data Explorer REST API (sdmx.oecd.org). This is the
official public API provided by the OECD. No authentication is required and no API key
is needed.
