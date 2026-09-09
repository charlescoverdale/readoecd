# Core utilities: cache management, API fetch, country validation

OECD_API_BASE <- "https://sdmx.oecd.org/public/rest/data"

# Cache directory (base R, no rappdirs)
oecd_cache_dir <- function() {
  getOption("readoecd.cache_dir", default = tools::R_user_dir("readoecd", "cache"))
}

# Build cache file path from dataset + countries + start_year
oecd_cache_path <- function(dataset_tag, countries, start_year) {
  countries_str <- paste(sort(countries), collapse = "_")
  filename <- paste0(dataset_tag, "_", countries_str, "_", start_year, ".csv")
  file.path(oecd_cache_dir(), filename)
}

# Core fetch: download CSV from OECD API and cache it
# dataflow:  e.g. "OECD.SDD.TPS,DSD_LFS@DF_IALFS_UNE_M,1.0"
# filter:    e.g. "AUS+GBR..PT_LF_SUB._Z.Y._T.Y_GE15..M"
# tag:       short identifier used in the cache filename
oecd_fetch <- function(dataflow, filter, tag, start_year, refresh = FALSE) {
  cache_countries <- if (identical(filter, "all")) "all" else filter
  path <- oecd_cache_path(tag, cache_countries, start_year)

  if (!refresh && file.exists(path)) {
    return(utils::read.csv(path, stringsAsFactors = FALSE))
  }

  url <- paste0(
    OECD_API_BASE, "/", dataflow, "/", filter,
    "?startPeriod=", start_year,
    "&format=csvfilewithlabels"
  )

  dir.create(oecd_cache_dir(), showWarnings = FALSE, recursive = TRUE)

  cli::cli_inform("Downloading from OECD API...")

  resp <- tryCatch(
    httr2::request(url) |>
      httr2::req_timeout(120) |>
      # Stay under the OECD's rate limit rather than discovering it. The
      # portal starts refusing after a few dozen requests in quick
      # succession, which a test suite or a loop over countries reaches
      # easily. One request per second costs nothing on a single call.
      httr2::req_throttle(rate = 1) |>
      httr2::req_retry(
        max_tries = 3, backoff = ~ 5,
        # 429 carries a Retry-After the default handler honours; 5xx from
        # this portal are transient too.
        is_transient = function(resp) {
          httr2::resp_status(resp) == 429L || httr2::resp_status(resp) >= 500L
        }
      ) |>
      # Return the response rather than throwing on 4xx and 5xx. Without this,
      # req_perform() raised on every HTTP error and the tryCatch below
      # reported all of them as "Failed to reach the OECD API", telling users
      # to check their internet connection when the API had in fact answered.
      # It also made the status handling further down unreachable.
      httr2::req_error(is_error = function(resp) FALSE) |>
      httr2::req_perform(),
    error = function(e) {
      # Now only genuine transport failures land here: no DNS, no route,
      # connection refused, or the 120s timeout expiring.
      cli::cli_abort(c(
        "Could not reach the OECD API at {.url {url}}.",
        "i" = "The request did not complete, so the API returned nothing to
               interpret. Check your internet connection or proxy settings.",
        "i" = "Original error: {conditionMessage(e)}"
      ))
    }
  )

  status <- httr2::resp_status(resp)

  if (status == 429) {
    cli::cli_abort(c(
      "OECD API rate limit exceeded.",
      "i" = "Wait a few minutes and try again.",
      "i" = "Use {.code refresh = FALSE} (the default) to avoid repeated downloads."
    ))
  }

  if (status == 422) {
    cli::cli_abort(c(
      "OECD API rejected the query for dataset {.val {tag}} (HTTP 422).",
      "i" = "This means the dataflow's dimensions have changed and the
             filter this package sends no longer matches it.",
      "i" = "Response: {.val {substr(httr2::resp_body_string(resp), 1, 120)}}",
      "i" = "This is a package bug, not something you can work around.
             Please report it at
             {.url https://github.com/charlescoverdale/readoecd/issues}"
    ))
  }

  if (status == 404) {
    cli::cli_abort(c(
      "OECD API returned 404 for dataset {.val {tag}}.",
      "i" = "The OECD periodically migrates dataset identifiers.",
      "i" = "Check for a package update: {.run update.packages('readoecd')}",
      "i" = "Or report at: {.url https://github.com/charlescoverdale/readoecd/issues}"
    ))
  }

  if (status != 200) {
    cli::cli_abort(c(
      "OECD API returned HTTP {status} for dataset {.val {tag}}.",
      "i" = "Report at: {.url https://github.com/charlescoverdale/readoecd/issues}"
    ))
  }

  raw <- httr2::resp_body_string(resp)
  df  <- utils::read.csv(text = raw, stringsAsFactors = FALSE)

  utils::write.csv(df, path, row.names = FALSE)
  df
}

# Return a zero-row result data frame with the standard column schema.
empty_oecd_result <- function() {
  data.frame(
    country      = character(0),
    country_name = character(0),
    year         = integer(0),
    series       = character(0),
    value        = numeric(0),
    unit         = character(0),
    stringsAsFactors = FALSE
  )
}

# Locate the human-readable country name column in an OECD CSV response.
# OECD's csvfilewithlabels format adds label columns adjacent to code columns;
# the name for REF_AREA is usually "Reference.area" (R coerces spaces to dots).
oecd_country_name_col <- function(df) {
  cand  <- c("Reference.area", "Reference area", "REF_AREA")
  found <- intersect(cand, names(df))
  if (length(found) > 0) found[1] else "REF_AREA"
}

# Build an OECD filter string with country substitution.
# template uses "COUNTRIES" as a placeholder for the country codes.
build_filter <- function(template, countries) {
  if (identical(countries, "all")) {
    gsub("COUNTRIES", "", template)
  } else {
    gsub("COUNTRIES", paste(countries, collapse = "+"), template)
  }
}

#' List OECD member countries
#'
#' Returns a data frame of the 38 OECD member countries with their ISO 3166-1
#' alpha-3 codes and English names. No network call is required.
#'
#' @return A data frame with columns:
#' \describe{
#'   \item{iso3}{ISO 3166-1 alpha-3 country code (character)}
#'   \item{name}{English country name (character)}
#' }
#'
#' @examples
#' list_oecd_countries()
#'
#' @family utilities
#' @export
list_oecd_countries <- function() {
  data.frame(
    iso3 = c(
      "AUS", "AUT", "BEL", "CAN", "CHL", "COL", "CRI", "CZE",
      "DNK", "EST", "FIN", "FRA", "DEU", "GRC", "HUN", "ISL",
      "IRL", "ISR", "ITA", "JPN", "KOR", "LVA", "LTU", "LUX",
      "MEX", "NLD", "NZL", "NOR", "POL", "PRT", "SVK", "SVN",
      "ESP", "SWE", "CHE", "TUR", "GBR", "USA"
    ),
    name = c(
      "Australia", "Austria", "Belgium", "Canada", "Chile", "Colombia",
      "Costa Rica", "Czech Republic", "Denmark", "Estonia", "Finland",
      "France", "Germany", "Greece", "Hungary", "Iceland", "Ireland",
      "Israel", "Italy", "Japan", "Korea", "Latvia", "Lithuania",
      "Luxembourg", "Mexico", "Netherlands", "New Zealand", "Norway",
      "Poland", "Portugal", "Slovak Republic", "Slovenia", "Spain",
      "Sweden", "Switzerland", "Turkiye", "United Kingdom", "United States"
    ),
    stringsAsFactors = FALSE
  )
}

# Validate country codes and return informative error
validate_countries <- function(countries) {
  if (identical(countries, "all")) return(invisible(NULL))
  valid <- list_oecd_countries()$iso3
  bad   <- setdiff(toupper(countries), valid)
  if (length(bad) > 0) {
    cli::cli_abort(c(
      "{.val {bad}} {?is/are} not valid OECD member ISO3 code{?s}.",
      "i" = "Run {.fn list_oecd_countries} to see all 38 member codes.",
      "i" = "Note: partner countries (e.g. China, India) are not included."
    ))
  }
  toupper(countries)
}

#' Check OECD API connectivity
#'
#' Tests the OECD API by making a small live request. Useful for diagnosing
#' connectivity issues or confirming the API is responding normally.
#'
#' @return Invisibly returns `TRUE` if the API is reachable, otherwise throws
#'   an error.
#'
#' @examples
#' \dontrun{
#' check_oecd_api()
#' }
#'
#' @family utilities
#' @export
check_oecd_api <- function() {
  url <- paste0(
    OECD_API_BASE,
    "/OECD.SDD.TPS,DSD_LFS@DF_IALFS_UNE_M,1.0/",
    "AUS..PT_LF_SUB._Z.Y._T.Y_GE15..M",
    "?startPeriod=2024&lastNObservations=1&format=csvfilewithlabels"
  )
  resp <- tryCatch(
    httr2::request(url) |> httr2::req_timeout(30) |> httr2::req_perform(),
    error = function(e) NULL
  )
  if (is.null(resp) || httr2::resp_status(resp) != 200) {
    cli::cli_abort("OECD API is not reachable. Check your internet connection.")
  }
  cli::cli_inform("OECD API is reachable.")
  invisible(TRUE)
}

#' Clear the readoecd local cache
#'
#' Deletes all files cached by `readoecd` on your local machine. After
#' clearing, the next call to any `get_oecd_*()` function will re-download
#' from the OECD API.
#'
#' @return Invisibly returns the number of files deleted.
#'
#' @examples
#' \donttest{
#' op <- options(readoecd.cache_dir = tempdir())
#' clear_oecd_cache()
#' options(op)
#' }
#'
#' @family utilities
#' @export
clear_oecd_cache <- function() {
  d <- oecd_cache_dir()
  if (!dir.exists(d)) {
    cli::cli_inform("Cache directory does not exist -- nothing to clear.")
    return(invisible(0L))
  }
  files <- list.files(d, full.names = TRUE)
  n <- length(files)
  if (n == 0L) {
    cli::cli_inform("Cache is already empty.")
    return(invisible(0L))
  }
  file.remove(files)
  cli::cli_inform("Cleared {n} cached file{?s}.")
  invisible(n)
}
