
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
- **Lambert Conformal Conic projection** - Configurable LCC with single
  or two standard parallels
- **Geohash encoding/decoding** - Fast, vectorized Geohash conversions
  with precision control
- **Geodesic calculations** - Exact solutions for direct and inverse
  geodesic problems on the WGS84 ellipsoid
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
#> structure(c(-27.3599457275122, 172.636080561206, -117.036015512422, 
#> -47.5933057721704, -171.143041737378, 105.05504976958, 28.349068723619, 
#> 43.595442851074, -14.3855046434328, -20.545814470388, 33.7917225155979, 
#> 67.7353784674779), dim = c(6L, 2L))

# Variable precision: from 100km (0) to 1m (5)
mgrs_fwd(pts, precision = 0:5)
#> [1] "26RMS"           "59TPJ32"         "11LME9609"       "23KKT296259"    
#> [5] "02SMC86753907"   "48WWA0232713362"

# Different precisions for each point
(code <- mgrs_fwd(pts, precision = 5:0))
#> [1] "26RMS6472335924" "59TPJ32062824"   "11LME961096"     "23KKT2925"      
#> [5] "02SMC83"         "48WWA"
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
#>          lon       lat        x       y zone northp precision  convergence
#> 1  -27.35995  28.34907 464723.5 3135924   26   TRUE         5 -0.170920629
#> 2  172.63614  43.59547 632065.0 4828245   59   TRUE         4  1.128383570
#> 3 -117.03571 -14.38539 496150.0 8409650   11  FALSE         3  0.008872274
#> 4  -47.59437 -20.55003 229500.0 7725500   23  FALSE         2  0.911245673
#> 5 -171.16197  33.75497 485000.0 3735000    2   TRUE         1 -0.089995186
#> 6  106.19919  68.05965 550000.0 7550000   48   TRUE         0  1.112355276
#>       scale grid_zone square_100km        crs
#> 1 0.9996154       26R           MS EPSG:32626
#> 2 0.9998145       59T           PJ EPSG:32659
#> 3 0.9996002       11L           ME EPSG:32711
#> 4 1.0005044       23K           KT EPSG:32723
#> 5 0.9996028       02S           MC EPSG:32602
#> 6 0.9996306       48W           WA EPSG:32648
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

## Lambert Conformal Conic Projection

The Lambert Conformal Conic (LCC) projection is widely used for
aeronautical charts and regional coordinate systems:

``` r
# Single standard parallel (tangent cone)
pts <- cbind(lon = c(-100, -99, -98), lat = c(40, 41, 42))
lcc_fwd(pts, lon0 = -100, stdlat = 40)
#>           x        y convergence    scale  lon lat
#> 1      0.00      0.0   0.0000000 1.000000 -100  40
#> 2  84146.25 111521.9   0.6427876 1.000152  -99  41
#> 3 165789.24 224013.2   1.2855752 1.000613  -98  42

# Two standard parallels (secant cone) - common for regional systems
lcc_fwd(pts, lon0 = -96, stdlat1 = 33, stdlat2 = 45)
#>           x        y convergence     scale  lon lat
#> 1 -339643.8 108321.8   -2.521985 0.9946660 -100  40
#> 2 -251122.5 215464.1   -1.891489 0.9950973  -99  41
#> 3 -164998.9 323691.8   -1.260993 0.9958400  -98  42
```

Round-trip conversion:

``` r
fwd <- lcc_fwd(pts, lon0 = -100, stdlat = 40)
lcc_rev(fwd$x, fwd$y, lon0 = -100, stdlat = 40)
#>    lon lat convergence    scale         x        y
#> 1 -100  40   0.0000000 1.000000      0.00      0.0
#> 2  -99  41   0.6427876 1.000152  84146.25 111521.9
#> 3  -98  42   1.2855752 1.000613 165789.24 224013.2
```

## Geohash

Convert coordinates to Geohash strings and back:

``` r
# Single point conversion
(gh <- geohash_fwd(c(147.325, -42.881)))
#> [1] "r22u03yb164p"
geohash_rev(gh)
#>       lon     lat len lat_resolution lon_resolution
#> 1 147.325 -42.881  12   1.676381e-07   3.352761e-07
```

Geohash has a useful property: truncating a code reduces precision but
still contains the original point:

``` r
# Full precision
gh <- geohash_fwd(c(147.325, -42.881), len = 12)
gh
#> [1] "r22u03yb164p"

# Truncated versions still contain the original point
substr(gh, 1, 8)  # ~19m precision
#> [1] "r22u03yb"
substr(gh, 1, 6)  # ~610m precision
#> [1] "r22u03"
substr(gh, 1, 4)  # ~20km precision
#> [1] "r22u"
```

