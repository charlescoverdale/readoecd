test_that("get_oecd_deficit() rejects invalid country codes", {
  expect_error(get_oecd_deficit("ZZZ"), "not valid OECD member")
})

test_that("get_oecd_deficit() returns correct structure", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_deficit(c("AUS", "GBR"), start_year = 2010)

  expect_s3_class(df, "data.frame")
  expect_named(df, c("country", "country_name", "year", "series", "value", "unit"))
  expect_type(df$country,      "character")
  expect_type(df$country_name, "character")
  expect_type(df$year,         "integer")
  expect_type(df$series,       "character")
  expect_type(df$value,        "double")
  expect_type(df$unit,         "character")
})

test_that("get_oecd_deficit() returns plausible values", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_deficit("AUS", start_year = 2015)
  expect_true(nrow(df) > 0)
  expect_true(all(df$series == "GOVT_NET_LENDING"))
  expect_true(all(df$unit == "% of GDP"))
  # Plausible range: -15% to +10% of GDP
  expect_true(all(df$value > -20 & df$value < 15))
})
