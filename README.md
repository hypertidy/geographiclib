
<!-- README.md is generated from README.Rmd. Please edit that file -->

# geographiclib

<!-- badges: start -->

[![R-CMD-check](https://github.com/hypertidy/geographiclib/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/hypertidy/geographiclib/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

R interface to [GeographicLib](https://geographiclib.sourceforge.io/)
for precise geodetic calculations on the WGS84 ellipsoid.

## Features

### Grid Reference Systems

- **GARS** - Global Area Reference System (military)
- **Geohash** - Geohash encoding/decoding with precision control
- **Georef** - World Geographic Reference System (aviation)
- **MGRS** - Military Grid Reference System encoding/decoding
- **OSGB** - Ordnance Survey National Grid (Great Britain)

### Coordinate Parsing & Formatting

- **DMS** - Degrees-minutes-seconds parsing and formatting
- **GeoCoords** - Universal coordinate parsing (MGRS, UTM, DMS, decimal)

### Map Projections

- **Albers Equal Area** - Equal-area conic projection
- **Azimuthal Equidistant** - Projection centered on any point
- **Cassini-Soldner** - Historical transverse cylindrical projection
- **Gnomonic** - Geodesics appear as straight lines
- **Lambert Conformal Conic** - Configurable LCC projection
- **Polar Stereographic** - Conformal polar projection with configurable
  scale
- **Transverse Mercator** - Custom TM projections with user-defined
  parameters
- **UTM/UPS** - Universal Transverse Mercator and Universal Polar
  Stereographic

### Geodesic Calculations

- **Geodesic direct/inverse** - Distance, bearing, paths on the
  ellipsoid (exact and fast)
- **Geodesic intersections** - Find where two geodesics cross
- **Nearest neighbor search** - Find closest points using geodesic
  distance
- **Polygon area** - Accurate area/perimeter on the ellipsoid
- **Rhumb lines** - Constant-bearing paths (loxodromes)

### Coordinate Transformations

- **Geocentric** - ECEF (Earth-Centered Earth-Fixed) coordinates
- **Local Cartesian** - East-North-Up (ENU) local coordinates

### Ellipsoid

- **Ellipsoid parameters** - WGS84 parameters, curvature, auxiliary
  latitudes

All functions are fully vectorized with rich metadata output.

## Installation

``` r
remotes::install_github("hypertidy/geographiclib")
```

## Quick example

``` r
library(geographiclib)

# Coordinates to MGRS
pts <- cbind(lon = c(147.32, -74.01, 0.13),
             lat = c(-42.88, 40.71, 51.51))
(codes <- mgrs_fwd(pts))
#> [1] "55GEN2613352461" "18TWL8362507036" "31UCT0084710446"

# MGRS back to coordinates with full metadata
mgrs_rev(codes)
#>           lon    lat        x       y zone northp precision convergence
#> 1 147.3200014 -42.88 526133.5 5252462   55  FALSE         5  -0.2177510
#> 2 -74.0099941  40.71 583625.5 4507036   18   TRUE         5   0.6457496
#> 3   0.1299966  51.51 300847.5 5710446   31   TRUE         5  -2.2471333
#>       scale grid_zone square_100km        crs
#> 1 0.9996084       55G           EN EPSG:32755
#> 2 0.9996861       18T           WL EPSG:32618
#> 3 1.0000870       31U           CT EPSG:32631

## arguments are vectorized
rev0 <- mgrs_rev(vcodes <- mgrs_fwd(rbind(pts, pts), precision = c(0L, 1L, 2L, 3L, 4L, 5L)))
cbind(mgrs = vcodes, rev0)
#>              mgrs         lon       lat        x       y zone northp precision
#> 1           55GEN 147.6124506 -42.90097 550000.0 5250000   55  FALSE         0
#> 2         18TWL80 -73.9940004  40.69152 585000.0 4505000   18   TRUE         1
#> 3       31UCT0010   0.1249653  51.51035 300500.0 5710500   31   TRUE         2
#> 4     55GEN261524 147.3202040 -42.88010 526150.0 5252450   55  FALSE         3
#> 5   18TWL83620703 -74.0100003  40.70999 583625.0 4507035   18   TRUE         4
#> 6 31UCT0084710446   0.1299966  51.51000 300847.5 5710446   31   TRUE         5
#>   convergence     scale grid_zone square_100km        crs
#> 1  -0.4169241 0.9996308       55G           EN EPSG:32755
#> 2   0.6559370 0.9996889       18T           WL EPSG:32618
#> 3  -2.2510864 1.0000887       31U           CT EPSG:32631
#> 4  -0.2178893 0.9996084       55G           EN EPSG:32755
#> 5   0.6457454 0.9996861       18T           WL EPSG:32618
#> 6  -2.2471333 1.0000870       31U           CT EPSG:32631
```

## Documentation

Function reference and vignettes are available at
<https://hypertidy.github.io/geographiclib/>

Articles:

- **[Getting
  Started](https://hypertidy.github.io/geographiclib/articles/geographiclib-overview.html)** -
  Package overview and quick examples
- **[Geodesics](https://hypertidy.github.io/geographiclib/articles/geodesics.html)** -
  Distance, bearings, waypoints, intersections, rhumb lines, polygon
  area, nearest neighbors
- **[Grid
  References](https://hypertidy.github.io/geographiclib/articles/grid-reference-systems.html)** -
  MGRS, Geohash, GARS, Georef, GeoCoords, DMS formatting
- **[Projections](https://hypertidy.github.io/geographiclib/articles/projections.html)** -
  UTM/UPS, Transverse Mercator, Lambert, Albers, Polar Stereographic,
  and more
- **[Local
  Coordinates](https://hypertidy.github.io/geographiclib/articles/local-coordinates.html)** -
  Geocentric (ECEF), Local Cartesian (ENU), ellipsoid properties

## Performance

Fast C++ implementation - process tens of thousands of coordinates in
milliseconds:

``` r
x <- do.call(cbind, maps::world.cities[c("long", "lat")])
system.time(mgrs_fwd(x))       # 43,645 points
#>  user  system elapsed 
#>  0.04    0.00    0.04
```

## Code of Conduct

Please note that the geographiclib project is released with a
[Contributor Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
