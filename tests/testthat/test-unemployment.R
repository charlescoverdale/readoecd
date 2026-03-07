test_that("get_oecd_unemployment() returns correct structure", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_unemployment(c("AUS", "GBR"), start_year = 2020)

  expect_s3_class(df, "data.frame")
  expect_named(df, c("country", "country_name", "period", "series", "value", "unit"))
  expect_type(df$country,      "character")
  expect_type(df$country_name, "character")
  expect_type(df$period,       "character")
  expect_type(df$series,       "character")
  expect_type(df$value,        "double")
  expect_type(df$unit,         "character")
})

test_that("get_oecd_unemployment() returns correct countries", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_unemployment(c("AUS", "GBR"), start_year = 2023)
  expect_setequal(unique(df$country), c("AUS", "GBR"))
})

test_that("get_oecd_unemployment() respects start_year", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_unemployment("AUS", start_year = 2022)
  expect_true(all(as.integer(substr(df$period, 1, 4)) >= 2022))
})

test_that("get_oecd_unemployment() returns plausible values", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_unemployment(c("AUS", "GBR", "USA"), start_year = 2023)
  expect_true(nrow(df) > 0)
  expect_true(all(df$value >= 0 & df$value <= 30))
})

test_that("get_oecd_unemployment() series and unit are consistent", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_unemployment("AUS", start_year = 2024)
  expect_true(all(df$series == "Unemployment rate"))
  expect_true(all(df$unit   == "% of labour force"))
})

test_that("get_oecd_unemployment() caches results", {
  skip_on_cran()
  skip_if_offline()

  # Use AUS — already downloaded in earlier tests, so second call hits cache
  df1 <- get_oecd_unemployment("AUS", start_year = 2023)
  df2 <- get_oecd_unemployment("AUS", start_year = 2023)
  expect_identical(df1, df2)
})

test_that("get_oecd_unemployment() rejects invalid country", {
  expect_error(get_oecd_unemployment("ZZZ"), "not valid OECD member")
})
