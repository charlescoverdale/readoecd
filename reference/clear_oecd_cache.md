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

## Examples

``` r
# \donttest{
clear_oecd_cache()
#> Cache directory does not exist -- nothing to clear.
# }
```
