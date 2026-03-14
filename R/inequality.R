# Income Inequality -- OECD Wealth, Income and Equality (WISE) IDD
# Agency:   OECD.WISE.INE
# Dataflow: DSD_WISE_IDD@DF_IDD v1.0
#
# Dimensions (9):
#   REF_AREA . FREQ . MEASURE . STATISTICAL_OPERATION . UNIT_MEASURE .
#   AGE . METHODOLOGY . DEFINITION . POVERTY_LINE
#
# Filter: FREQ=A, all other dimensions open.
# parse_inequality() retains the Gini coefficient of disposable income
# (MEASURE = INC_DISP_GINI) for the total population.

OECD_INEQUALITY_DATAFLOW        <- "OECD.WISE.INE,DSD_WISE_IDD@DF_IDD,1.0"
OECD_INEQUALITY_FILTER_TEMPLATE <- "COUNTRIES.A........"

parse_inequality <- function(df) {
  if (nrow(df) == 0) return(empty_oecd_result())

  # Gini coefficient of disposable income
  gini_codes <- c("INC_DISP_GINI", "GINI_DISP", "INC_GINI", "GINI")
  if ("MEASURE" %in% names(df)) {
    avail <- unique(df[["MEASURE"]])
    keep  <- intersect(gini_codes, avail)
    if (length(keep) > 0) {
      df <- df[df[["MEASURE"]] == keep[1], ]
    } else {
      cli::cli_warn(c(
        "Could not identify Gini coefficient measure in this dataset.",
        "i" = "Available measures: {.val {avail}}",
        "i" = "Report at: {.url https://github.com/charlescoverdale/readoecd/issues}"
      ))
      return(empty_oecd_result())
    }
  }

  # Total population (AGE = _T or _Z)
  if ("AGE" %in% names(df))
    df <- df[df[["AGE"]] %in% c("_T", "_Z", "TOTAL"), ]

  # Current methodology only (avoid mixing old/new series)
  if ("METHODOLOGY" %in% names(df)) {
    meth <- unique(df[["METHODOLOGY"]])
    pref <- intersect(c("METH2012", "METH2011", "_Z"), meth)
    if (length(pref) > 0) df <- df[df[["METHODOLOGY"]] == pref[1], ]
  }

  if (nrow(df) == 0) return(empty_oecd_result())

  cname  <- oecd_country_name_col(df)
  result <- data.frame(
    country      = df[["REF_AREA"]],
    country_name = df[[cname]],
    year         = suppressWarnings(as.integer(df[["TIME_PERIOD"]])),
    series       = "GINI",
    value        = suppressWarnings(as.numeric(df[["OBS_VALUE"]])),
    unit         = "Gini coefficient (0-1)",
    stringsAsFactors = FALSE
  )
  result <- result[!is.na(result$value) & !is.na(result$year), ]
  result[order(result$country, result$year), ]
}

#' Get OECD income inequality data
#'
#' Downloads (and caches) the Gini coefficient of disposable income for OECD
#' member countries from the OECD Income Distribution Database (IDD).
#'
#' The Gini coefficient measures income inequality on a scale from 0 (perfect
#' equality) to 1 (maximum inequality). Disposable income is household income
#' after taxes and transfers. The series follows the OECD METH2012 methodology
#' where available for consistency across countries and time.
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
#'   \item{series}{`"GINI"` (character)}
#'   \item{value}{Gini coefficient of disposable income (numeric)}
#'   \item{unit}{`"Gini coefficient (0-1)"` (character)}
#' }
#'
#' @examples
#' \donttest{
#' gini <- get_oecd_inequality(c("AUS", "GBR", "USA", "DNK"), start_year = 2000)
#' head(gini)
#' }
#'
#' @family social indicators
#' @export
get_oecd_inequality <- function(countries = "all", start_year = 1990,
                                refresh = FALSE) {
  countries <- validate_countries(countries)
  filter    <- build_filter(OECD_INEQUALITY_FILTER_TEMPLATE, countries)
  tag       <- if (is.null(countries)) "inequality_all" else
    paste0("inequality_", paste(sort(countries), collapse = "_"))
  raw    <- oecd_fetch(OECD_INEQUALITY_DATAFLOW, filter, tag, start_year,
                       refresh)
  result <- parse_inequality(raw)
  result[result$year >= start_year, ]
}
