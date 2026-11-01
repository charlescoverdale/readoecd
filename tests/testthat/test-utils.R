test_that("list_oecd_countries() returns correct structure", {
  df <- expect_oecd(list_oecd_countries())
  expect_s3_class(df, "data.frame")
  expect_equal(nrow(df), 38L)
  expect_named(df, c("iso3", "name"))
  expect_type(df$iso3, "character")
  expect_type(df$name, "character")
})

test_that("list_oecd_countries() contains key members", {
  iso3 <- expect_oecd(list_oecd_countries())$iso3
  expect_true("AUS" %in% iso3)
  expect_true("GBR" %in% iso3)
  expect_true("USA" %in% iso3)
  expect_true("DEU" %in% iso3)
  expect_true("JPN" %in% iso3)
})

test_that("validate_countries() accepts valid ISO3 codes", {
  expect_equal(validate_countries("AUS"), "AUS")
  expect_equal(validate_countries(c("AUS", "GBR")), c("AUS", "GBR"))
  expect_equal(validate_countries("all"), NULL)
})

test_that("validate_countries() rejects invalid codes", {
  expect_error(validate_countries("ZZZ"), "not valid OECD member")
  expect_error(validate_countries("CHN"), "not valid OECD member")
  expect_error(validate_countries("GB"),  "not valid OECD member")
})

test_that("validate_countries() is case-insensitive", {
  expect_equal(validate_countries("aus"), "AUS")
  expect_equal(validate_countries("gbr"), "GBR")
})

test_that("build_filter() substitutes country codes", {
  tmpl   <- "COUNTRIES..PT_LF_SUB.M"
  result <- build_filter(tmpl, c("AUS", "GBR"))
  expect_equal(result, "AUS+GBR..PT_LF_SUB.M")
})

test_that("build_filter() handles 'all' correctly", {
  tmpl   <- "COUNTRIES..PT_LF_SUB.M"
  result <- build_filter(tmpl, "all")
  expect_equal(result, "..PT_LF_SUB.M")
})

test_that("clear_oecd_cache() runs without error", {
  # Should not error even if cache is empty
  expect_no_error(clear_oecd_cache())
})

test_that("oecd_members_only() drops aggregates and partner economies", {
  df <- data.frame(country = c("OECD", "GBR", "EU27_2020", "IND", "USA"),
                   value = 1:5)
  out <- oecd_members_only(df)
  expect_equal(out$country, c("GBR", "USA"))
  expect_equal(oecd_members_only(df[0, ])$country, character(0))
})

test_that("oecd_cache_ttl() defaults to 7 days and rejects bad values", {
  op <- options(readoecd.cache_ttl = NULL)
  on.exit(options(op))
  expect_equal(oecd_cache_ttl(), 168)
  options(readoecd.cache_ttl = -1)
  expect_error(oecd_cache_ttl(), "non-negative")
})

test_that("oecd_fetch() serves a fresh cached copy without the network", {
  op <- options(readoecd.cache_dir = tempfile("readoecd_ttl_"),
                readoecd.cache_ttl = 1)
  on.exit(options(op))
  dir.create(oecd_cache_dir(), recursive = TRUE)
  path <- oecd_cache_path("TEST", "AUS", 2020)
  utils::write.csv(data.frame(x = 1), path, row.names = FALSE)
  out <- oecd_fetch("NOT.A,REAL@FLOW,1.0", "AUS", "TEST", 2020)
  expect_equal(out, data.frame(x = 1L))
})

test_that("check_oecd_api() reaches the API", {
  skip_on_cran()
  skip_if_offline()
  # Skip if rate-limited or temporarily unavailable
  result <- tryCatch(check_oecd_api(), error = function(e) NULL)
  skip_if(is.null(result), "OECD API not reachable (may be rate-limited)")
  expect_true(result)
})
