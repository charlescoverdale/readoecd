# Skip a test when the failure is the OECD portal rather than the package.
#
# The SDMX API rate-limits after a few dozen requests and answers 429 until
# the window clears. A suite that goes red on that stops being a useful
# signal: the failures that matter get lost among the ones that do not.
#
# A genuine bug still fails. This only skips the server-side conditions the
# package itself classifies as transient.
expect_oecd <- function(expr) {
  tryCatch(
    force(expr),
    error = function(e) {
      msg <- conditionMessage(e)
      if (grepl("rate limit|HTTP 5[0-9][0-9]|Could not reach|temporarily", msg)) {
        testthat::skip(paste("OECD API unavailable:", substr(msg, 1, 70)))
      }
      stop(e)
    }
  )
}
