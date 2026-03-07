# readoecd

**readoecd** provides clean, tidy access to OECD economic data directly from R.

Data is downloaded from the [OECD Data Explorer API](https://data-explorer.oecd.org) on first use and cached locally — no repeated downloads needed.

## Installation

```r
# Install from GitHub (CRAN submission in progress)
# install.packages("remotes")
remotes::install_github("charlescoverdale/readoecd")
```

## Usage

```r
library(readoecd)

# Monthly unemployment rates — Australia, UK, and USA since 2010
unemp <- get_oecd_unemployment(c("AUS", "GBR", "USA"), start_year = 2010)
head(unemp)
#>   country country_name  period            series value               unit
#> 1     AUS    Australia 2010-01 Unemployment rate   5.2 % of labour force
#> 2     AUS    Australia 2010-02 Unemployment rate   5.3 % of labour force
#> ...

# All 38 OECD members
unemp_all <- get_oecd_unemployment(start_year = 2020)

# See all available country codes
list_oecd_countries()

# Check the cache
clear_oecd_cache()
```

## Functions

| Function | Description |
|---|---|
| `get_oecd_unemployment()` | Monthly unemployment rate (% of labour force) |
| `list_oecd_countries()` | List all 38 OECD member country codes and names |
| `check_oecd_api()` | Test connectivity to the OECD API |
| `clear_oecd_cache()` | Delete all locally cached data files |

## Data output

All `get_oecd_*()` functions return a tidy data frame with consistent columns:

| Column | Type | Description |
|---|---|---|
| `country` | character | ISO 3166-1 alpha-3 code (e.g. `"AUS"`) |
| `country_name` | character | English country name |
| `period` | character | `"YYYY-MM"` for monthly data |
| `series` | character | Series label |
| `value` | numeric | Observation value |
| `unit` | character | Unit of measurement |

## Caching

Downloaded data is stored in your user cache directory (`tools::R_user_dir("readoecd", "cache")`). Subsequent calls return the cached copy instantly. Use `refresh = TRUE` to force a re-download, or `clear_oecd_cache()` to wipe all cached files.

## API stability

readoecd uses the OECD Data Explorer REST API (`sdmx.oecd.org`). The OECD periodically migrates dataset identifiers — if a function stops working, check for a package update or [file an issue](https://github.com/charlescoverdale/readoecd/issues).

## Background: the existing OECD package

There is an existing R package called [OECD](https://cran.r-project.org/package=OECD), written by Eric Persson and first published on CRAN in 2016. It is a generic API wrapper — rather than providing named functions for specific datasets, it exposes the raw OECD SDMX API directly. The typical workflow requires the user to first browse available datasets with `search_dataset()`, then retrieve dimension codes with `get_data_structure()`, then construct a filter string manually before finally calling `get_dataset()`. This gives maximum flexibility but places the burden of knowing the OECD's dataset catalogue and dimension codes entirely on the user.

**The CRAN version (v0.2.5, released December 2021) is currently broken.** In July 2024, the OECD migrated their API from the old endpoint (`stats.oecd.org`) to a new SDMX 3.0 REST API (`sdmx.oecd.org`). The CRAN version still points at the old endpoint, which no longer returns data. Despite being broken, the package still attracts around 700–1,400 downloads per month — reflecting how many analysts depend on OECD data in R and have no working alternative.

**Eric's GitHub version is partially updated** ([expersso/OECD](https://github.com/expersso/OECD)). He updated the package in August 2025 to target the new API, but this version has not been submitted to CRAN and is not widely known. It remains a generic wrapper: it still requires users to know dataset IDs and construct their own filter strings.

**readoecd takes a different approach.** Rather than wrapping the raw API, it provides curated named functions for the most commonly needed OECD datasets. Users do not need to know anything about SDMX, dataset identifiers, or dimension codes — `get_oecd_unemployment(c("AUS", "GBR"), start_year = 2010)` just works. Output columns are consistent across all functions, and data is cached locally so repeated calls are instant.

## License

MIT
