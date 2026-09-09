# CRAN submission comments: readoecd 0.3.4

## Reason for this submission

A repair release. Five of the eight data functions were broken against the
live OECD API. Users got "Failed to reach the OECD API. Check your internet
connection" for every one of them, which was the wrong diagnosis: the API
had answered, and answered with a specific error.

The cause was that `req_perform()` raises on 4xx and 5xx by default, so the
`tryCatch` around it caught every HTTP error and reported them all as a
connection failure. It also made the 429 and 404 handling below it
unreachable. With `req_error(is_error = FALSE)` added, the real errors
surface and the existing status handling works.

That exposed five separate upstream changes. Nothing had been withdrawn:
the OECD moved dataflow versions and renamed dimension codes.

* `get_oecd_tax()`: the dataflow gained a `CTRY_SPECIFIC_REVENUE`
  dimension, so the filter was one position short (HTTP 422).
* `get_oecd_health()`: the dataflow moved to version 1.1, and `PT_GDP`
  became `PT_B1GQ`.
* `get_oecd_deficit()`: `CHAPTER = "_Z"` matched nothing.
* `get_oecd_current_account()`: three dimensions used `_Z` where the data
  now carries `WXD`, `T` and `N`.
* `get_oecd_productivity()`: `DSD_PDB@DF_PDB_LV` answers HTTP 500 for every
  query, so this reads `DSD_PDB@DF_PDB` version 2.0 instead.

`parse_tax()` and `parse_productivity()` needed matching changes, described
in NEWS.md. Every function was verified against live data: Australian tax
revenue now returns 27.8 to 29.5 per cent of GDP across 2015 to 2021, which
matches the published ratio.

## Rate limiting

The API refuses further requests after a few dozen in quick succession.
Requests are now throttled to one per second, 429 and 5xx are treated as
transient so the retry applies, and the network tests skip rather than fail
when the portal is refusing. All network tests remain wrapped in
`skip_on_cran()` and `skip_if_offline()`.

## R CMD check results

0 errors | 0 warnings | 0 notes

Local check: macOS (aarch64), R 4.5.2, `devtools::check(cran = TRUE)`. The
run emits "checking for future file timestamps: unable to verify current
time", which is the checking machine being unable to reach worldclockapi.com
rather than a package fault.

## Downstream dependencies

None.
