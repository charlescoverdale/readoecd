# Health Expenditure -- System of Health Accounts (SHA)
# Agency:   OECD.ELS.HD
# Dataflow: DSD_SHA@DF_SHA v1.0
#
# Dimensions (12):
#   REF_AREA . FREQ . MEASURE . UNIT_MEASURE . FINANCING_SCHEME .
#   FINANCING_SCHEME_REV . FUNCTION . MODE_PROVISION . PROVIDER .
#   FACTOR_PROVISION . ASSET_TYPE . PRICE_BASE
#
# Filter: MEASURE=EXP_HEALTH, UNIT_MEASURE=PT_GDP, FREQ=A
# Remaining dimensions left open; parse_health() retains
# total expenditure (FINANCING_SCHEME=_T, FUNCTION=HC, PROVIDER=_T).

OECD_HEALTH_DATAFLOW        <- "OECD.ELS.HD,DSD_SHA@DF_SHA,1.0"
OECD_HEALTH_FILTER_TEMPLATE <- "COUNTRIES.A.EXP_HEALTH.PT_GDP........"

parse_health <- function(df) {
  if (nrow(df) == 0) return(empty_oecd_result())

  # Total health expenditure: all financing sources, total function, all providers
  if ("FINANCING_SCHEME" %in% names(df))
    df <- df[df[["FINANCING_SCHEME"]] == "_T", ]
  if ("FUNCTION" %in% names(df))
    df <- df[df[["FUNCTION"]] %in% c("HC", "_T"), ]
  if ("PROVIDER" %in% names(df))
    df <- df[df[["PROVIDER"]] %in% c("_T", "_Z"), ]

  if (nrow(df) == 0) return(empty_oecd_result())

  cname  <- oecd_country_name_col(df)
  result <- data.frame(
    country      = df[["REF_AREA"]],
    country_name = df[[cname]],
    year         = suppressWarnings(as.integer(df[["TIME_PERIOD"]])),
    series       = "HEALTH_EXPENDITURE",
    value        = suppressWarnings(as.numeric(df[["OBS_VALUE"]])),
    unit         = "% of GDP",
    stringsAsFactors = FALSE
  )
  result <- result[!is.na(result$value) & !is.na(result$year), ]
  result[order(result$country, result$year), ]
}

#' Get OECD health expenditure data
#'
#' Downloads (and caches) total current health expenditure as a share of GDP
#' for OECD member countries from the System of Health Accounts (SHA) database.
#'
#' Health expenditure covers all spending on health care goods and services
#' across all financing sources (government, compulsory insurance, voluntary
#' insurance, and out-of-pocket payments), measured as a percentage of GDP at
#' current prices.
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
#'   \item{series}{`"HEALTH_EXPENDITURE"` (character)}
#'   \item{value}{Total health expenditure as a share of GDP (numeric)}
#'   \item{unit}{`"% of GDP"` (character)}
#' }
#'
#' @examples
#' \donttest{
#' op <- options(readoecd.cache_dir = tempdir())
#' health <- get_oecd_health(c("AUS", "GBR", "USA"), start_year = 2000)
#' head(health)
#' options(op)
#' }
#'
#' @family social indicators
#' @export
get_oecd_health <- function(countries = "all", start_year = 1990,
                            refresh = FALSE) {
  countries <- validate_countries(countries)
  filter    <- build_filter(OECD_HEALTH_FILTER_TEMPLATE, countries)
  tag       <- if (is.null(countries)) "health_all" else
    paste0("health_", paste(sort(countries), collapse = "_"))
  raw    <- oecd_fetch(OECD_HEALTH_DATAFLOW, filter, tag, start_year, refresh)
  result <- parse_health(raw)
  result[result$year >= start_year, ]
}
