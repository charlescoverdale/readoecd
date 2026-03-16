# CRAN submission comments — readoecd 0.3.1

## Resubmission

This is an update to readoecd 0.3.0 (currently on CRAN). Changes made in
response to CRAN feedback (Prof Ripley, 2026-03-15):

* Examples now cache to `tempdir()` instead of the user's home directory,
  fixing CRAN policy compliance for `\donttest` examples.
* Cache directory is now configurable via `options(readoecd.cache_dir = ...)`.

## R CMD check results

0 errors | 0 warnings | 0 notes

Checked on: macOS Sequoia 15.6.1 (aarch64), R 4.5.2.

## Network-dependent examples and tests

All examples that make live API calls are wrapped in `\donttest{}`, with
caching redirected to `tempdir()` so that no files are written to the user's
home filespace. The single exception, `check_oecd_api()`, uses `\dontrun{}`
as it is a connectivity diagnostic whose outcome depends on real-time API
availability.

All network-dependent tests use `skip_on_cran()` and `skip_if_offline()`, so
the test suite passes cleanly on CRAN without any network calls.

## OECD API

Data is downloaded from the OECD Data Explorer REST API (sdmx.oecd.org). This
is the official public API provided by the OECD. No authentication or API key
is required.

## Downstream dependencies

None.
