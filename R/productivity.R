# Labour Productivity -- OECD Productivity Database (PDB)
# Agency:   OECD.SDD.TPS
# Dataflow: DSD_PDB@DF_PDB_LV v1.0
#
# Dimensions (9):
#   REF_AREA . FREQ . MEASURE . ACTIVITY . UNIT_MEASURE .
#   PRICE_BASE . TRANSFORMATION . ADJUSTMENT . CONVERSION_TYPE
#
# Filter: FREQ=A, all other dimensions open.
# parse_productivity() selects GDP per hour worked (GDPHRS) where available,
# falling back to GDP per capita (GDPPOP) in USD PPP.

OECD_PRODUCTIVITY_DATAFLOW        <- "OECD.SDD.TPS,DSD_PDB@DF_PDB_LV,1.0"
OECD_PRODUCTIVITY_FILTER_TEMPLATE <- "COUNTRIES.A........"

parse_productivity <- function(df) {
  if (nrow(df) == 0) return(empty_oecd_result())

  # Prefer GDP per hour worked; fall back to GDP per capita
  measure_priority <- c("GDPHRS", "T_GDPHRS", "GDPPOP", "T_GDPPOP")
  if ("MEASURE" %in% names(df)) {
    avail <- unique(df[["MEASURE"]])
    keep  <- intersect(measure_priority, avail)
    if (length(keep) > 0) {
      df <- df[df[["MEASURE"]] == keep[1], ]
      series_label <- switch(keep[1],
        GDPHRS   = "GDP_PER_HOUR",
        T_GDPHRS = "GDP_PER_HOUR",
        GDPPOP   = "GDP_PER_CAPITA",
        T_GDPPOP = "GDP_PER_CAPITA",
        keep[1]
      )
    } else {
      series_label <- "PRODUCTIVITY"
    }
  } else {
    series_label <- "PRODUCTIVITY"
  }

  # Prefer USD PPP unit
  if ("UNIT_MEASURE" %in% names(df)) {
    avail_units <- unique(df[["UNIT_MEASURE"]])
    pref_units  <- c("USD_PPP", "XDC_PS", "USD_EXC")
    keep_unit   <- intersect(pref_units, avail_units)
    if (length(keep_unit) > 0)
      df <- df[df[["UNIT_MEASURE"]] == keep_unit[1], ]
  }

  # Total economy only
  if ("ACTIVITY" %in% names(df))
    df <- df[df[["ACTIVITY"]] %in% c("_T", "TOT", "TOTAL"), ]

  if (nrow(df) == 0) return(empty_oecd_result())

  unit_label <- if ("UNIT_MEASURE" %in% names(df) && nrow(df) > 0)
    unique(df[["UNIT_MEASURE"]])[1] else "USD PPP"

  cname  <- oecd_country_name_col(df)
  result <- data.frame(
    country      = df[["REF_AREA"]],
    country_name = df[[cname]],
    year         = suppressWarnings(as.integer(df[["TIME_PERIOD"]])),
    series       = series_label,
    value        = suppressWarnings(as.numeric(df[["OBS_VALUE"]])),
    unit         = unit_label,
    stringsAsFactors = FALSE
  )
  result <- result[!is.na(result$value) & !is.na(result$year), ]
  result[order(result$country, result$year), ]
}

#' Get OECD productivity data
#'
#' Downloads (and caches) labour productivity data for OECD member countries
#' from the OECD Productivity Database (PDB).
#'
#' Returns GDP per hour worked where available (in USD purchasing power
#' parities), falling back to GDP per capita. Values are at current prices.
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
#'   \item{series}{`"GDP_PER_HOUR"` or `"GDP_PER_CAPITA"` (character)}
#'   \item{value}{Productivity value (numeric)}
#'   \item{unit}{Unit of measurement (character)}
#' }
#'
#' @examples
#' \donttest{
#' op <- options(readoecd.cache_dir = tempdir())
#' prod <- try(get_oecd_productivity(c("AUS", "GBR", "USA"), start_year = 2000))
#' if (!inherits(prod, "try-error")) head(prod)
#' options(op)
#' }
#'
#' @family productivity and trade
#' @export
get_oecd_productivity <- function(countries = "all", start_year = 1990,
                                  refresh = FALSE) {
  countries <- validate_countries(countries)
  filter    <- build_filter(OECD_PRODUCTIVITY_FILTER_TEMPLATE, countries)
  tag       <- if (is.null(countries)) "productivity_all" else
    paste0("productivity_", paste(sort(countries), collapse = "_"))
  raw    <- oecd_fetch(OECD_PRODUCTIVITY_DATAFLOW, filter, tag, start_year,
                       refresh)
  result <- parse_productivity(raw)
  result[result$year >= start_year, ]
}
