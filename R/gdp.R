# OECD National Accounts -- annual GDP
# Agency:   OECD.SDD.NAD
# Dataflow: DSD_NAMAIN10@DF_TABLE1 v2.0 (Main national accounts -- Table 1)
# API ref:  https://data-explorer.oecd.org (search "GDP")
#
# Dimensions (12):
#   FREQ . REF_AREA . SECTOR . COUNTERPART_SECTOR . TRANSACTION .
#   INSTR_ASSET . ACTIVITY . EXPENDITURE . UNIT_MEASURE . PRICE_BASE .
#   TRANSFORMATION . TABLE_IDENTIFIER
#
# Filter: A=annual, TRANSACTION=B1GQ (GDP), PRICE_BASE=V (current prices)
# UNIT_MEASURE left open -- API returns multiple currencies; parse_gdp()
# selects USD_PPP for cross-country comparability.

OECD_GDP_DATAFLOW        <- "OECD.SDD.NAD,DSD_NAMAIN10@DF_TABLE1,2.0"
OECD_GDP_FILTER_TEMPLATE <- "A.COUNTRIES...B1GQ.....V.."

parse_gdp <- function(df) {
  # Prefer USD PPP for cross-country comparability; fall back to whatever is present
  ppp_codes <- c("USD_PPP", "MNDUSD_PPP", "PC_GDP")
  if ("UNIT_MEASURE" %in% names(df)) {
    avail <- unique(df[["UNIT_MEASURE"]])
    keep  <- intersect(ppp_codes, avail)
    if (length(keep) > 0) {
      df <- df[df[["UNIT_MEASURE"]] %in% keep[1], ]
      unit_label <- paste0("Millions ", keep[1], ", current prices")
    } else {
      unit_label <- "Current prices"
    }
  } else {
    unit_label <- "Current prices"
  }

  result <- data.frame(
    country      = df[["REF_AREA"]],
    country_name = df[["Reference.area"]],
    year         = suppressWarnings(as.integer(df[["TIME_PERIOD"]])),
    series       = "GDP",
    value        = suppressWarnings(as.numeric(df[["OBS_VALUE"]])),
    unit         = unit_label,
    stringsAsFactors = FALSE
  )
  result <- result[!is.na(result$value) & !is.na(result$year), ]
  result[order(result$country, result$year), ]
}

#' Get OECD GDP data
#'
#' Downloads (and caches) annual gross domestic product (GDP) at current
#' prices for OECD member countries from the OECD National Accounts database.
#'
#' GDP is measured using the expenditure approach (Table 1 of the OECD Main
#' National Accounts), valued at current prices in US dollars converted using
#' purchasing power parities (PPPs) where available.
#'
#' @param countries Character vector of ISO 3166-1 alpha-3 country codes, or
#'   `"all"` for all 38 OECD members. Defaults to `"all"`. Run
#'   [list_oecd_countries()] to see available codes.
#' @param start_year Numeric. Earliest year to include. Defaults to `1990`.
#' @param refresh Logical. If `TRUE`, re-download even if a cached copy
#'   exists. Defaults to `FALSE`.
#'
#' @return A data frame with columns:
#' \describe{
#'   \item{country}{ISO 3166-1 alpha-3 country code (character)}
#'   \item{country_name}{English country name (character)}
#'   \item{year}{Calendar year (integer)}
#'   \item{series}{`"GDP"` (character)}
#'   \item{value}{GDP value at current prices (numeric)}
#'   \item{unit}{Unit of measurement (character)}
#' }
#'
#' @examples
#' \donttest{
#' gdp <- get_oecd_gdp(c("AUS", "GBR", "USA"), start_year = 2010)
#'
#' # Largest OECD economies
#' latest <- gdp[gdp$year == max(gdp$year), ]
#' head(latest[order(-latest$value), c("country_name", "value")], 10)
#' }
#'
#' @export
get_oecd_gdp <- function(countries = "all", start_year = 1990,
                          refresh = FALSE) {
  countries <- validate_countries(countries)
  filter    <- build_filter(OECD_GDP_FILTER_TEMPLATE, countries)
  tag       <- if (identical(countries, NULL)) "gdp_all" else
    paste0("gdp_", paste(sort(countries), collapse = "_"))
  raw    <- oecd_fetch(OECD_GDP_DATAFLOW, filter, tag, start_year, refresh)
  result <- parse_gdp(raw)
  result[result$year >= start_year, ]
}
