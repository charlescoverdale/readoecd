# Get OECD education expenditure data

Downloads (and caches) total education expenditure as a share of GDP for
OECD member countries from the OECD Education at a Glance (EAG) UOE
Finance database.

## Usage

``` r
get_oecd_education(countries = "all", start_year = 1990, refresh = FALSE)
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

  `"EDU_EXPENDITURE"` (character)

- value:

  Total education expenditure as a share of GDP (numeric)

- unit:

  `"% of GDP"` (character)

## Details

Education expenditure covers spending on educational institutions across
all levels of education (ISCED 0–8), from all public and private
sources, expressed as a percentage of GDP.

## Examples

``` r
# \donttest{
edu <- get_oecd_education(c("AUS", "GBR", "USA"), start_year = 2000)
#> Downloading from OECD API...
head(edu)
#>     country country_name year          series     value     unit
#> 76      AUS    Australia 2000 EDU_EXPENDITURE 0.0544171 % of GDP
#> 91      AUS    Australia 2000 EDU_EXPENDITURE 0.0898196 % of GDP
#> 226     AUS    Australia 2000 EDU_EXPENDITURE 0.0354025 % of GDP
#> 646     AUS    Australia 2000 EDU_EXPENDITURE 3.7549170 % of GDP
#> 676     AUS    Australia 2000 EDU_EXPENDITURE 1.6030780 % of GDP
#> 706     AUS    Australia 2000 EDU_EXPENDITURE 0.4119364 % of GDP
# }
```
