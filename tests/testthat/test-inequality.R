test_that("get_oecd_inequality() rejects invalid country codes", {
  expect_error(get_oecd_inequality("ZZZ"), "not valid OECD member")
})

test_that("get_oecd_inequality() returns correct structure", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_inequality(c("AUS", "GBR"), start_year = 2010)

  expect_s3_class(df, "data.frame")
  expect_named(df, c("country", "country_name", "year", "series", "value", "unit"))
  expect_type(df$country,      "character")
  expect_type(df$country_name, "character")
  expect_type(df$year,         "integer")
  expect_type(df$series,       "character")
  expect_type(df$value,        "double")
  expect_type(df$unit,         "character")
})

test_that("get_oecd_inequality() returns plausible Gini values", {
  skip_on_cran()
  skip_if_offline()

  df <- get_oecd_inequality("AUS", start_year = 2010)
  expect_true(nrow(df) > 0)
  expect_true(all(df$series == "GINI"))
  # Gini coefficients are between 0 and 1; OECD countries typically 0.25-0.50
  expect_true(all(df$value > 0.1 & df$value < 0.7))
})
