# Get OECD GDP data

Downloads (and caches) annual gross domestic product (GDP) at current
prices for OECD member countries from the OECD National Accounts
database.

## Usage

``` r
get_oecd_gdp(countries = "all", start_year = 1990, refresh = FALSE)
```

## Arguments

- countries:

  Character vector of ISO 3166-1 alpha-3 country codes, or `"all"` for
  all 38 OECD members. Defaults to `"all"`. Run
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

  `"GDP"` (character)

- value:

  GDP value at current prices (numeric)

- unit:

  Unit of measurement (character)

## Details

GDP is measured using the expenditure approach (Table 1 of the OECD Main
National Accounts), valued at current prices in US dollars converted
using purchasing power parities (PPPs) where available.

## Examples

``` r
# \donttest{
gdp <- get_oecd_gdp(c("AUS", "GBR", "USA"), start_year = 2010)
#> Downloading from OECD API...

# Largest OECD economies
latest <- gdp[gdp$year == max(gdp$year), ]
head(latest[order(-latest$value), c("country_name", "value")], 10)
#>      country_name    value
#> 10  United States 29298013
#> 9  United Kingdom  4352408
#> 23      Australia  2033546
# }
```
