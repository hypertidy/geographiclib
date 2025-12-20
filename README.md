
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
- **Fully vectorized UTM/UPS conversion** - Direct access to Universal
  Transverse Mercator and Universal Polar Stereographic projections
- **Rich output** - Get projected coordinates, zones, convergence, scale
  factors, grid designators, and EPSG codes
- **Variable precision support** - Generate MGRS codes from 100km to 1m
  precision
- **Polar region support** - Handles UPS (Universal Polar Stereographic)
  zones automatically
- **Fast C++ implementation** - Built on GeographicLib’s battle-tested
  geodetic algorithms

## Installation

You can install the development version of geographiclib like so:

``` r
remotes::install_github("hypertidy/geographiclib")
```

## MGRS - Military Grid Reference System

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
#> structure(c(168.54785816744, 169.508864488453, 62.3109609726816, 
#> -105.109947966412, 97.2814318723977, 159.053902504966, -72.2564091067761, 
#> 79.538566977717, -76.83280242607, -67.7227939199656, 80.1980826118961, 
#> -14.1883090557531), dim = c(6L, 2L))

# Variable precision: from 100km (0) to 1m (5)
mgrs_fwd(pts, precision = 0:5)
#> [1] "59CMV"           "59XMJ63"         "41CMQ8271"       "13DDE953880"    
#> [5] "47XMK67340417"   "57LWE0581631446"

# Different precisions for each point
(code <- mgrs_fwd(pts, precision = 5:0))
#> [1] "59CMV1661080766" "59XMJ69773047"   "41CMQ824717"     "13DDE9588"      
#> [5] "47XMK60"         "57LWE"
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
#>          lon       lat        x       y zone northp precision convergence
#> 1  168.54786 -72.25641 416610.5 1980766   59  FALSE         5  2.33562020
#> 2  169.50874  79.53861 469775.0 8830475   59   TRUE         4 -1.46648202
#> 3   62.30980 -76.83309 482450.0 1471750   41  FALSE         3  0.67205594
#> 4 -105.10635 -67.71864 495500.0 2488500   13  FALSE         2  0.09841205
#> 5   97.15689  80.20480 465000.0 8905000   47   TRUE         1 -1.81626281
#> 6  159.46304 -14.02012 550000.0 8450000   57  FALSE         0 -0.11217919
#>       scale grid_zone square_100km        crs
#> 1 0.9996850       59C           MV EPSG:32759
#> 2 0.9996112       59X           MJ EPSG:32659
#> 3 0.9996038       41C           MQ EPSG:32741
#> 4 0.9996002       13D           DE EPSG:32713
#> 5 0.9996150       47X           MK EPSG:32647
#> 6 0.9996309       57L           WE EPSG:32757
```

The reverse conversion returns the center point of each MGRS grid cell.

## UTM/UPS - Universal Transverse Mercator / Universal Polar Stereographic

Direct access to UTM/UPS projections for precise coordinate conversion:

``` r
# Forward: Geographic to UTM/UPS
pts <- cbind(lon = c(147.325, -63.22, 0, 45.67),
             lat = c(-42.881, 17.62, 88, 39.84))
(utm <- utmups_fwd(pts))
#>           x       y zone northp convergence     scale     lon     lat
#> 1  526541.3 5252349   55  FALSE -0.22115661 0.9996087 147.325 -42.881
#> 2  476660.8 1948158   20   TRUE -0.06659487 0.9996067 -63.220  17.620
#> 3 2000000.0 1777931    0   TRUE  0.00000000 0.9943028   0.000  88.000
#> 4  557324.5 4410214   38   TRUE  0.42924443 0.9996405  45.670  39.840
#>          crs
#> 1 EPSG:32755
#> 2 EPSG:32620
#> 3 EPSG:32661
#> 4 EPSG:32638
```

The forward conversion automatically selects the appropriate UTM zone
(or UPS for polar regions) and returns:

- Projected coordinates (x/y in meters)
- Zone and hemisphere information
- Meridian convergence and scale factor
- EPSG CRS codes

``` r
# Reverse: UTM/UPS to Geographic
utmups_rev(utm$x, utm$y, utm$zone, utm$northp)
#>       lon     lat         x       y zone northp convergence     scale
#> 1 147.325 -42.881  526541.3 5252349   55  FALSE -0.22115661 0.9996087
#> 2 -63.220  17.620  476660.8 1948158   20   TRUE -0.06659487 0.9996067
#> 3   0.000  88.000 2000000.0 1777931    0   TRUE  0.00000000 0.9943028
#> 4  45.670  39.840  557324.5 4410214   38   TRUE  0.42924443 0.9996405
#>          crs
#> 1 EPSG:32755
#> 2 EPSG:32620
#> 3 EPSG:32661
#> 4 EPSG:32638
```

### Polar regions

Both MGRS and UTM/UPS automatically handle polar regions using UPS:

``` r
# North and South pole regions
polar_pts <- cbind(c(147, 148, -100), c(88, -88, -85))

