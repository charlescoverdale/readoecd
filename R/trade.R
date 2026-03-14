# Balance of Payments -- OECD BOP Statistics
# Agency:   OECD.SDD.TPS
# Dataflow: DSD_BOP@DF_BOP v1.0
#
# Dimensions (8):
#   REF_AREA . COUNTERPART_AREA . MEASURE . ACCOUNTING_ENTRY .
#   FS_ENTRY . FREQ . UNIT_MEASURE . ADJUSTMENT
#
# Filter: COUNTERPART_AREA=_Z (rest of world), ACCOUNTING_ENTRY=B (balance),
#         FREQ=A (annual), UNIT_MEASURE=USD_EXC; MEASURE left open.
# parse_trade() selects current account (CA) or goods-and-services (CA_G_S).

OECD_TRADE_DATAFLOW        <- "OECD.SDD.TPS,DSD_BOP@DF_BOP,1.0"
OECD_TRADE_FILTER_TEMPLATE <- "COUNTRIES._Z..B._Z.A.USD_EXC._Z"

parse_trade <- function(df) {
  if (nrow(df) == 0) return(empty_oecd_result())

  # Prefer current account total (CA), then goods + services (CA_G_S)
  measure_priority <- c("CA", "CA_G_S", "CA_G", "CA_S")
  if ("MEASURE" %in% names(df)) {
    avail <- unique(df[["MEASURE"]])
    keep  <- intersect(measure_priority, avail)
    if (length(keep) > 0) {
      df <- df[df[["MEASURE"]] == keep[1], ]
      series_label <- switch(keep[1],
        CA     = "CURRENT_ACCOUNT",
        CA_G_S = "CURRENT_ACCOUNT_GOODS_SERVICES",
        CA_G   = "CURRENT_ACCOUNT_GOODS",
        CA_S   = "CURRENT_ACCOUNT_SERVICES",
        keep[1]
      )
    } else {
      return(empty_oecd_result())
    }
  } else {
    series_label <- "TRADE"
  }

  if (nrow(df) == 0) return(empty_oecd_result())

  cname  <- oecd_country_name_col(df)
  result <- data.frame(
    country      = df[["REF_AREA"]],
    country_name = df[[cname]],
    year         = suppressWarnings(as.integer(df[["TIME_PERIOD"]])),
    series       = series_label,
    value        = suppressWarnings(as.numeric(df[["OBS_VALUE"]])),
    unit         = "Millions USD (exchange rate)",
    stringsAsFactors = FALSE
  )
  result <- result[!is.na(result$value) & !is.na(result$year), ]
  result[order(result$country, result$year), ]
}

#' Get OECD trade (balance of payments) data
#'
#' Downloads (and caches) annual current account balance data for OECD member
#' countries from the OECD Balance of Payments (BOP) database.
#'
#' Returns the current account balance (credits minus debits) with the rest of
#' the world, in millions of US dollars at current exchange rates. A positive
#' value indicates a current account surplus; a negative value indicates a
#' deficit.
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
#'   \item{series}{`"CURRENT_ACCOUNT"` or `"CURRENT_ACCOUNT_GOODS_SERVICES"`
#'     (character)}
#'   \item{value}{Current account balance in millions USD (numeric)}
#'   \item{unit}{`"Millions USD (exchange rate)"` (character)}
#' }
#'
#' @examples
#' \donttest{
#' trade <- get_oecd_current_account(c("AUS", "DEU", "USA"), start_year = 2000)
#' head(trade)
#' }
#'
#' @family productivity and trade
#' @export
get_oecd_current_account <- function(countries = "all", start_year = 1990,
                           refresh = FALSE) {
  countries <- validate_countries(countries)
  filter    <- build_filter(OECD_TRADE_FILTER_TEMPLATE, countries)
  tag       <- if (is.null(countries)) "trade_all" else
    paste0("trade_", paste(sort(countries), collapse = "_"))
  raw    <- oecd_fetch(OECD_TRADE_DATAFLOW, filter, tag, start_year, refresh)
  result <- parse_trade(raw)
  result[result$year >= start_year, ]
}
