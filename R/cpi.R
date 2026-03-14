# Consumer Price Index -- OECD Prices (COICOP 1999)
# Agency:   OECD.SDD.TPS
# Dataflow: DSD_PRICES@DF_PRICES_ALL v1.0
#
# Dimensions (8):
#   REF_AREA . FREQ . METHODOLOGY . MEASURE . UNIT_MEASURE .
#   EXPENDITURE . ADJUSTMENT . TRANSFORMATION
#
# Filter: FREQ=A, MEASURE=CPI, UNIT_MEASURE=PA (annual % change),
#         EXPENDITURE=_T (total), ADJUSTMENT=N, TRANSFORMATION=GY
# Returns the annual year-on-year CPI inflation rate.

OECD_CPI_DATAFLOW        <- "OECD.SDD.TPS,DSD_PRICES@DF_PRICES_ALL,1.0"
OECD_CPI_FILTER_TEMPLATE <- "COUNTRIES.A.N.CPI.PA._T.N.GY"

parse_cpi <- function(df) {
  if (nrow(df) == 0) return(empty_oecd_result())

  cname  <- oecd_country_name_col(df)
  result <- data.frame(
    country      = df[["REF_AREA"]],
    country_name = df[[cname]],
    year         = suppressWarnings(as.integer(df[["TIME_PERIOD"]])),
    series       = "CPI_INFLATION",
    value        = suppressWarnings(as.numeric(df[["OBS_VALUE"]])),
    unit         = "% change, year-on-year",
    stringsAsFactors = FALSE
  )
  result <- result[!is.na(result$value) & !is.na(result$year), ]
  result[order(result$country, result$year), ]
}

#' Get OECD CPI inflation data
#'
#' Downloads (and caches) annual consumer price inflation for OECD member
#' countries from the OECD Prices database (COICOP 1999 classification).
#'
#' Returns the year-on-year percentage change in the Consumer Price Index
#' (CPI) for total expenditure, not seasonally adjusted. This is the standard
#' harmonised measure of headline inflation used for cross-country comparisons.
#'
#' @param countries Character vector of ISO 3166-1 alpha-3 country codes, or
#'   `"all"` for all available OECD members. Defaults to `"all"`. Run
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
#'   \item{series}{`"CPI_INFLATION"` (character)}
#'   \item{value}{Annual CPI inflation rate (numeric)}
#'   \item{unit}{`"% change, year-on-year"` (character)}
#' }
#'
#' @examples
#' \donttest{
#' cpi <- get_oecd_cpi(c("AUS", "GBR", "USA"), start_year = 2000)
#' head(cpi)
#' }
#'
#' @family economic indicators
#' @export
get_oecd_cpi <- function(countries = "all", start_year = 1990,
                         refresh = FALSE) {
  countries <- validate_countries(countries)
  filter    <- build_filter(OECD_CPI_FILTER_TEMPLATE, countries)
  tag       <- if (is.null(countries)) "cpi_all" else
    paste0("cpi_", paste(sort(countries), collapse = "_"))
  raw    <- oecd_fetch(OECD_CPI_DATAFLOW, filter, tag, start_year, refresh)
  result <- parse_cpi(raw)
  result[result$year >= start_year, ]
}
