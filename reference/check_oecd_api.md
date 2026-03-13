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

## Examples

``` r
if (FALSE) { # \dontrun{
check_oecd_api()
} # }
```
