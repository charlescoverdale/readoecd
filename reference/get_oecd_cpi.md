# Get OECD CPI inflation data

Downloads (and caches) annual consumer price inflation for OECD member
countries from the OECD Prices database (COICOP 1999 classification).

## Usage

``` r
get_oecd_cpi(countries = "all", start_year = 1990, refresh = FALSE)
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

  `"CPI_INFLATION"` (character)

- value:

  Annual CPI inflation rate (numeric)

- unit:

  `"% change, year-on-year"` (character)

## Details

Returns the year-on-year percentage change in the Consumer Price Index
(CPI) for total expenditure, not seasonally adjusted. This is the
standard harmonised measure of headline inflation used for cross-country
comparisons.

## Examples

``` r
# \donttest{
cpi <- get_oecd_cpi(c("AUS", "GBR", "USA"), start_year = 2000)
#> Downloading from OECD API...
head(cpi)
#>    country country_name year        series    value                   unit
#> 77     AUS    Australia 2000 CPI_INFLATION 4.457435 % change, year-on-year
#> 76     AUS    Australia 2001 CPI_INFLATION 4.407135 % change, year-on-year
#> 75     AUS    Australia 2002 CPI_INFLATION 2.981575 % change, year-on-year
#> 74     AUS    Australia 2003 CPI_INFLATION 2.732596 % change, year-on-year
#> 73     AUS    Australia 2004 CPI_INFLATION 2.343255 % change, year-on-year
#> 72     AUS    Australia 2005 CPI_INFLATION 2.691832 % change, year-on-year
# }
```
