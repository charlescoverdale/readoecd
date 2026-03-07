test_that("get_oecd_current_account() rejects invalid country codes", {
  expect_error(get_oecd_current_account("ZZZ"), "not valid OECD member")
})

test_that("get_oecd_current_account() returns correct structure", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_current_account(c("AUS", "DEU"), start_year = 2010)

  expect_s3_class(df, "data.frame")
  expect_named(df, c("country", "country_name", "year", "series", "value", "unit"))
  expect_type(df$country,      "character")
  expect_type(df$country_name, "character")
  expect_type(df$year,         "integer")
  expect_type(df$series,       "character")
  expect_type(df$value,        "double")
  expect_type(df$unit,         "character")
})

test_that("get_oecd_current_account() returns plausible values", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_current_account("AUS", start_year = 2015)
  expect_true(nrow(df) > 0)
  expect_true(df$series[1] %in% c("CURRENT_ACCOUNT", "CURRENT_ACCOUNT_GOODS_SERVICES"))
  expect_true(all(df$unit == "Millions USD (exchange rate)"))
})
