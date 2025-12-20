
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
- **Geodesic polygon area** - Accurate area and perimeter calculations
  on the WGS84 ellipsoid
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
#> structure(c(161.328855799511, -103.391612386331, 135.142396884039, 
#> 40.8742207288742, 41.9387888163328, 78.1792014464736, -70.6055350229144, 
#> 17.9450660292059, -9.28087754175067, 0.932147176936269, -48.2449049921706, 
#> -44.7932648425922), dim = c(6L, 2L))

# Variable precision: from 100km (0) to 1m (5)
mgrs_fwd(pts, precision = 0:5)
#> [1] "57DWB"           "13QFV78"         "53LNK1574"       "37NGB085030"    
#> [5] "37FGG18175230"   "44GKR7687936143"

# Different precisions for each point
(code <- mgrs_fwd(pts, precision = 5:0))
#> [1] "57DWB8629264942" "13QFV70338484"   "53LNK156740"     "37NGB0803"      
#> [5] "37FGG15"         "44GKR"
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
#>          lon         lat        x       y zone northp precision convergence
#> 1  161.32885 -70.6055340 586292.5 2164942   57  FALSE         5 -2.19683438
#> 2 -103.39165  17.9450695 670335.0 1984845   13   TRUE         4  0.49566068
#> 3  135.14250  -9.2812521 515650.0 8974050   53  FALSE         3 -0.02298188
#> 4   40.87365   0.9358922 708500.0  103500   37   TRUE         2  0.03061471
#> 5   41.89478 -48.2217574 715000.0 4655000   37  FALSE         1 -2.15954089
#> 6   77.84665 -44.6598207 250000.0 5050000   44  FALSE         0  2.21762068
#>       scale grid_zone square_100km        crs
#> 1 0.9996911       57D           WB EPSG:32757
#> 2 0.9999587       13Q           FV EPSG:32613
#> 3 0.9996030       53L           NK EPSG:32753
#> 4 1.0001382       37N           GB EPSG:32637
#> 5 1.0001680       37F           GG EPSG:32737
#> 6 1.0003686       44G           KR EPSG:32744
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

## Polygon Area - Geodesic area and perimeter

Compute accurate polygon area and perimeter on the WGS84 ellipsoid:

``` r
# Triangle: London - New York - Rio de Janeiro
pts <- cbind(
  lon = c(0, -74, -43),
  lat = c(52, 41, -23)
)
polygon_area(pts)
#> $area
#> [1] 2.653936e+13
#> 
#> $perimeter
#> [1] 22634340
#> 
#> $n
#> [1] 3
```

The area is returned in square meters and the perimeter in meters. The
area is signed: positive for counter-clockwise polygons, negative for
clockwise.

``` r
# Area in square kilometers
result <- polygon_area(pts)
abs(result$area) / 1e6
#> [1] 26539358
```

### Multiple polygons

Use the `id` argument to compute area for multiple polygons at once:

``` r
pts <- cbind(
  lon = c(0, -74, -43, 100, 110, 105, 120),
  lat = c(52, 41, -23, 10, 10, 20, 15)
)
polygon_area(pts, id = c(1, 1, 1, 2, 2, 2, 2))
#>   id          area perimeter n
#> 1  1  2.653936e+13  22634340 3
#> 2  2 -4.264720e+11   6253557 4
```

### Polyline length

Set `polyline = TRUE` to compute the length of a path instead of a
closed polygon:

``` r
# Great circle route length
route <- cbind(
  lon = c(151.2, -122.4, -0.1),  # Sydney - San Francisco - London

  lat = c(-33.9, 37.8, 51.5)
)
polygon_area(route, polyline = TRUE)
#> $area
#> [1] 4.680388e-310
#> 
#> $perimeter
#> [1] 20577363
#> 
#> $n
#> [1] 3
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
the vectorized MGRS, UTM/UPS, and polygon area functionality needed:

- **mgrs** - MGRS support but not vectorized, uses older GEOTRANS code
- **geosphere** - Miscellaneous geodetic functions including polygon
  area (spherical approximation)
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
