# Changelog

## readoecd 0.3.0

CRAN release: 2026-03-12

- Added
  [`get_oecd_cpi()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_cpi.md)
  — annual CPI inflation rate, year-on-year (OECD Prices database).
- Added
  [`get_oecd_deficit()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_deficit.md)
  — general government net lending/borrowing as % of GDP (NAAG).
- Added
  [`get_oecd_inequality()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_inequality.md)
  — Gini coefficient of disposable income (OECD IDD).

## readoecd 0.2.0

- Added
  [`get_oecd_gdp()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_gdp.md)
  — annual GDP at current prices (OECD National Accounts).
- Added
  [`get_oecd_tax()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_tax.md)
  — total tax revenue as % of GDP (OECD Revenue Statistics).
- Added
  [`get_oecd_health()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_health.md)
  — total health expenditure as % of GDP (SHA database).
- Added
  [`get_oecd_education()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_education.md)
  — total education expenditure as % of GDP (EAG UOE Finance).
- Added
  [`get_oecd_productivity()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_productivity.md)
  — GDP per hour worked or per capita (OECD PDB).
- Added `get_oecd_trade()` — annual current account balance in USD (OECD
  BOP).

## readoecd 0.1.0

- Initial release.
- [`get_oecd_unemployment()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_unemployment.md)
  — monthly unemployment rates for all 38 OECD members.
- Utility functions:
  [`list_oecd_countries()`](https://charlescoverdale.github.io/readoecd/reference/list_oecd_countries.md),
  [`check_oecd_api()`](https://charlescoverdale.github.io/readoecd/reference/check_oecd_api.md),
  [`clear_oecd_cache()`](https://charlescoverdale.github.io/readoecd/reference/clear_oecd_cache.md).
- Data is downloaded from the OECD Data Explorer API on first use and
  cached locally.
