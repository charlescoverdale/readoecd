# Get OECD tax revenue data

Downloads (and caches) total tax revenue as a share of GDP for OECD
member countries from the OECD Revenue Statistics Comparator database.

## Usage

``` r
get_oecd_tax(countries = "all", start_year = 1990, refresh = FALSE)
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

  `"TAX_REVENUE"` (character)

- value:

  Total tax revenue as a share of GDP (numeric)

- unit:

  `"% of GDP"` (character)

## See also

Other fiscal:
[`get_oecd_deficit()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_deficit.md)

## Examples

``` r
# \donttest{
op <- options(readoecd.cache_dir = tempdir())
tax <- try(get_oecd_tax(c("AUS", "GBR", "USA"), start_year = 2000))
#> Downloading from OECD API...
if (!inherits(tax, "try-error")) head(tax)
#>   country country_name year      series  value     unit
#> 1     AUS    Australia 2000 TAX_REVENUE 30.380 % of GDP
#> 2     AUS    Australia 2001 TAX_REVENUE 28.859 % of GDP
#> 3     AUS    Australia 2002 TAX_REVENUE 29.736 % of GDP
#> 4     AUS    Australia 2003 TAX_REVENUE 29.833 % of GDP
#> 5     AUS    Australia 2004 TAX_REVENUE 30.134 % of GDP
#> 6     AUS    Australia 2005 TAX_REVENUE 29.835 % of GDP
options(op)
# }
```
