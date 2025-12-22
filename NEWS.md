# geographiclib 0.2.0

## New features

### Geohash support
* `geohash_fwd()` - Convert geographic coordinates to Geohash strings
* `geohash_rev()` - Convert Geohash strings back to coordinates with resolution information
* `geohash_resolution()` - Get lat/lon resolution for a given Geohash length
* `geohash_length()` - Find minimum length needed for desired precision

### Geodesic calculations (GeodesicExact)
* `geodesic_direct()` - Solve the direct geodesic problem (find destination given start, azimuth, distance)
* `geodesic_inverse()` - Solve the inverse geodesic problem (find distance and azimuths between two points)
* `geodesic_path()` - Generate points along a geodesic path between two points
* `geodesic_line()` - Generate points at specified distances along a geodesic from a starting point
* `geodesic_distance()` - Compute pairwise geodesic distances
* `geodesic_distance_matrix()` - Compute distance matrix between sets of points

### Polygon area
* `polygon_area()` - Compute geodesic polygon area and perimeter on WGS84 ellipsoid
* `polygon_area_cumulative()` - Compute cumulative area/perimeter as vertices are added

### UTM/UPS conversions
* `utmups_fwd()` - Convert geographic coordinates to UTM/UPS with full metadata
* `utmups_rev()` - Convert UTM/UPS coordinates back to geographic

### MGRS enhancements
* `mgrs_rev()` now returns 12 columns including:
  - Convergence angle and scale factor
  - Grid zone designator and 100km square ID
  - Precision level decoded from MGRS string
  - EPSG CRS codes for direct use with spatial packages

## Internal changes

* All functions now use cpp11 interface (replacing Rcpp-style SEXP code)
* Full vectorization on all coordinate inputs
* Consistent data frame output with rich metadata

# geographiclib 0.1.0

* Initial release with basic MGRS support
* `mgrs_fwd()` - Convert coordinates to MGRS
* `mgrs_rev()` - Convert MGRS to coordinates 
