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
* Added `get_oecd_trade()` — annual current account balance in USD (OECD BOP).

# readoecd 0.1.0

* Initial release.
* `get_oecd_unemployment()` — monthly unemployment rates for all 38 OECD members.
* Utility functions: `list_oecd_countries()`, `check_oecd_api()`, `clear_oecd_cache()`.
* Data is downloaded from the OECD Data Explorer API on first use and cached locally.
