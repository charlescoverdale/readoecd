# Tests that run without any network access (CRAN-safe)

test_that("get_oecd_unemployment() rejects invalid country codes", {
  expect_error(get_oecd_unemployment(countries = "ZZZ"), "not valid OECD member")
})

test_that("list_oecd_countries() requires no network", {
  # This must work offline -- no API calls allowed
  df <- list_oecd_countries()
  expect_equal(nrow(df), 38L)
})
