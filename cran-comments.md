# CRAN submission comments: readoecd 0.3.5

## Reason for this submission

A bug-fix release. Every data function returned its locally cached copy
indefinitely, so repeated calls never saw later OECD releases or
revisions. Cached copies now expire after 7 days (configurable with an
option). `citation("readoecd")` also reported a hard-coded version; it now
reads the installed one.

## R CMD check results

0 errors | 0 warnings | 0 notes

Local check: macOS (aarch64), R 4.5.2, `R CMD check --as-cran
--run-donttest`. The run emits "checking for future file timestamps:
unable to verify current time", which is the checking machine being
unable to reach worldclockapi.com rather than a package fault.

All network tests remain wrapped in `skip_on_cran()` and
`skip_if_offline()`, and requests are throttled to stay under the API's
rate limit.

## Downstream dependencies

None.
