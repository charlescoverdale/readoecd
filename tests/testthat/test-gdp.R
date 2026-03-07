test_that("get_oecd_gdp() rejects invalid country codes", {
  expect_error(get_oecd_gdp("ZZZ"), "not valid OECD member")
})

test_that("get_oecd_gdp() returns correct structure", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_gdp(c("AUS", "GBR"), start_year = 2015)

  expect_s3_class(df, "data.frame")
  expect_named(df, c("country", "country_name", "year", "series", "value", "unit"))
  expect_type(df$country,      "character")
  expect_type(df$country_name, "character")
  expect_type(df$year,         "integer")
  expect_type(df$series,       "character")
  expect_type(df$value,        "double")
  expect_type(df$unit,         "character")
})

test_that("get_oecd_gdp() returns correct countries", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_gdp(c("AUS", "GBR"), start_year = 2018)
  expect_setequal(unique(df$country), c("AUS", "GBR"))
})

test_that("get_oecd_gdp() respects start_year", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_gdp("AUS", start_year = 2010)
  expect_true(all(df$year >= 2010))
})

test_that("get_oecd_gdp() returns plausible values", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_gdp("AUS", start_year = 2020)
  expect_true(nrow(df) > 0)
  expect_true(all(df$value > 0))
  expect_true(all(df$series == "GDP"))
})
