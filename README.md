
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
#> structure(c(80.7739260233939, 36.6979004256427, 39.1493193525821, 
#> -119.001946728677, -12.9028697311878, 18.9792475383729, 88.0304698459804, 
#> 18.4222341142595, 10.5258371355012, -60.552484751679, -83.9670355897397, 
#> -11.9155057193711), dim = c(6L, 2L))

# Variable precision: from 100km (0) to 1m (5)
mgrs_fwd(pts, precision = 0:5)
#> [1] "ZCG"             "37QBA53"         "37PEM1663"       "11ELN902853"    
#> [5] "AYU50305346"     "34LBM7991281987"

# Different precisions for each point
(code <- mgrs_fwd(pts, precision = 5:0))
#> [1] "ZCG1585664938" "37QBA56823844" "37PEM163635"   "11ELN9085"    
#> [5] "AYU55"         "34LBM"
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
#>          lon       lat       x       y zone northp precision convergence
#> 1   80.77404  88.03047 2215856 1964938    0   TRUE         5 80.77403976
#> 2   36.69788  18.42223  256825 2038445   37   TRUE         4 -0.72786976
#> 3   39.14943  10.52579  516350 1163550   37   TRUE         3  0.02729787
#> 4 -118.99668 -60.55155  390500 3285500   11  FALSE         2  1.73888051
#> 5  -12.48249 -83.96290 1855000 2655000    0  FALSE         1 12.48248938
#> 6   18.70229 -12.20245  250000 8650000   34  FALSE         0  0.48591301
#>       scale grid_zone square_100km        crs
#> 1 0.9942937         Z           CG EPSG:32661
#> 2 1.0003311       37Q           BA EPSG:32637
#> 3 0.9996033       37P           EM EPSG:32637
#> 4 0.9997469       11E           LN EPSG:32711
#> 5 0.9967639         A           YU EPSG:32761
#> 6 1.0003733       34L           BM EPSG:32734
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

Here is the Python package by library author Charles F. F. Karney
<https://geographiclib.sourceforge.io/html/python/>

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
