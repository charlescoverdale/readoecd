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

## Examples

``` r
# \donttest{
trade <- get_oecd_current_account(c("AUS", "DEU", "USA"), start_year = 2000)
#> Downloading from OECD API...
#> Error in value[[3L]](cond): Failed to reach the OECD API.
#> ℹ Check your internet connection and try again.
#> ℹ If the problem persists, the OECD may have changed their API.
#> ℹ Check for a package update or report at
#>   <https://github.com/charlescoverdale/readoecd/issues>
head(trade)
#> Error: object 'trade' not found
# }
```
