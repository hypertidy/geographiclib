# geographiclib 0.3.0

## New vignettes

* `vignette("grid-reference-systems")` - Detailed guide to MGRS, Geohash, GARS, and Georef with Southern Hemisphere and Antarctic examples
* `vignette("projections")` - Comprehensive coverage of UTM/UPS, LCC, Cassini-Soldner, Gnomonic, Azimuthal Equidistant, and OSGB
* `vignette("geodesics")` - Distance, bearing, path, and polygon area calculations with Antarctic examples
* `vignette("local-coordinates")` - Geocentric (ECEF), Local Cartesian (ENU), and ellipsoid properties for GNSS and surveying

# geographiclib 0.2.0

## New features

### Fast geodesic calculations (series approximation)
* `geodesic_direct_fast()`, `geodesic_inverse_fast()`, `geodesic_path_fast()`
* `geodesic_distance_fast()`, `geodesic_distance_matrix_fast()`
* Slightly faster than exact versions, accurate to ~15 nanometers

### Local Cartesian (ENU) coordinates
* `localcartesian_fwd()` - Convert geographic to local East-North-Up coordinates
* `localcartesian_rev()` - Convert local coordinates back to geographic
* Useful for local surveys and robotics applications

### Cassini-Soldner projection
* `cassini_fwd()` - Convert geographic to Cassini-Soldner projection
* `cassini_rev()` - Convert back to geographic
* Historical projection used for large-scale topographic mapping

### Gnomonic projection
* `gnomonic_fwd()` - Convert geographic to gnomonic projection
* `gnomonic_rev()` - Convert back to geographic
* Geodesics appear as straight lines - useful for great circle route planning

### OSGB - Ordnance Survey National Grid (Great Britain)
* `osgb_fwd()` - Convert WGS84 to OSGB grid coordinates
* `osgb_rev()` - Convert OSGB grid to WGS84
* `osgb_gridref()` - Convert to alphanumeric grid reference strings
* `osgb_gridref_rev()` - Parse grid reference strings
* Includes automatic WGS84/OSGB36 datum transformation

### Geocentric (ECEF) coordinates
* `geocentric_fwd()` - Convert geodetic (lon/lat/height) to geocentric (X/Y/Z) coordinates
* `geocentric_rev()` - Convert geocentric (X/Y/Z) to geodetic coordinates

### WGS84 Ellipsoid parameters
* `ellipsoid_params()` - Get WGS84 ellipsoid parameters (a, f, b, e², etc.)
* `ellipsoid_circle()` - Get circle of latitude radius and meridian distance
* `ellipsoid_latitudes()` - Convert to auxiliary latitudes (parametric, geocentric, rectifying, authalic, conformal, isometric)
* `ellipsoid_latitudes_inv()` - Convert auxiliary latitudes back to geographic
* `ellipsoid_curvature()` - Get meridional and transverse radii of curvature

### Azimuthal Equidistant projection
* `azeq_fwd()` - Convert geographic to azimuthal equidistant projection
* `azeq_rev()` - Convert azimuthal equidistant to geographic coordinates

### GARS (Global Area Reference System)
* `gars_fwd()` - Convert geographic coordinates to GARS codes
* `gars_rev()` - Convert GARS codes to geographic coordinates

### Georef (World Geographic Reference System)
* `georef_fwd()` - Convert geographic coordinates to Georef codes
* `georef_rev()` - Convert Georef codes to geographic coordinates

### Rhumb line (loxodrome) calculations
* `rhumb_direct()` - Solve the direct rhumb problem (find destination given start, azimuth, distance)
* `rhumb_inverse()` - Solve the inverse rhumb problem (find distance and azimuth between two points)
* `rhumb_path()` - Generate points along a rhumb line between two points
* `rhumb_line()` - Generate points at specified distances along a rhumb line
* `rhumb_distance()` - Compute pairwise rhumb distances
* `rhumb_distance_matrix()` - Compute rhumb distance matrix between sets of points

### Lambert Conformal Conic projection
* `lcc_fwd()` - Convert geographic coordinates to LCC projected coordinates
* `lcc_rev()` - Convert LCC coordinates back to geographic
* Supports both single standard parallel (tangent cone) and two standard parallels (secant cone)
* Returns convergence angle and scale factor

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
