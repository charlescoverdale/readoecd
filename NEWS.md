# readoecd 0.1.0

* Initial release.
* Provides tidy access to 10 key OECD economic datasets via `get_oecd_*()` functions.
* Covers: GDP, unemployment, CPI, tax revenue, government debt, government deficit,
  income inequality, health expenditure, education expenditure, labour productivity,
  and trade balance.
* Data is downloaded from the OECD Data Explorer API on first use and cached locally.
* Utility functions: `list_oecd_countries()`, `check_oecd_api()`, `clear_oecd_cache()`.
