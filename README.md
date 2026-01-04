
<!-- README.md is generated from README.Rmd. Please edit that file -->

# geographiclib

<!-- badges: start -->

[![R-CMD-check](https://github.com/hypertidy/geographiclib/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/hypertidy/geographiclib/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

R interface to [GeographicLib](https://geographiclib.sourceforge.io/)
for precise geodetic calculations on the WGS84 ellipsoid.

## Features

- **MGRS** - Military Grid Reference System encoding/decoding
- **UTM/UPS** - Universal Transverse Mercator and Universal Polar
  Stereographic projections
- **Transverse Mercator** - Custom TM projections with user-defined
  parameters
- **Lambert Conformal Conic** - Configurable LCC projection
- **Azimuthal Equidistant** - Projection centered on any point
- **Cassini-Soldner** - Historical transverse cylindrical projection
- **Gnomonic** - Geodesics appear as straight lines
- **OSGB** - Ordnance Survey National Grid (Great Britain)
- **Geohash** - Geohash encoding/decoding with precision control
- **GARS** - Global Area Reference System (military)
- **Georef** - World Geographic Reference System (aviation)
- **Geodesic calculations** - Distance, bearing, paths on the ellipsoid
  (exact and fast)
- **Rhumb lines** - Constant-bearing paths (loxodromes)
- **Polygon area** - Accurate area/perimeter on the ellipsoid
- **Geocentric** - ECEF (Earth-Centered Earth-Fixed) coordinates
- **Local Cartesian** - East-North-Up (ENU) local coordinates
- **Ellipsoid** - WGS84 parameters, curvature, auxiliary latitudes

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
```

## Documentation

See the [package overview
vignette](https://hypertidy.github.io/geographiclib/articles/geographiclib-overview.html)
for a comprehensive tour of all features including:

- MGRS and Geohash encoding
- UTM/UPS and Lambert Conformal Conic projections
- Geodesic distance, bearing, and path calculations
- Polygon area on the ellipsoid

Full documentation at <https://hypertidy.github.io/geographiclib/>

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
