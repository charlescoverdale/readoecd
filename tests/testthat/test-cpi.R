test_that("get_oecd_cpi() rejects invalid country codes", {
  expect_error(get_oecd_cpi("ZZZ"), "not valid OECD member")
})

test_that("get_oecd_cpi() returns correct structure", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_cpi(c("AUS", "GBR"), start_year = 2010)

  expect_s3_class(df, "data.frame")
  expect_named(df, c("country", "country_name", "year", "series", "value", "unit"))
  expect_type(df$country,      "character")
  expect_type(df$country_name, "character")
  expect_type(df$year,         "integer")
  expect_type(df$series,       "character")
  expect_type(df$value,        "double")
  expect_type(df$unit,         "character")
})

test_that("get_oecd_cpi() returns plausible values", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_cpi("GBR", start_year = 2020)
  expect_true(nrow(df) > 0)
  expect_true(all(df$series == "CPI_INFLATION"))
  expect_true(all(df$unit == "% change, year-on-year"))
  # UK inflation 2020-2024 ranged from ~1% to ~11%
  expect_true(any(df$value > 2))
})
