# Get OECD productivity data

Downloads (and caches) labour productivity data for OECD member
countries from the OECD Productivity Database (PDB).

## Usage

``` r
get_oecd_productivity(countries = "all", start_year = 1990, refresh = FALSE)
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

  `"GDP_PER_HOUR"` or `"GDP_PER_CAPITA"` (character)

- value:

  Productivity value (numeric)

- unit:

  Unit of measurement (character)

## Details

Returns GDP per hour worked where available (in USD purchasing power
parities), falling back to GDP per capita. Values are at current prices.

## See also

Other productivity and trade:
[`get_oecd_current_account()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_current_account.md)

## Examples

``` r
# \donttest{
op <- options(readoecd.cache_dir = tempdir())
prod <- try(get_oecd_productivity(c("AUS", "GBR", "USA"), start_year = 2000))
#> Downloading from OECD API...
if (!inherits(prod, "try-error")) head(prod)
#>     country country_name year       series    value      unit
#> 73      AUS    Australia 2000 GDP_PER_HOUR 34.09458 USD_PPP_H
#> 74      AUS    Australia 2000 GDP_PER_HOUR 53.89475 USD_PPP_H
#> 75      AUS    Australia 2000 GDP_PER_HOUR 44.73481 USD_PPP_H
#> 220     AUS    Australia 2000 GDP_PER_HOUR 77.13215 USD_PPP_H
#> 76      AUS    Australia 2001 GDP_PER_HOUR 47.77077 USD_PPP_H
#> 77      AUS    Australia 2001 GDP_PER_HOUR 55.96281 USD_PPP_H
options(op)
# }
```
