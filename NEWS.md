# readoecd 0.3.4

Repair release. Five of the eight data functions were broken against the
live OECD API and returned nothing, or in one case an empty frame, without
saying why. All five work again.

## Errors were being reported as a connection problem

`oecd_fetch()` wrapped `req_perform()` in a `tryCatch` that reported every
failure as "Failed to reach the OECD API. Check your internet connection".
Because `req_perform()` raises on 4xx and 5xx by default, that handler
caught every HTTP error the API returned, so a 404 or a rate limit looked
like a broken network. It also made the 429 and 404 branches further down
the function unreachable: they had never run. The response is now allowed
through with `req_error(is_error = FALSE)`, and the `tryCatch` catches only
genuine transport failures.

With the real errors visible, five separate upstream changes turned up.
Nothing had been withdrawn; the OECD had moved versions and renamed codes.

| Function | Cause | Fix |
|---|---|---|
| `get_oecd_tax()` | Dataflow gained a `CTRY_SPECIFIC_REVENUE` dimension, so the filter was one position short and returned HTTP 422 | Added the position |
| `get_oecd_health()` | Requesting version 1.0 of a dataflow now at 1.1 returns no records | Bumped to 1.1, and `PT_GDP` became `PT_B1GQ` |
| `get_oecd_deficit()` | `CHAPTER = "_Z"` matched nothing | Left the dimension open |
| `get_oecd_current_account()` | `COUNTERPART_AREA`, `FS_ENTRY` and `ADJUSTMENT` all used `_Z` | Now `WXD`, `T` and `N` |
| `get_oecd_productivity()` | `DSD_PDB@DF_PDB_LV` answers HTTP 500 for every query | Reads `DSD_PDB@DF_PDB` version 2.0 |

## Tax revenue was returning an empty frame

Once the request succeeded, `parse_tax()` still returned nothing: all three
of its filters used codes the OECD has since renamed. The institutional
sector total is `S13`, not `_T`, and both revenue dimensions use `_T` rather
than `_Z`. Verified against Australia, which now reports 27.8 to 29.5 per
cent of GDP across 2015 to 2021, matching the published ratio.

## Productivity needed more than a new dataflow

`DF_PDB` is the full productivity database rather than the levels extract
the package used to read, so the same measure code appears as a level, a
growth rate and an index. Taking it unfiltered mixed GDP per hour in US
dollars with percentage changes, including negative values.
`parse_productivity()` now selects the level, PPP-converted, total-economy
slice, and takes chain linked volume rather than current prices: on the
current-price basis Australian GDP per hour rises 38 per cent over 2015 to
2021 against 6 per cent in volume terms, and that difference is inflation
rather than productivity.

## Rate limiting

The API refuses further requests after a few dozen in quick succession,
which a test run or a loop over countries reaches easily. Requests are now
throttled to one per second, and 429 and 5xx responses are explicitly
treated as transient so the existing retry applies to them. The network
tests skip rather than fail when the portal is refusing, via a new
`expect_oecd()` helper, so the suite stays a useful signal.

# readoecd 0.3.4

* Fixed incorrect function name in NEWS.md (`get_oecd_trade` corrected to
  `get_oecd_current_account`).
* Fixed cache tag bug in `get_oecd_unemployment()` when requesting all
  countries.
* Standardised NULL check pattern across all data functions.

# readoecd 0.3.3

* Examples now wrapped in `try()` to handle transient OECD API failures
  gracefully during CRAN checks.

# readoecd 0.3.2

* Removed non-existent pkgdown URL from DESCRIPTION.

# readoecd 0.3.1

* Examples now cache to `tempdir()` instead of the user's home directory,
  fixing CRAN policy compliance for `\donttest` examples.
* Cache directory is now configurable via `options(readoecd.cache_dir = ...)`.

# readoecd 0.3.0

* Added `get_oecd_cpi()` — annual CPI inflation rate, year-on-year (OECD Prices database).
* Added `get_oecd_deficit()` — general government net lending/borrowing as % of GDP (NAAG).
* Added `get_oecd_inequality()` — Gini coefficient of disposable income (OECD IDD).

# readoecd 0.2.0

* Added `get_oecd_gdp()` — annual GDP at current prices (OECD National Accounts).
* Added `get_oecd_tax()` — total tax revenue as % of GDP (OECD Revenue Statistics).
* Added `get_oecd_health()` — total health expenditure as % of GDP (SHA database).
* Added `get_oecd_education()` — total education expenditure as % of GDP (EAG UOE Finance).
* Added `get_oecd_productivity()` — GDP per hour worked or per capita (OECD PDB).
* Added `get_oecd_current_account()` — annual current account balance in USD (OECD BOP).

# readoecd 0.1.0

* Initial release.
* `get_oecd_unemployment()` — monthly unemployment rates for all 38 OECD members.
* Utility functions: `list_oecd_countries()`, `check_oecd_api()`, `clear_oecd_cache()`.
* Data is downloaded from the OECD Data Explorer API on first use and cached locally.
