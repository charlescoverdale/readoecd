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

## Details

Cached files are used for 7 days and then downloaded again; set
`options(readoecd.cache_ttl = )` to a number of hours to change this.

## See also

Other utilities:
[`check_oecd_api()`](https://charlescoverdale.github.io/readoecd/reference/check_oecd_api.md),
[`list_oecd_countries()`](https://charlescoverdale.github.io/readoecd/reference/list_oecd_countries.md)

## Examples

``` r
# \donttest{
op <- options(readoecd.cache_dir = tempdir())
clear_oecd_cache()
#> Warning: cannot remove file '/tmp/RtmpyxknST/bslib-7db53ff92ec092c0dbca0588320fd109', reason 'Directory not empty'
#> Warning: cannot remove file '/tmp/RtmpyxknST/downlit', reason 'Directory not empty'
#> Cleared 2 cached files.
options(op)
# }
```
