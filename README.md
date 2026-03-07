# readoecd

**readoecd** provides clean, tidy access to OECD economic data directly from R.

## Background: the existing OECD package

There is an existing R package called [OECD](https://cran.r-project.org/package=OECD), written by Eric Persson and first published on CRAN in 2016. It is a generic API wrapper — rather than providing named functions for specific datasets, it exposes the raw OECD SDMX API directly. The typical workflow requires the user to first browse available datasets with `search_dataset()`, then retrieve dimension codes with `get_data_structure()`, then construct a filter string manually before finally calling `get_dataset()`. This gives maximum flexibility but places the burden of knowing the OECD's dataset catalogue and dimension codes entirely on the user.

**The CRAN version (v0.2.5, released December 2021) is currently broken.** In July 2024, the OECD migrated their API from the old endpoint (`stats.oecd.org`) to a new SDMX 3.0 REST API (`sdmx.oecd.org`). The CRAN version still points at the old endpoint, which no longer returns data. Despite being broken, the package still attracts around 700–1,400 downloads per month — reflecting how many analysts depend on OECD data in R and have no working alternative.

**Eric's GitHub version is partially updated** ([expersso/OECD](https://github.com/expersso/OECD)). He updated the package in August 2025 to target the new API, but this version has not been submitted to CRAN and is not widely known. It remains a generic wrapper: it still requires users to know dataset IDs and construct their own filter strings.

**readoecd takes a different approach.** Rather than wrapping the raw API, it provides curated named functions for the most commonly needed OECD datasets. Users do not need to know anything about SDMX, dataset identifiers, or dimension codes — `get_oecd_gdp(c("AUS", "GBR"), start_year = 2010)` just works. Output columns are consistent across all functions, and data is cached locally so repeated calls are instant.

## Installation

```r
# Install from GitHub (CRAN submission in progress)
# install.packages("remotes")
remotes::install_github("charlescoverdale/readoecd")
```

## Usage

```r
library(readoecd)
```

### GDP

```r
# Largest OECD economies in the most recent year
gdp <- get_oecd_gdp("all", start_year = 2015)
latest <- gdp[gdp$year == max(gdp$year), ]
head(latest[order(-latest$value), c("country_name", "year", "value")], 10)
#>         country_name year    value
#>    United States     2023 27357916
#>            Japan     2023  4212945
#>          Germany     2023  4457178
#>   United Kingdom     2023  3081866
#>           France     2023  2923489

# GDP growth for G7 countries
g7 <- get_oecd_gdp(c("CAN", "FRA", "DEU", "ITA", "JPN", "GBR", "USA"),
                   start_year = 2000)
```

### Unemployment

```r
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

### Tax revenue

```r
# Tax burden comparison: Nordics vs Anglo-Saxon economies
tax <- get_oecd_tax(c("DNK", "SWE", "NOR", "AUS", "GBR", "USA"),
                    start_year = 2010)

# Latest reading for each country
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

### Health expenditure

```r
# Which OECD country spends the most on health?
health <- get_oecd_health("all", start_year = 2015)
latest_hlth <- health[health$year == max(health$year), ]
head(latest_hlth[order(-latest_hlth$value), c("country_name", "year", "value")], 5)
#>    country_name year value
#>   United States 2022  16.6
#>         Germany 2022  12.7
#>     Switzerland 2022  11.3
#>          France 2022  11.9
#>       Australia 2022   9.7
```

### Education expenditure

```r
# Education spending trends for selected countries
edu <- get_oecd_education(c("AUS", "GBR", "USA", "KOR", "FIN"),
                          start_year = 2005)
```

### Productivity

```r
# Productivity gap between frontier and laggard OECD economies
prod <- get_oecd_productivity("all", start_year = 2010)
latest_prod <- prod[prod$year == max(prod$year), ]
head(latest_prod[order(-latest_prod$value), c("country_name", "year", "value")], 5)
```

### Trade (current account)

```r
# Persistent surplus and deficit countries
trade <- get_oecd_current_account("all", start_year = 2010)
latest_trade <- trade[trade$year == max(trade$year), ]

# Largest surpluses
head(latest_trade[order(-latest_trade$value), c("country_name", "year", "value")], 5)

# Largest deficits
head(latest_trade[order(latest_trade$value), c("country_name", "year", "value")], 5)
```

### Utilities

```r
# See all available country codes
list_oecd_countries()

# Clear the local cache to force fresh downloads
clear_oecd_cache()
```

## Datasets

### `get_oecd_gdp()` — Gross Domestic Product

Source: **OECD National Accounts** (Main Aggregates, Table 1). Annual GDP measured using the expenditure approach at current prices, in millions of US dollars at exchange rates. Coverage is broad — most OECD members have data from the 1990s, some earlier. GDP in USD PPP is used for cross-country comparisons where available; the package falls back to exchange-rate USD if PPP is not published for a given country-year.

### `get_oecd_unemployment()` — Unemployment Rate

Source: **OECD Labour Force Statistics** (Harmonised Unemployment Rates). Monthly seasonally-adjusted unemployment rate as a percentage of the labour force, for persons aged 15 and over. The harmonised series adjusts for differences in national survey methodologies, making it the standard series for cross-country comparisons. Coverage varies by country but generally starts from the 1980s–1990s.

### `get_oecd_tax()` — Tax Revenue

Source: **OECD Revenue Statistics Comparator**. Total tax revenue as a percentage of GDP, covering all levels of government (central, state, and local) and all tax types (income, payroll, property, goods and services, and other taxes). The standard measure of overall tax burden used in cross-country fiscal analysis. Annual data; most countries covered from the early 1990s.

### `get_oecd_health()` — Health Expenditure

Source: **System of Health Accounts (SHA)**. Total current health expenditure as a percentage of GDP, covering all financing sources — government schemes, compulsory health insurance, voluntary health insurance, and out-of-pocket payments. Based on the internationally standardised SHA 2011 framework developed jointly by the OECD, WHO, and Eurostat. Annual data; coverage typically from 2000 onwards.

### `get_oecd_education()` — Education Expenditure

Source: **Education at a Glance (EAG) — UOE Finance indicators**. Total expenditure on educational institutions as a percentage of GDP, aggregated across all levels of education (ISCED 0–8, from early childhood through tertiary). Covers both public and private expenditure. Published annually; data typically available with a two-year lag, covering most OECD members from the mid-2000s.

### `get_oecd_productivity()` — Labour Productivity

Source: **OECD Productivity Database (PDB)**. GDP per hour worked in USD PPP where available, falling back to GDP per capita. GDP per hour worked is the standard measure of labour productivity used for cross-country comparisons, as it adjusts for differences in average working hours across countries. Annual data; coverage varies by country.

### `get_oecd_current_account()` — Current Account Balance

Source: **OECD Balance of Payments Statistics**. Annual current account balance with the rest of the world, in millions of US dollars at current exchange rates. A positive value indicates a surplus (exports exceeding imports of goods, services, income, and transfers); a negative value indicates a deficit. Coverage is annual; most countries available from the 1990s.

## Utility functions

| Function | Description |
|---|---|
| `list_oecd_countries()` | List all 38 OECD member country codes and names |
| `check_oecd_api()` | Test connectivity to the OECD API |
| `clear_oecd_cache()` | Delete all locally cached data files |

## Output

All `get_oecd_*()` functions return a tidy long-format data frame with consistent columns:

| Column | Type | Description |
|---|---|---|
| `country` | character | ISO 3166-1 alpha-3 code (e.g. `"AUS"`) |
| `country_name` | character | English country name |
| `year` | integer | Calendar year (annual datasets) |
| `period` | character | `"YYYY-MM"` for monthly datasets |
| `series` | character | Series label (e.g. `"GDP"`, `"TAX_REVENUE"`) |
| `value` | numeric | Observation value |
| `unit` | character | Unit of measurement |

## Caching

Downloaded data is stored in your user cache directory (`tools::R_user_dir("readoecd", "cache")`). Subsequent calls return the cached copy instantly. Use `refresh = TRUE` to force a re-download, or `clear_oecd_cache()` to wipe all cached files.

## API stability

readoecd uses the OECD Data Explorer REST API (`sdmx.oecd.org`). The OECD periodically migrates dataset identifiers — if a function stops working, check for a package update or [file an issue](https://github.com/charlescoverdale/readoecd/issues).

## License

MIT
