
<!-- README.md is generated from README.Rmd. Please edit that file -->

# geographiclib

<!-- badges: start -->

<!-- badges: end -->

The goal of geographiclib is to wrap the awesome
[GeographicLib](https://geographiclib.sourceforge.io/) library.

Currently only reverse and forward for a simple MGRS conversion is
exposed, WIP.

Notes for work in progress:

- no changes made to source files, check complains about kissfft.hh and
  src/GeographicLib/Makefile
- source code for *this* package is named “000_stuff_geographiclib.cpp”
  to differentiate from the original sources, which are all included
- see data-raw/GeographicLib.R for the obtaining source (at 2025-06-16
  <https://github.com/geographiclib/geographiclib>
  0a6067b74d2c5316afceb61e3a7a2b2f262960d8)

## Have questions?

Other packages that include source from GeographicLib are these, none
were suitable for my purposes:

- geosphere for miscellaneous (I considered extending geosphere but it’s
  not a very responsive project)
- nngeo for near neighbours
- geodist for distance calcs
- sf for distance calcs
- terra for various
- googlePolylines
- BH
- lwgeom
- s2

## Installation

You can install the development version of geographiclib like so:

``` r
remotes::install_github("hypertidy/geographiclib")
```

## Example

This is a conversion for MGRS, please note this is really in testing
stage and the details will change.

``` r
library(geographiclib)

(code <- mgrs_fwd(c(147.325, -42.881)))
#> [1] "55GEN2654152348"
mgrs_rev(code)
#>         lon         lat           x           y        zone      northp 
#>     147.325     -42.881  526541.500 5252348.500      55.000       0.000
```

The foward mode is vectorized on coordinate and precision value.

``` r
pts <- cbind(runif(6, -180, 180), runif(6, -90, 90))
dput(pts)
#> structure(c(-124.283308396116, 1.25723057426512, 166.786755686626, 
#> -110.804824540392, 21.6347536537796, -129.085749993101, -30.6520690815523, 
#> -64.1709041548893, -83.9470116840675, -87.5648662308231, 40.6639107735828, 
#> 52.7895963191986), dim = c(6L, 2L))
mgrs_fwd(pts, precision = 0:5)
#> [1] "10JCM"           "31DDJ18"         "BBF5345"         "AXM472039"      
#> [5] "34TEL53650164"   "09UVU9421748868"
mgrs_fwd(pts, precision = 5:0)
#> [1] "10JCM7704008254" "31DDJ15288278"   "BBF537451"       "AXM4703"        
#> [5] "34TEL50"         "09UVU"
```

## Code of Conduct

Please note that the geographiclib project is released with a
[Contributor Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
