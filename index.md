# readoecd

[![CRAN
status](https://www.r-pkg.org/badges/version/readoecd)](https://CRAN.R-project.org/package=readoecd)
[![R-CMD-check](https://github.com/charlescoverdale/readoecd/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/charlescoverdale/readoecd/actions/workflows/R-CMD-check.yaml)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/readoecd)](https://cran.r-project.org/package=readoecd)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![License:
MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

**readoecd** provides clean, tidy access to OECD economic data directly
from R.

## Background: the existing OECD package

There is an existing R package called
[OECD](https://cran.r-project.org/package=OECD), written by Eric Persson
and first published on CRAN in 2016. It is a generic API wrapper -
rather than providing named functions for specific datasets, it exposes
the raw OECD SDMX API directly. The typical workflow requires the user
to first browse available datasets with `search_dataset()`, then
retrieve dimension codes with `get_data_structure()`, then construct a
filter string manually before finally calling `get_dataset()`. This
gives maximum flexibility but places the burden of knowing the OECD’s
dataset catalogue and dimension codes entirely on the user.

**The CRAN version (v0.2.5, released December 2021) is currently
broken.** In July 2024, the OECD migrated their API from the old
endpoint (`stats.oecd.org`) to a new SDMX 3.0 REST API
(`sdmx.oecd.org`). The CRAN version still points at the old endpoint,
which no longer returns data. Despite being broken, the package still
attracts around 700–1,400 downloads per month - reflecting how many
analysts depend on OECD data in R and have no working alternative.

**Eric’s GitHub version is partially updated**
([expersso/OECD](https://github.com/expersso/OECD)). He updated the
package in August 2025 to target the new API, but this version has not
been submitted to CRAN and is not widely known. It remains a generic
wrapper: it still requires users to know dataset IDs and construct their
own filter strings.

**readoecd takes a different approach.** Rather than wrapping the raw
API, it provides curated named functions for the most commonly needed
OECD datasets. Users do not need to know anything about SDMX, dataset
identifiers, or dimension codes -
`get_oecd_gdp(c("AUS", "GBR"), start_year = 2010)` just works. Output
columns are consistent across all functions, and data is cached locally
so repeated calls are instant.

## Installation

``` r
install.packages("readoecd")

# Or install the development version from GitHub
# install.packages("devtools")
devtools::install_github("charlescoverdale/readoecd")
```

## Looking for a specific dataset or variable treatment?

Each function in readoecd returns a single, opinionated series - for
example,
[`get_oecd_cpi()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_cpi.md)
returns the annual headline inflation rate, and
[`get_oecd_health()`](https://charlescoverdale.github.io/readoecd/reference/get_oecd_health.md)
returns total health expenditure as a share of GDP. If you need a
different cut of the data, the best starting point is the [OECD Data
Explorer](https://data-explorer.oecd.org), which lets you browse and
filter any OECD dataset interactively.

Examples of things you might want that go beyond what readoecd currently
provides:

- **CPI by expenditure category** (food, housing, transport) rather than
  the headline total
- **Health expenditure by financing source** (government-only vs
  out-of-pocket) rather than the all-sources aggregate
- **GDP in constant prices** (volume, real growth) rather than current
  prices
- **Tax revenue by tax type** (income tax, VAT, corporate tax) rather
  than the total
- **Unemployment by age group or sex** rather than the all-persons total
- **Trade in goods and services separately** rather than the combined
  current account

## Datasets available in this package

``` r
library(readoecd)
```

### `get_oecd_gdp()` - Gross Domestic Product

Source: **OECD National Accounts** (Main Aggregates, Table 1). Annual
GDP measured using the expenditure approach at current prices, in
millions of US dollars at exchange rates. Coverage is broad - most OECD
members have data from the 1990s, some earlier. GDP in USD PPP is used
for cross-country comparisons where available; the package falls back to
exchange-rate USD if PPP is not published for a given country-year.

``` r
# Largest OECD economies in the most recent year
gdp <- get_oecd_gdp("all", start_year = 2015)
latest <- gdp[gdp$year == max(gdp$year), ]
head(latest[order(-latest$value), c("country_name", "year", "value")], 5)
#>        country_name year    value
#>   United States     2023 27357916
#>         Germany     2023  4457178
#>           Japan     2023  4212945
#>  United Kingdom     2023  3081866
#>          France     2023  2923489

# G7 comparison since 2000
g7 <- get_oecd_gdp(c("CAN", "FRA", "DEU", "ITA", "JPN", "GBR", "USA"),
                   start_year = 2000)
```

### `get_oecd_cpi()` - CPI Inflation

Source: **OECD Prices database** (COICOP 1999 classification). Annual
year-on-year percentage change in the Consumer Price Index for total
household expenditure, not seasonally adjusted. This is the standard
harmonised measure of headline inflation used for cross-country
comparisons. Coverage varies by country but is generally available from
the 1970s–1980s onwards.

``` r
# Inflation through the post-COVID price surge
cpi <- get_oecd_cpi(c("AUS", "GBR", "USA", "DEU"), start_year = 2018)
cpi[cpi$year == 2022, c("country_name", "year", "value")]
#>    country_name year value
#>       Australia 2022   6.6
#>         Germany 2022   8.7
#>  United Kingdom 2022   9.1
#>   United States 2022   8.0
```

### `get_oecd_unemployment()` - Unemployment Rate

Source: **OECD Labour Force Statistics** (Harmonised Unemployment
Rates). Monthly seasonally-adjusted unemployment rate as a percentage of
the labour force, for persons aged 15 and over. The harmonised series
adjusts for differences in national survey methodologies, making it the
standard series for cross-country comparisons. Coverage varies by
country but generally starts from the 1980s–1990s.

``` r
# Track unemployment through the COVID shock
unemp <- get_oecd_unemployment(c("AUS", "GBR", "USA"), start_year = 2018)

# Peak unemployment by country during 2020
peak_2020 <- unemp[substr(unemp$period, 1, 4) == "2020", ]
aggregate(value ~ country_name, data = peak_2020, FUN = max)
#>    country_name value
#>       Australia  7.47
#>  United Kingdom  5.10
#>   United States 14.70
```

### `get_oecd_tax()` - Tax Revenue

Source: **OECD Revenue Statistics Comparator**. Total tax revenue as a
percentage of GDP, covering all levels of government (central, state,
and local) and all tax types (income, payroll, property, goods and
services, and other taxes). The standard measure of overall tax burden
used in cross-country fiscal analysis. Annual data; most countries
covered from the early 1990s.

``` r
# Tax burden: Nordics vs Anglo-Saxon economies
tax <- get_oecd_tax(c("DNK", "SWE", "NOR", "AUS", "GBR", "USA"),
                    start_year = 2010)

latest_tax <- tax[tax$year == max(tax$year), c("country_name", "year", "value")]
latest_tax[order(-latest_tax$value), ]
#>    country_name year value
#>         Denmark 2022  46.0
#>          Sweden 2022  42.6
#>          Norway 2022  42.2
#>  United Kingdom 2022  35.3
#>       Australia 2022  29.5
#>   United States 2022  27.7
```

### `get_oecd_deficit()` - Government Deficit

Source: **OECD National Accounts** (General Government Accounts, NAAG).
General government net lending/borrowing as a percentage of GDP,
consistent with the System of National Accounts (SNA) definition. A
positive value indicates a surplus; a negative value indicates a
deficit. Annual data; most OECD members covered from the 1990s.

``` r
# Fiscal positions during and after the pandemic
deficit <- get_oecd_deficit(c("AUS", "GBR", "USA", "DEU"), start_year = 2018)
deficit[deficit$year %in% 2019:2022, c("country_name", "year", "value")]
#>    country_name year  value
#>       Australia 2019  0.02
#>       Australia 2020 -4.45
#>       Australia 2021 -4.97
#>       Australia 2022 -1.70
```

### `get_oecd_health()` - Health Expenditure

Source: **System of Health Accounts (SHA)**. Total current health
expenditure as a percentage of GDP, covering all financing sources -
government schemes, compulsory health insurance, voluntary health
insurance, and out-of-pocket payments. Based on the internationally
standardised SHA 2011 framework developed jointly by the OECD, WHO, and
Eurostat. Annual data; coverage typically from 2000 onwards.

``` r
# Which OECD country spends the most on health?
health <- get_oecd_health("all", start_year = 2015)
latest_hlth <- health[health$year == max(health$year), ]
head(latest_hlth[order(-latest_hlth$value), c("country_name", "year", "value")], 5)
#>    country_name year value
#>   United States 2022  16.6
#>         Germany 2022  12.7
#>          France 2022  11.9
#>     Switzerland 2022  11.3
#>       Australia 2022   9.7
```

### `get_oecd_education()` - Education Expenditure

Source: **Education at a Glance (EAG) - UOE Finance indicators**. Total
expenditure on educational institutions as a percentage of GDP,
aggregated across all levels of education (ISCED 0–8, from early
childhood through tertiary). Covers both public and private expenditure.
Published annually; data typically available with a two-year lag,
covering most OECD members from the mid-2000s.

``` r
# Education spending trends across selected countries
edu <- get_oecd_education(c("AUS", "GBR", "USA", "KOR", "FIN"),
                          start_year = 2005)

latest_edu <- edu[edu$year == max(edu$year), c("country_name", "year", "value")]
latest_edu[order(-latest_edu$value), ]
```

### `get_oecd_inequality()` - Income Inequality

Source: **OECD Income Distribution Database (IDD)**. Gini coefficient of
disposable household income (after taxes and transfers), on a scale from
0 (perfect equality) to 1 (maximum inequality). Follows the OECD
METH2012 methodology for comparability across countries and over time.
Annual data; coverage varies by country, typically from the mid-1990s.

``` r
# Income inequality: how do OECD countries compare?
gini <- get_oecd_inequality("all", start_year = 2010)
latest_gini <- gini[gini$year == max(gini$year), ]

# Most and least equal OECD economies
head(latest_gini[order(latest_gini$value), c("country_name", "year", "value")], 5)
head(latest_gini[order(-latest_gini$value), c("country_name", "year", "value")], 5)
```

### `get_oecd_productivity()` - Labour Productivity

Source: **OECD Productivity Database (PDB)**. GDP per hour worked in USD
PPP where available, falling back to GDP per capita. GDP per hour worked
is the standard measure of labour productivity used for cross-country
comparisons, as it adjusts for differences in average working hours
across countries. Annual data; coverage varies by country.

``` r
# Productivity rankings across all OECD members
prod <- get_oecd_productivity("all", start_year = 2010)
latest_prod <- prod[prod$year == max(prod$year), ]
head(latest_prod[order(-latest_prod$value), c("country_name", "year", "value")], 5)
```

### `get_oecd_current_account()` - Current Account Balance

Source: **OECD Balance of Payments Statistics**. Annual current account
balance with the rest of the world, in millions of US dollars at current
exchange rates. A positive value indicates a surplus (exports exceeding
imports of goods, services, income, and transfers); a negative value
indicates a deficit. Coverage is annual; most countries available from
the 1990s.

``` r
# Identify persistent surplus and deficit countries
ca <- get_oecd_current_account("all", start_year = 2010)
latest_ca <- ca[ca$year == max(ca$year), ]

# Largest surpluses
head(latest_ca[order(-latest_ca$value), c("country_name", "year", "value")], 5)

# Largest deficits
head(latest_ca[order(latest_ca$value), c("country_name", "year", "value")], 5)
```

## Utility functions

| Function                                                                                                | Description                                     |
|---------------------------------------------------------------------------------------------------------|-------------------------------------------------|
| [`list_oecd_countries()`](https://charlescoverdale.github.io/readoecd/reference/list_oecd_countries.md) | List all 38 OECD member country codes and names |
| [`check_oecd_api()`](https://charlescoverdale.github.io/readoecd/reference/check_oecd_api.md)           | Test connectivity to the OECD API               |
| [`clear_oecd_cache()`](https://charlescoverdale.github.io/readoecd/reference/clear_oecd_cache.md)       | Delete all locally cached data files            |

``` r
# See all available country codes
list_oecd_countries()

# Clear the local cache to force fresh downloads
clear_oecd_cache()
```

## Output

All `get_oecd_*()` functions return a tidy long-format data frame with
consistent columns:

| Column         | Type      | Description                                    |
|----------------|-----------|------------------------------------------------|
| `country`      | character | ISO 3166-1 alpha-3 code (e.g. `"AUS"`)         |
| `country_name` | character | English country name                           |
| `year`         | integer   | Calendar year (annual datasets)                |
| `period`       | character | `"YYYY-MM"` for monthly datasets               |
| `series`       | character | Series label (e.g. `"GDP"`, `"CPI_INFLATION"`) |
| `value`        | numeric   | Observation value                              |
| `unit`         | character | Unit of measurement                            |

## Caching

Downloaded data is stored in your user cache directory
(`tools::R_user_dir("readoecd", "cache")`). Subsequent calls return the
cached copy instantly. Use `refresh = TRUE` to force a re-download, or
[`clear_oecd_cache()`](https://charlescoverdale.github.io/readoecd/reference/clear_oecd_cache.md)
to wipe all cached files.

## API stability

readoecd uses the OECD Data Explorer REST API (`sdmx.oecd.org`). The
OECD periodically migrates dataset identifiers - if a function stops
working, check for a package update or [file an
issue](https://github.com/charlescoverdale/readoecd/issues).

## Related packages

The **readoecd** package is part of a suite of R packages for economic
and financial data:

| Package                                                    | What it covers                                                                       |
|------------------------------------------------------------|--------------------------------------------------------------------------------------|
| [`ons`](https://github.com/charlescoverdale/ons)           | ONS data (GDP, inflation, unemployment, wages, trade, house prices, population)      |
| [`boe`](https://github.com/charlescoverdale/boe)           | Bank of England data (Bank Rate, SONIA, gilt yields, exchange rates, mortgage rates) |
| [`hmrc`](https://github.com/charlescoverdale/hmrc)         | HMRC tax receipts, corporation tax, stamp duty, R&D credits, and tax gap data        |
| [`obr`](https://github.com/charlescoverdale/obr)           | OBR fiscal forecasts and the Public Finances Databank                                |
| [`readecb`](https://github.com/charlescoverdale/readecb)   | European Central Bank data (policy rates, HICP, exchange rates, yield curves)        |
| [`fred`](https://github.com/charlescoverdale/fred)         | US Federal Reserve (FRED) data (800,000+ economic time series)                       |
| [`inflateR`](https://github.com/charlescoverdale/inflateR) | Adjust values for inflation using CPI or GDP deflator data                           |

## Keywords

OECD, SDMX, international economic data, GDP, unemployment, trade,
education, health, environment, OECD Data Explorer, open data,
cross-country comparison, R package

## License

MIT
