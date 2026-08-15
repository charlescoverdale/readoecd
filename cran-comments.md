# CRAN submission comments — readoecd 0.3.4

## Reason for this submission

This is a maintenance update to readoecd 0.3.3, currently on CRAN.

* Fixed a cache tag bug in `get_oecd_unemployment()` when requesting all
  countries, where the request did not get a distinct cache key.
* Standardised the NULL check pattern across the data functions.
* Corrected a function name in NEWS.md (`get_oecd_trade` should have
  read `get_oecd_current_account`).

No API changes.

## R CMD check results

0 errors | 0 warnings | 0 notes (CRAN default settings, R 4.5.2, macOS).

## Notes on data access

Unchanged: the package targets the OECD SDMX endpoint that replaced
OECD.Stat, calling it on demand and caching locally using
`tools::R_user_dir()`. No data is bundled. Network-using examples are
wrapped in `\donttest{}` and tests in `skip_on_cran()`, so the check does
not depend on the endpoint being reachable.

## Downstream dependencies

None on CRAN.
