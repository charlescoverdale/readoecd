# Government Deficit -- OECD National Accounts (NAAG)
# Agency:   OECD.SDD.NAD
# Dataflow: DSD_NAAG@DF_NAAG v1.0
#
# Dimensions (5):
#   FREQ . REF_AREA . MEASURE . UNIT_MEASURE . CHAPTER
#
# Note: REF_AREA is the second dimension (not first).
# Filter: FREQ=A, MEASURE=B9S13 (general government net lending/borrowing),
#         UNIT_MEASURE=PT_B1GQ (% of GDP), CHAPTER=_Z
#
# A positive value indicates a surplus; a negative value indicates a deficit.

OECD_DEFICIT_DATAFLOW        <- "OECD.SDD.NAD,DSD_NAAG@DF_NAAG,1.0"
OECD_DEFICIT_FILTER_TEMPLATE <- "A.COUNTRIES.B9S13.PT_B1GQ._Z"

parse_deficit <- function(df) {
  if (nrow(df) == 0) return(empty_oecd_result())

  cname  <- oecd_country_name_col(df)
  result <- data.frame(
    country      = df[["REF_AREA"]],
    country_name = df[[cname]],
    year         = suppressWarnings(as.integer(df[["TIME_PERIOD"]])),
    series       = "GOVT_NET_LENDING",
    value        = suppressWarnings(as.numeric(df[["OBS_VALUE"]])),
    unit         = "% of GDP",
    stringsAsFactors = FALSE
  )
  result <- result[!is.na(result$value) & !is.na(result$year), ]
  result[order(result$country, result$year), ]
}

#' Get OECD government deficit data
#'
#' Downloads (and caches) general government net lending/borrowing as a share
#' of GDP for OECD member countries from the OECD National Accounts (NAAG)
#' database.
#'
#' Net lending/borrowing is the difference between government revenue and
#' expenditure, expressed as a percentage of GDP. A positive value indicates
#' a surplus (government saving); a negative value indicates a deficit
#' (government borrowing). This is the standard fiscal balance measure used
#' for cross-country comparisons and is consistent with the System of National
#' Accounts (SNA) definition.
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
#'   \item{series}{`"GOVT_NET_LENDING"` (character)}
#'   \item{value}{Net lending/borrowing as a share of GDP (numeric). Positive
#'     = surplus; negative = deficit.}
#'   \item{unit}{`"% of GDP"` (character)}
#' }
#'
#' @examples
#' \donttest{
#' op <- options(readoecd.cache_dir = tempdir())
#' deficit <- get_oecd_deficit(c("AUS", "GBR", "USA"), start_year = 2000)
#' head(deficit)
#' options(op)
#' }
#'
#' @family fiscal
#' @export
get_oecd_deficit <- function(countries = "all", start_year = 1990,
                             refresh = FALSE) {
  countries <- validate_countries(countries)
  filter    <- build_filter(OECD_DEFICIT_FILTER_TEMPLATE, countries)
  tag       <- if (is.null(countries)) "deficit_all" else
    paste0("deficit_", paste(sort(countries), collapse = "_"))
  raw    <- oecd_fetch(OECD_DEFICIT_DATAFLOW, filter, tag, start_year, refresh)
  result <- parse_deficit(raw)
  result[result$year >= start_year, ]
}
