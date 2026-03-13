# List OECD member countries

Returns a data frame of the 38 OECD member countries with their ISO
3166-1 alpha-3 codes and English names. No network call is required.

## Usage

``` r
list_oecd_countries()
```

## Value

A data frame with columns:

- iso3:

  ISO 3166-1 alpha-3 country code (character)

- name:

  English country name (character)

## Examples

``` r
list_oecd_countries()
#>    iso3            name
#> 1   AUS       Australia
#> 2   AUT         Austria
#> 3   BEL         Belgium
#> 4   CAN          Canada
#> 5   CHL           Chile
#> 6   COL        Colombia
#> 7   CRI      Costa Rica
#> 8   CZE  Czech Republic
#> 9   DNK         Denmark
#> 10  EST         Estonia
#> 11  FIN         Finland
#> 12  FRA          France
#> 13  DEU         Germany
#> 14  GRC          Greece
#> 15  HUN         Hungary
#> 16  ISL         Iceland
#> 17  IRL         Ireland
#> 18  ISR          Israel
#> 19  ITA           Italy
#> 20  JPN           Japan
#> 21  KOR           Korea
#> 22  LVA          Latvia
#> 23  LTU       Lithuania
#> 24  LUX      Luxembourg
#> 25  MEX          Mexico
#> 26  NLD     Netherlands
#> 27  NZL     New Zealand
#> 28  NOR          Norway
#> 29  POL          Poland
#> 30  PRT        Portugal
#> 31  SVK Slovak Republic
#> 32  SVN        Slovenia
#> 33  ESP           Spain
#> 34  SWE          Sweden
#> 35  CHE     Switzerland
#> 36  TUR         Turkiye
#> 37  GBR  United Kingdom
#> 38  USA   United States
```
