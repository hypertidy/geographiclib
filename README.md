
<!-- README.md is generated from README.Rmd. Please edit that file -->

# geographiclib

<!-- badges: start -->

[![R-CMD-check](https://github.com/hypertidy/geographiclib/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/hypertidy/geographiclib/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of geographiclib is to wrap the awesome
[GeographicLib](https://geographiclib.sourceforge.io/) library for
precise geodetic calculations in R.

## Features

- **Fully vectorized MGRS conversion** - Convert thousands of
  coordinates in milliseconds
- **Rich reverse conversion output** - Get UTM/UPS coordinates, zones,
  convergence, scale factors, grid designators, and EPSG codes
- **Variable precision support** - Generate MGRS codes from 100km to 1m
  precision
- **Polar region support** - Handles UPS (Universal Polar Stereographic)
  zones automatically
- **Fast C++ implementation** - Built on GeographicLib’s battle-tested
  geodetic algorithms

Currently MGRS (Military Grid Reference System) conversion is exposed.
More GeographicLib functionality coming soon!

## Installation

You can install the development version of geographiclib like so:

``` r
remotes::install_github("hypertidy/geographiclib")
```

## Example

Convert coordinates to MGRS and back:

``` r
library(geographiclib)

(code <- mgrs_fwd(c(147.325, -42.881)))
#> [1] "55GEN2654152348"
mgrs_rev(code)
#>       lon     lat        x       y zone northp precision convergence     scale
#> 1 147.325 -42.881 526541.5 5252348   55  FALSE         5  -0.2211584 0.9996087
#>   grid_zone square_100km        crs
#> 1       55G           EN EPSG:32755
```

### Vectorized forward conversion

The `mgrs_fwd()` function is fully vectorized on both coordinates and
precision:

``` r
pts <- cbind(runif(6, -180, 180), runif(6, -90, 90))
dput(pts)
#> structure(c(-107.481253920123, -133.803564794362, 70.0526936072856, 
#> 21.5749115590006, 44.3363820947707, -42.9503603931516, -37.2774341376498, 
#> -73.1088844919577, 52.4657312734053, 89.4701917190105, -29.9632428959012, 
#> -4.61918272543699), dim = c(6L, 2L))

# Variable precision: from 100km (0) to 1m (5)
mgrs_fwd(pts, precision = 0:5)
#> [1] "13HBU"           "08CND38"         "42UWD7113"       "ZAG216452"      
#> [5] "38JMM35978510"   "23MQQ2738589102"

# Different precisions for each point
(code <- mgrs_fwd(pts, precision = 5:0))
#> [1] "13HBU8001471464" "08CND38798698"   "42UWD715133"     "ZAG2145"        
#> [5] "38JMM38"         "23MQQ"
```

### Rich reverse conversion output

The `mgrs_rev()` function returns a comprehensive data frame with 12
columns:

- **Geographic coordinates** (`lon`/`lat` in decimal degrees)
- **Projected coordinates** (`x`/`y` in meters, UTM/UPS)
- **Zone information** (`zone` number, `northp` hemisphere, `grid_zone`
  designator, `square_100km` ID)
- **Geodetic properties** (`convergence` angle in degrees, `scale`
  factor)
- **Precision level** (0-5, decoded from MGRS string)
- **CRS identification** (`crs` as EPSG codes for direct use with
  spatial packages)

``` r
mgrs_rev(code)
#>          lon        lat         x       y zone northp precision convergence
#> 1 -107.48125 -37.277431  280014.5 5871464   13  FALSE         5   1.5034327
#> 2 -133.80369 -73.108895  538795.0 1886985    8  FALSE         4  -1.1447122
#> 3   70.05321  52.465626  571550.0 5813350   42   TRUE         3   0.8352199
#> 4   21.52901  89.472301 2021500.0 1945500    0   TRUE         2  21.5290069
#> 5   44.32631 -29.964116  435000.0 6685000   38  FALSE         1   0.3364916
#> 6  -42.74546  -4.972039  750000.0 9450000   23  FALSE         0  -0.1955021
#>       scale grid_zone square_100km        crs
#> 1 1.0001962       13H           BU EPSG:32713
#> 2 0.9996184       08C           ND EPSG:32708
#> 3 0.9996628       42U           WD EPSG:32642
#> 4 0.9940211         Z           AG EPSG:32661
#> 5 0.9996521       38J           MM EPSG:32738
#> 6 1.0003737       23M           QQ EPSG:32723
```

The reverse conversion returns the center point of each MGRS grid cell.

### Polar regions

Polar coordinates automatically use UPS (Universal Polar Stereographic):

``` r
# North and South pole regions
polar_pts <- cbind(c(147, 148, -100), c(88, -88, -85))
polar_codes <- mgrs_fwd(polar_pts)
mgrs_rev(polar_codes)
#>         lon lat       x       y zone northp precision convergence     scale
#> 1  147.0000  88 2120948 2186242    0   TRUE         5    147.0000 0.9943028
#> 2  148.0001 -88 2117678 1811674    0  FALSE         5   -148.0001 0.9943028
#> 3 -100.0000 -85 1452982 1903546    0  FALSE         5    100.0000 0.9958948
#>   grid_zone square_100km        crs
#> 1         Z           BJ EPSG:32661
#> 2         B           BL EPSG:32761
#> 3         A           SM EPSG:32761
```

Note that `zone = 0` indicates UPS projection, with dedicated EPSG codes
(32661 for North, 32761 for South).

### Performance

It’s fast - process tens of thousands of coordinates in milliseconds:

``` r
# World cities dataset
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

## Comparison with other packages

Several R packages include GeographicLib source code, but none provided
the vectorized MGRS functionality needed:

- **mgrs** - MGRS support but not vectorized, uses older GEOTRANS code
- **geosphere** - Miscellaneous geodetic functions
- **sf, terra, s2** - Distance and geodetic calculations
- **geodist** - Fast distance calculations
- **nngeo** - Nearest neighbor operations
- **googlePolylines, BH, lwgeom** - Other geodetic utilities

## Development notes

- No changes made to GeographicLib source files
- Package source code named “000\_\*\_geographiclib.cpp” to
  differentiate from original sources
- See `data-raw/GeographicLib.R` for source provenance (obtained
  2025-06-16 from <https://github.com/geographiclib/geographiclib>
  commit 0a6067b)
- Note: R CMD check complains about kissfft.hh and
  src/GeographicLib/Makefile (non-package files from upstream)

## Code of Conduct

Please note that the geographiclib project is released with a
[Contributor Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
