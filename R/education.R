# Education Expenditure -- OECD Education at a Glance (EAG) UOE Finance
# Agency:   OECD.EDU.IMEP
# Dataflow: DSD_EAG_UOE_FIN@DF_UOE_INDIC_FIN_GDP v1.0
#
# Dimensions (8):
#   MEASURE . REF_AREA . EDUCATION_LEV . EXP_SOURCE .
#   EXP_DESTINATION . EXPENDITURE_TYPE . PRICE_BASE . UNIT_MEASURE
#
# Note: REF_AREA is the second dimension (not first).
# Filter: MEASURE=EXP, UNIT_MEASURE=PT_B1GQ (% of GDP), all other dims open.
# parse_education() preferentially retains aggregate education level rows.

OECD_EDUCATION_DATAFLOW        <- "OECD.EDU.IMEP,DSD_EAG_UOE_FIN@DF_UOE_INDIC_FIN_GDP,1.0"
OECD_EDUCATION_FILTER_TEMPLATE <- "EXP.COUNTRIES......"

parse_education <- function(df) {
  if (nrow(df) == 0) return(empty_oecd_result())

  # Prefer aggregate education level (all ISCED levels); fall back to all rows
  agg_codes <- c("ISCED11_0T8", "ISCED97_0T4", "ISCED_0T8", "_T", "ALL",
                 "TOTAL", "ISCED_TOTAL")
  if ("EDUCATION_LEV" %in% names(df)) {
    keep <- df[["EDUCATION_LEV"]] %in% agg_codes
    if (any(keep)) df <- df[keep, ]
    # If no recognised aggregate code, keep all and let user filter downstream
  }

  if (nrow(df) == 0) return(empty_oecd_result())

  cname <- oecd_country_name_col(df)
  result <- data.frame(
    country      = df[["REF_AREA"]],
    country_name = df[[cname]],
    year         = suppressWarnings(as.integer(df[["TIME_PERIOD"]])),
    series       = "EDU_EXPENDITURE",
    value        = suppressWarnings(as.numeric(df[["OBS_VALUE"]])),
    unit         = "% of GDP",
    stringsAsFactors = FALSE
  )
  result <- result[!is.na(result$value) & !is.na(result$year), ]
  result[order(result$country, result$year), ]
}

#' Get OECD education expenditure data
#'
#' Downloads (and caches) total education expenditure as a share of GDP for
#' OECD member countries from the OECD Education at a Glance (EAG) UOE
#' Finance database.
#'
#' Education expenditure covers spending on educational institutions across
#' all levels of education (ISCED 0--8), from all public and private sources,
#' expressed as a percentage of GDP.
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
#'   \item{series}{`"EDU_EXPENDITURE"` (character)}
#'   \item{value}{Total education expenditure as a share of GDP (numeric)}
#'   \item{unit}{`"% of GDP"` (character)}
#' }
#'
#' @examples
#' \donttest{
#' edu <- get_oecd_education(c("AUS", "GBR", "USA"), start_year = 2000)
#' head(edu)
#' }
#'
#' @family social indicators
#' @export
get_oecd_education <- function(countries = "all", start_year = 1990,
                               refresh = FALSE) {
  countries <- validate_countries(countries)
  filter    <- build_filter(OECD_EDUCATION_FILTER_TEMPLATE, countries)
  tag       <- if (is.null(countries)) "edu_all" else
    paste0("edu_", paste(sort(countries), collapse = "_"))
  raw    <- oecd_fetch(OECD_EDUCATION_DATAFLOW, filter, tag, start_year,
                       refresh)
  result <- parse_education(raw)
  result[result$year >= start_year, ]
}
