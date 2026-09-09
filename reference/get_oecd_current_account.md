# Get OECD trade (balance of payments) data

Downloads (and caches) annual current account balance data for OECD
member countries from the OECD Balance of Payments (BOP) database.

## Usage

``` r
get_oecd_current_account(countries = "all", start_year = 1990, refresh = FALSE)
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

  `"CURRENT_ACCOUNT"` or `"CURRENT_ACCOUNT_GOODS_SERVICES"` (character)

- value:

  Current account balance in millions USD (numeric)

- unit:

  `"Millions USD (exchange rate)"` (character)

## Details

Returns the current account balance (credits minus debits) with the rest
of the world, in millions of US dollars at current exchange rates. A
positive value indicates a current account surplus; a negative value
indicates a deficit.

## See also

Other productivity and trade:
[`get_oecd_productivity()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_productivity.md)

## Examples

``` r
# \donttest{
op <- options(readoecd.cache_dir = tempdir())
trade <- try(get_oecd_current_account(c("AUS", "DEU", "USA"), start_year = 2000))
#> Downloading from OECD API...
if (!inherits(trade, "try-error")) head(trade)
#>    country country_name year          series      value
#> 52     AUS    Australia 2000 CURRENT_ACCOUNT -16028.220
#> 53     AUS    Australia 2001 CURRENT_ACCOUNT  -8639.672
#> 54     AUS    Australia 2002 CURRENT_ACCOUNT -16207.060
#> 55     AUS    Australia 2003 CURRENT_ACCOUNT -28784.950
#> 56     AUS    Australia 2004 CURRENT_ACCOUNT -41381.860
#> 57     AUS    Australia 2005 CURRENT_ACCOUNT -43573.640
#>                            unit
#> 52 Millions USD (exchange rate)
#> 53 Millions USD (exchange rate)
#> 54 Millions USD (exchange rate)
#> 55 Millions USD (exchange rate)
#> 56 Millions USD (exchange rate)
#> 57 Millions USD (exchange rate)
options(op)
# }
```
