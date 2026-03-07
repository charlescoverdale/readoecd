test_that("get_oecd_productivity() rejects invalid country codes", {
  expect_error(get_oecd_productivity("ZZZ"), "not valid OECD member")
})

test_that("get_oecd_productivity() returns correct structure", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_productivity(c("AUS", "GBR"), start_year = 2010)

  expect_s3_class(df, "data.frame")
  expect_named(df, c("country", "country_name", "year", "series", "value", "unit"))
  expect_type(df$country,      "character")
  expect_type(df$country_name, "character")
  expect_type(df$year,         "integer")
  expect_type(df$series,       "character")
  expect_type(df$value,        "double")
  expect_type(df$unit,         "character")
})

test_that("get_oecd_productivity() returns plausible values", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_productivity("AUS", start_year = 2015)
  expect_true(nrow(df) > 0)
  expect_true(all(df$value > 0))
  expect_true(df$series[1] %in% c("GDP_PER_HOUR", "GDP_PER_CAPITA"))
})