Check resolution for different Geohash lengths:

``` r
geohash_resolution(c(4, 6, 8, 10, 12))
#>   len lat_resolution lon_resolution
#> 1   4   1.757812e-01   3.515625e-01
#> 2   6   5.493164e-03   1.098633e-02
#> 3   8   1.716614e-04   3.433228e-04
#> 4  10   5.364418e-06   1.072884e-05
#> 5  12   1.676381e-07   3.352761e-07
```

## Geodesic Calculations

Solve geodesic problems on the WGS84 ellipsoid with full
double-precision accuracy.

### Direct problem

Given a starting point, azimuth (bearing), and distance, find the
destination:

``` r
# Where do you end up starting from London, heading east for 1000 km?
geodesic_direct(c(-0.1, 51.5), azi = 90, s = 1000000)
#>   lon1 lat1 azi1   s12     lon2     lat2     azi2    m12       M12       M21
#> 1 -0.1 51.5   90 1e+06 14.12014 50.62607 101.0838 995914 0.9877522 0.9877514
#>            S12
#> 1 7.838198e+12
```

### Inverse problem

Given two points, find the distance and azimuths between them:

``` r
# Distance from London to New York
geodesic_inverse(c(-0.1, 51.5), c(-74, 40.7))
#>   lon1 lat1 lon2 lat2     s12      azi1      azi2     m12       M12       M21
#> 1 -0.1 51.5  -74 40.7 5587820 -71.62462 -128.7635 4900877 0.6407216 0.6404073
#>             S12
#> 1 -4.040644e+13
```

### Geodesic paths

Generate points along the shortest path (geodesic) between two points:

``` r
# Great circle path from London to New York
path <- geodesic_path(c(-0.1, 51.5), c(-74, 40.7), n = 10)
path
#>           lon      lat        azi         s
#> 1   -0.100000 51.50000  -71.62462       0.0
#> 2   -8.884387 52.93855  -78.57312  620868.8
#> 3  -18.121882 53.69011  -85.98680 1241737.7
#> 4  -27.529365 53.71152  -93.57462 1862606.5
#> 5  -36.785150 53.00151 -101.00705 2483475.3
#> 6  -45.602073 51.60102 -107.98901 3104344.2
#> 7  -53.782959 49.58257 -114.31523 3725213.0
#> 8  -61.236199 47.03438 -119.88570 4346081.8
#> 9  -67.957770 44.04615 -124.68751 4966950.7
#> 10 -74.000000 40.70000 -128.76352 5587819.5
```

### Distance matrix

Compute distances between sets of points:

``` r
cities <- cbind(
  lon = c(-0.1, -74, 139.7, 151.2),  # London, NYC, Tokyo, Sydney
  lat = c(51.5, 40.7, 35.7, -33.9)
)
# Distance matrix in kilometers
geodesic_distance_matrix(cities) / 1000
#>           [,1]     [,2]      [,3]      [,4]
#> [1,]     0.000  5587.82  9581.233 16990.084
#> [2,]  5587.820     0.00 10872.923 15990.627
#> [3,]  9581.233 10872.92     0.000  7797.237
#> [4,] 16990.084 15990.63  7797.237     0.000
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
#> [1] 4.665774e-310
#> 
#> $perimeter
#> [1] 20577363
#> 
#> $n
#> [1] 3
```

## Polar regions

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

## Performance

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

# Geohash conversion
system.time(gh <- geohash_fwd(x))
#   user  system elapsed 
#   0.02    0.00    0.02

# Geodesic distances (pairwise)
system.time(d <- geodesic_distance(x[1:10000,], x[10001:20000,]))
#   user  system elapsed 
#   0.02    0.00    0.02

sample(codes, 10)
# [1] "37NCG3952467839" "31PBK7766746791" "36SWD3827984213" "35ULP9426067305" "45VUC7504263576"
# [6] "36RXV9463390163" "31UFT6135362533" "11SLT9551050534" "32TQQ0915128552" "32PMT1934289062"

sum(nchar(codes))
#[1] 654675
```

## Comparison with other packages

Several R packages provide geodetic functionality, but none provided the
complete vectorized interface to GeographicLib needed:

- **mgrs** - MGRS support but not vectorized, uses older GEOTRANS code
- **geohash** - Geohash support but not as feature-rich
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
