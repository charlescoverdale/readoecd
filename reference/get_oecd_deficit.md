# Get OECD government deficit data

Downloads (and caches) general government net lending/borrowing as a
share of GDP for OECD member countries from the OECD National Accounts
(NAAG) database.

## Usage

``` r
get_oecd_deficit(countries = "all", start_year = 1990, refresh = FALSE)
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

  `"GOVT_NET_LENDING"` (character)

- value:

  Net lending/borrowing as a share of GDP (numeric). Positive = surplus;
  negative = deficit.

- unit:

  `"% of GDP"` (character)

## Details

Net lending/borrowing is the difference between government revenue and
expenditure, expressed as a percentage of GDP. A positive value
indicates a surplus (government saving); a negative value indicates a
deficit (government borrowing). This is the standard fiscal balance
measure used for cross-country comparisons and is consistent with the
System of National Accounts (SNA) definition.

## See also

Other fiscal:
[`get_oecd_tax()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_tax.md)

## Examples

``` r
# \donttest{
op <- options(readoecd.cache_dir = tempdir())
deficit <- try(get_oecd_deficit(c("AUS", "GBR", "USA"), start_year = 2000))
#> Downloading from OECD API...
if (!inherits(deficit, "try-error")) head(deficit)
#>    country country_name year           series      value     unit
#> 75     AUS    Australia 2000 GOVT_NET_LENDING -1.3381041 % of GDP
#> 25     AUS    Australia 2001 GOVT_NET_LENDING -0.7788197 % of GDP
#> 4      AUS    Australia 2002 GOVT_NET_LENDING  0.6761192 % of GDP
#> 69     AUS    Australia 2003 GOVT_NET_LENDING  0.7640926 % of GDP
#> 1      AUS    Australia 2004 GOVT_NET_LENDING  0.8962921 % of GDP
#> 27     AUS    Australia 2005 GOVT_NET_LENDING  1.5711434 % of GDP
options(op)
# }
```
