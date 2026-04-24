# Get OECD unemployment rates

Downloads (and caches) monthly harmonised unemployment rates for OECD
member countries from the OECD Labour Force Statistics database.

## Usage

``` r
get_oecd_unemployment(countries = "all", start_year = 2000, refresh = FALSE)
```

## Arguments

- countries:

  Character vector of ISO 3166-1 alpha-3 country codes, or `"all"` for
  all 38 OECD members. Defaults to `"all"`. Run
  [`list_oecd_countries()`](https://charlescoverdale.github.io/readoecd/reference/list_oecd_countries.md)
  to see available codes.

- start_year:

  Numeric. Earliest year to include. Defaults to `2000`.

- refresh:

  Logical. If `TRUE`, re-download even if a cached copy exists. Defaults
  to `FALSE`.

## Value

A data frame with columns:

- country:

  ISO 3166-1 alpha-3 country code (character)

- country_name:

  English country name (character)

- period:

  Calendar month in `"YYYY-MM"` format (character)

- series:

  `"Unemployment rate"` (character)

- value:

  Unemployment rate as a percentage of the labour force (numeric)

- unit:

  `"% of labour force"` (character)

## Details

Returns the seasonally adjusted unemployment rate as a percentage of the
labour force, for persons aged 15 and over (total, both sexes). This is
the standard harmonised series used for cross-country comparisons.

## See also

Other economic indicators:
[`get_oecd_cpi()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_cpi.md),
[`get_oecd_gdp()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_gdp.md)

## Examples

``` r
# \donttest{
op <- options(readoecd.cache_dir = tempdir())
# All OECD members since 2010
une <- try(get_oecd_unemployment(start_year = 2010))
#> Downloading from OECD API...

# Australia and UK since 2020
une <- try(get_oecd_unemployment(c("AUS", "GBR"), start_year = 2020))
#> Downloading from OECD API...

if (!inherits(une, "try-error")) {
  # Which country had the highest unemployment in 2020?
  une2020 <- une[startsWith(une$period, "2020"), ]
  une2020_avg <- aggregate(value ~ country_name, une2020, mean)
  head(une2020_avg[order(-une2020_avg$value), ], 5)
}
#>     country_name    value
#> 1      Australia 6.478989
#> 2 United Kingdom 4.600000
options(op)
# }
```