# MGRS in polar regions
polar_mgrs <- mgrs_fwd(polar_pts)
mgrs_rev(polar_mgrs)
#>         lon lat       x       y zone northp precision convergence     scale
#> 1  147.0000  88 2120948 2186242    0   TRUE         5    147.0000 0.9943028
#> 2  148.0001 -88 2117678 1811674    0  FALSE         5   -148.0001 0.9943028
#> 3 -100.0000 -85 1452982 1903546    0  FALSE         5    100.0000 0.9958948
#>   grid_zone square_100km        crs
#> 1         Z           BJ EPSG:32661
#> 2         B           BL EPSG:32761
#> 3         A           SM EPSG:32761

# Direct UTM/UPS conversion
utmups_fwd(polar_pts)
#>         x       y zone northp convergence     scale  lon lat        crs
#> 1 2120948 2186243    0   TRUE         147 0.9943028  147  88 EPSG:32661
#> 2 2117679 1811675    0  FALSE        -148 0.9943028  148 -88 EPSG:32761
#> 3 1452981 1903546    0  FALSE         100 0.9958948 -100 -85 EPSG:32761
```

Note that `zone = 0` indicates UPS projection, with dedicated EPSG codes
(32661 for North, 32761 for South).

### Convergence and scale

The convergence angle and scale factor are useful for surveying and
geodetic applications:

``` r
# Points across different longitudes at same latitude
pts <- cbind(lon = seq(-120, 120, by = 30), lat = 45)
result <- utmups_fwd(pts)

# Convergence varies with distance from central meridian
data.frame(
  lon = result$lon,
  zone = result$zone,
  convergence = round(result$convergence, 2),
  scale = round(result$scale, 6)
)
#>    lon zone convergence    scale
#> 1 -120   11       -2.12 1.000287
#> 2  -90   16       -2.12 1.000287
#> 3  -60   21       -2.12 1.000287
#> 4  -30   26       -2.12 1.000287
#> 5    0   31       -2.12 1.000287
#> 6   30   36       -2.12 1.000287
#> 7   60   41       -2.12 1.000287
#> 8   90   46       -2.12 1.000287
#> 9  120   51       -2.12 1.000287
```

### Performance

It’s fast - process tens of thousands of coordinates in milliseconds:

``` r
# World cities dataset
x <- do.call(cbind, maps::world.cities[c("long", "lat")])
dim(x)
#[1] 43645     2

# MGRS conversion
system.time(codes <- mgrs_fwd(x))
#   user  system elapsed 
#   0.04    0.00    0.04 

# UTM/UPS conversion
system.time(utm <- utmups_fwd(x))
#   user  system elapsed 
#   0.03    0.00    0.03

sample(codes, 10)
# [1] "37NCG3952467839" "31PBK7766746791" "36SWD3827984213" "35ULP9426067305" "45VUC7504263576"
# [6] "36RXV9463390163" "31UFT6135362533" "11SLT9551050534" "32TQQ0915128552" "32PMT1934289062"

sum(nchar(codes))
#[1] 654675
```

## Comparison with other packages

Several R packages include GeographicLib source code, but none provided
the vectorized MGRS and UTM/UPS functionality needed:

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
