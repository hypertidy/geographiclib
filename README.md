
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
- mgrs (awesome, but not vectorized and uses the old military code)

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
#> structure(c(114.759704517201, -7.08586019463837, -64.7754746954888, 
#> -95.5247894860804, 61.3103591278195, 155.611106855795, 31.8269406678155, 
#> -85.6811079243198, 5.10067101102322, 72.4497017450631, -15.7701186882332, 
#> 68.7295922124758), dim = c(6L, 2L))
mgrs_fwd(pts, precision = 0:5)
#> [1] "50RKA"           "AZS47"           "20NLL0364"       "15XVA150408"    
#> [5] "41LLC18995576"   "56WPB0568326455"
mgrs_fwd(pts, precision = 5:0)
#> [1] "50RKA8797123440" "AZS40827605"     "20NLL031640"     "15XVA1540"      
#> [5] "41LLC15"         "56WPB"
```

Also it’s fast.

``` r
x <- do.call(cbind, maps::world.cities[c("long", "lat")])
dim(x)
#[1] 43645     2
system.time(codes <- mgrs_fwd(x))
#   user  system elapsed 
#   0.04    0.00    0.04 
sample(codes, 10)
# [1] "37NCG3952467839" "31PBK7766746791" "36SWD3827984213" "35ULP9426067305" "45VUC7504263576"
# [6] "36RXV9463390163" "31UFT6135362533" "11SLT9551050534" "32TQQ0915128552" "32PMT1934289062"
sum(nchar(codes))
#[1] 654675
```

## Code of Conduct

Please note that the geographiclib project is released with a
[Contributor Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
