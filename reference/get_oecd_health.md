# Get OECD health expenditure data

Downloads (and caches) total current health expenditure as a share of
GDP for OECD member countries from the System of Health Accounts (SHA)
database.

## Usage

``` r
get_oecd_health(countries = "all", start_year = 1990, refresh = FALSE)
```

## Arguments

- countries:

  Character vector of ISO 3166-1 alpha-3 country codes, or `"all"` for
  all available OECD members. Defaults to `"all"`. Run
  [`list_oecd_countries()`](https://charlescoverdale.github.io/readoecd/reference/list_oecd_countries.md)
  to see available codes.

- start_year:

  Numeric. Earliest year to include. Defaults to `1990`.

- refresh:

  Logical. If `TRUE`, re-download even if a cached copy exists. Defaults
  to `FALSE`.

## Value

A data frame with columns:

- country:

  ISO 3166-1 alpha-3 country code (character)

- country_name:

  English country name (character)

- year:

  Calendar year (integer)

- series:

  `"HEALTH_EXPENDITURE"` (character)

- value:

  Total health expenditure as a share of GDP (numeric)

- unit:

  `"% of GDP"` (character)

## Details

Health expenditure covers all spending on health care goods and services
across all financing sources (government, compulsory insurance,
voluntary insurance, and out-of-pocket payments), measured as a
percentage of GDP at current prices.

## See also

Other social indicators:
[`get_oecd_education()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_education.md),
[`get_oecd_inequality()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_inequality.md)

## Examples

``` r
# \donttest{
op <- options(readoecd.cache_dir = tempdir())
health <- try(get_oecd_health(c("AUS", "GBR", "USA"), start_year = 2000))
#> Downloading from OECD API...
#> Error in value[[3L]](cond) : Failed to reach the OECD API.
#> ℹ Check your internet connection and try again.
#> ℹ If the problem persists, the OECD may have changed their API.
#> ℹ Check for a package update or report at
#>   <https://github.com/charlescoverdale/readoecd/issues>
if (!inherits(health, "try-error")) head(health)
options(op)
# }
```
