# Clear the readoecd local cache

Deletes all files cached by `readoecd` on your local machine. After
clearing, the next call to any `get_oecd_*()` function will re-download
from the OECD API.

## Usage

``` r
clear_oecd_cache()
```

## Value

Invisibly returns the number of files deleted.

## See also

Other utilities:
[`check_oecd_api()`](https://charlescoverdale.github.io/readoecd/reference/check_oecd_api.md),
[`list_oecd_countries()`](https://charlescoverdale.github.io/readoecd/reference/list_oecd_countries.md)

## Examples

``` r
# \donttest{
op <- options(readoecd.cache_dir = tempdir())
clear_oecd_cache()
#> Warning: cannot remove file '/tmp/Rtmpkmt4wc/bslib-246362e7e3ff6191071d5f9b40ba8d62', reason 'Directory not empty'
#> Cleared 1 cached file.
options(op)
# }
```
