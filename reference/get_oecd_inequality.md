# Get OECD income inequality data

Downloads (and caches) the Gini coefficient of disposable income for
OECD member countries from the OECD Income Distribution Database (IDD).

## Usage

``` r
get_oecd_inequality(countries = "all", start_year = 1990, refresh = FALSE)
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

  `"GINI"` (character)

- value:

  Gini coefficient of disposable income (numeric)

- unit:

  `"Gini coefficient (0-1)"` (character)

## Details

The Gini coefficient measures income inequality on a scale from 0
(perfect equality) to 1 (maximum inequality). Disposable income is
household income after taxes and transfers. The series follows the OECD
METH2012 methodology where available for consistency across countries
and time.

## See also

Other social indicators:
[`get_oecd_education()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_education.md),
[`get_oecd_health()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_health.md)

## Examples

``` r
# \donttest{
op <- options(readoecd.cache_dir = tempdir())
gini <- try(get_oecd_inequality(c("AUS", "GBR", "USA", "DNK"), start_year = 2000))
#> Downloading from OECD API...
if (!inherits(gini, "try-error")) head(gini)
#>    country country_name year series  value                   unit
#> 40     AUS    Australia 2012   GINI 0.3260 Gini coefficient (0-1)
#> 41     AUS    Australia 2014   GINI 0.3370 Gini coefficient (0-1)
#> 42     AUS    Australia 2016   GINI 0.3300 Gini coefficient (0-1)
#> 43     AUS    Australia 2018   GINI 0.3250 Gini coefficient (0-1)
#> 39     AUS    Australia 2020   GINI 0.3190 Gini coefficient (0-1)
#> 2      DNK      Denmark 2011   GINI 0.2505 Gini coefficient (0-1)
options(op)
# }
```
