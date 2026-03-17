# Tax Revenue -- OECD Revenue Statistics Comparator
# Agency:   OECD.CTP.TPS
# Dataflow: DSD_REV_COMP_OECD@DF_RSOECD v1.0
#
# Dimensions (7):
#   REF_AREA . MEASURE . SECTOR . STANDARD_REVENUE .
#   CTRY_SPECIFIC_REVENUE . UNIT_MEASURE . FREQ
#
# Filter: MEASURE=TAX_REV, UNIT_MEASURE=PT_B1GQ (% of GDP), FREQ=A
# SECTOR / STANDARD_REVENUE / CTRY_SPECIFIC_REVENUE left open;
# parse_tax() retains the national aggregate (_T / _Z codes).

OECD_TAX_DATAFLOW        <- "OECD.CTP.TPS,DSD_REV_COMP_OECD@DF_RSOECD,1.0"
OECD_TAX_FILTER_TEMPLATE <- "COUNTRIES.TAX_REV...PT_B1GQ.A"

parse_tax <- function(df) {
  if (nrow(df) == 0) return(empty_oecd_result())

  # Retain national totals: SECTOR="_T", revenue dimensions="_Z"
  if ("SECTOR" %in% names(df))
    df <- df[df[["SECTOR"]] == "_T", ]
  if ("STANDARD_REVENUE" %in% names(df))
    df <- df[df[["STANDARD_REVENUE"]] == "_Z", ]
  if ("CTRY_SPECIFIC_REVENUE" %in% names(df))
    df <- df[df[["CTRY_SPECIFIC_REVENUE"]] == "_Z", ]

  if (nrow(df) == 0) return(empty_oecd_result())

  cname  <- oecd_country_name_col(df)
  result <- data.frame(
    country      = df[["REF_AREA"]],
    country_name = df[[cname]],
    year         = suppressWarnings(as.integer(df[["TIME_PERIOD"]])),
    series       = "TAX_REVENUE",
    value        = suppressWarnings(as.numeric(df[["OBS_VALUE"]])),
    unit         = "% of GDP",
    stringsAsFactors = FALSE
  )
  result <- result[!is.na(result$value) & !is.na(result$year), ]
  result[order(result$country, result$year), ]
}

#' Get OECD tax revenue data
#'
#' Downloads (and caches) total tax revenue as a share of GDP for OECD member
#' countries from the OECD Revenue Statistics Comparator database.
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
#'   \item{series}{`"TAX_REVENUE"` (character)}
#'   \item{value}{Total tax revenue as a share of GDP (numeric)}
#'   \item{unit}{`"% of GDP"` (character)}
#' }
#'
#' @examples
#' \donttest{
#' op <- options(readoecd.cache_dir = tempdir())
#' tax <- try(get_oecd_tax(c("AUS", "GBR", "USA"), start_year = 2000))
#' if (!inherits(tax, "try-error")) head(tax)
#' options(op)
#' }
#'
#' @family fiscal
#' @export
get_oecd_tax <- function(countries = "all", start_year = 1990,
                         refresh = FALSE) {
  countries <- validate_countries(countries)
  filter    <- build_filter(OECD_TAX_FILTER_TEMPLATE, countries)
  tag       <- if (is.null(countries)) "tax_all" else
    paste0("tax_", paste(sort(countries), collapse = "_"))
  raw    <- oecd_fetch(OECD_TAX_DATAFLOW, filter, tag, start_year, refresh)
  result <- parse_tax(raw)
  result[result$year >= start_year, ]
}
