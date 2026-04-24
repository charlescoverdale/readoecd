# Check OECD API connectivity

Tests the OECD API by making a small live request. Useful for diagnosing
connectivity issues or confirming the API is responding normally.

## Usage

``` r
check_oecd_api()
```

## Value

Invisibly returns `TRUE` if the API is reachable, otherwise throws an
error.

## See also

Other utilities:
[`clear_oecd_cache()`](https://charlescoverdale.github.io/readoecd/reference/clear_oecd_cache.md),
[`list_oecd_countries()`](https://charlescoverdale.github.io/readoecd/reference/list_oecd_countries.md)

## Examples

``` r
if (FALSE) { # \dontrun{
check_oecd_api()
} # }
```
