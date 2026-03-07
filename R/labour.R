# OECD Labour Force Statistics
# Agency:   OECD.SDD.TPS
# Dataset:  DSD_LFS@DF_IALFS_UNE_M  (monthly unemployment rate)
# Confirmed working: 2026-03-07

OECD_UNE_DATAFLOW <- "OECD.SDD.TPS,DSD_LFS@DF_IALFS_UNE_M,1.0"

# Filter template: COUNTRIES + fixed dimensions for the cleanest series
# Dimensions (in order): REF_AREA, MEASURE, UNIT_MEASURE, TRANSFORMATION,
#                        ADJUSTMENT, SEX, AGE, ACTIVITY, FREQ
# We want: total sex (_T), 15+ (Y_GE15), all activity (_Z),
#          seasonally adjusted (Y), monthly (M),
#          unemployment rate as % of labour force (PT_LF_SUB)
OECD_UNE_FILTER_TEMPLATE <-
  "COUNTRIES..PT_LF_SUB._Z.Y._T.Y_GE15._Z.M"

# Parse the labelled CSV into a tidy data frame
parse_unemployment <- function(df) {
  # CSV columns from csvfilewithlabels:
  # STRUCTURE, STRUCTURE_ID, STRUCTURE_NAME, ACTION,
  # REF_AREA, Reference area,
  # MEASURE, Measure,
  # UNIT_MEASURE, Unit of measure,
  # TRANSFORMATION, Transformation,
  # ADJUSTMENT, Adjustment,
  # SEX, Sex,
  # AGE, Age,
  # ACTIVITY, Economic activity,
  # FREQ, Frequency of observation,
  # TIME_PERIOD, Time period,
  # OBS_VALUE, Observation value,
  # ...
  if (nrow(df) == 0) {
    return(data.frame(country=character(0), country_name=character(0),
                      period=character(0), series=character(0),
                      value=numeric(0), unit=character(0),
                      stringsAsFactors=FALSE))
  }
  cname  <- oecd_country_name_col(df)
  result <- data.frame(
    country      = df[["REF_AREA"]],
    country_name = df[[cname]],
    period       = df[["TIME_PERIOD"]],
    series       = "Unemployment rate",
    value        = suppressWarnings(as.numeric(df[["OBS_VALUE"]])),
    unit         = "% of labour force",
    stringsAsFactors = FALSE
  )
  result <- result[!is.na(result$value), ]
  result[order(result$country, result$period), ]
}

#' Get OECD unemployment rates
#'
#' Downloads (and caches) monthly harmonised unemployment rates for OECD
#' member countries from the OECD Labour Force Statistics database.
#'
#' Returns the seasonally adjusted unemployment rate as a percentage of the
#' labour force, for persons aged 15 and over (total, both sexes). This is
#' the standard harmonised series used for cross-country comparisons.
#'
#' @param countries Character vector of ISO 3166-1 alpha-3 country codes, or
#'   `"all"` for all 38 OECD members. Defaults to `"all"`. Run
#'   [list_oecd_countries()] to see available codes.
#' @param start_year Numeric. Earliest year to include. Defaults to `2000`.
#' @param refresh Logical. If `TRUE`, re-download even if a cached copy
#'   exists. Defaults to `FALSE`.
#'
#' @return A data frame with columns:
#' \describe{
#'   \item{country}{ISO 3166-1 alpha-3 country code (character)}
#'   \item{country_name}{English country name (character)}
#'   \item{period}{Calendar month in `"YYYY-MM"` format (character)}
#'   \item{series}{`"Unemployment rate"` (character)}
#'   \item{value}{Unemployment rate as a percentage of the labour force (numeric)}
#'   \item{unit}{`"% of labour force"` (character)}
#' }
#'
#' @examples
#' \donttest{
#' # All OECD members since 2010
#' une <- get_oecd_unemployment(start_year = 2010)
#'
#' # Australia and UK since 2020
#' une <- get_oecd_unemployment(c("AUS", "GBR"), start_year = 2020)
#'
#' # Which country had the highest unemployment in 2020?
#' une2020 <- une[startsWith(une$period, "2020"), ]
#' une2020_avg <- aggregate(value ~ country_name, une2020, mean)
#' head(une2020_avg[order(-une2020_avg$value), ], 5)
#' }
#'
#' @export
get_oecd_unemployment <- function(countries = "all",
                                  start_year = 2000,
                                  refresh    = FALSE) {
  countries <- validate_countries(countries)
  filter    <- build_filter(OECD_UNE_FILTER_TEMPLATE, countries)
  tag       <- if (identical(countries, "all")) "une_all" else
    paste0("une_", paste(sort(countries), collapse = "_"))

  raw    <- oecd_fetch(OECD_UNE_DATAFLOW, filter, tag, start_year, refresh)
  result <- parse_unemployment(raw)

  # Apply start_year filter (period is "YYYY-MM")
  result[as.integer(substr(result$period, 1, 4)) >= start_year, ]
}
