# geographiclib 0.3.5

## New features

### DMS (Degrees, Minutes, Seconds) conversion
* `dms_decode()` - Parse DMS strings in various formats to decimal degrees
* `dms_decode_latlon()` - Parse coordinate pairs with automatic hemisphere handling
* `dms_decode_angle()` - Parse angles (no hemisphere designators)
* `dms_decode_azimuth()` - Parse azimuths (E/W allowed, result in [-180, 180])
* `dms_encode()` - Format decimal degrees to DMS strings with configurable precision
* `dms_split()` - Split angles into degree, minute, second components
* `dms_combine()` - Combine d/m/s components to decimal degrees

## Documentation

* Expanded `vignette("grid-reference-systems")` with GeoCoords and DMS sections

# geographiclib 0.3.4

## New features

* `geocoords_parse()` - Parse coordinate strings in various formats (MGRS, UTM, DMS)
* `geocoords_to_mgrs()` - Convert lat/lon to MGRS strings
* `geocoords_to_utm()` - Convert lat/lon to UTM strings

# geographiclib 0.3.3

## New features

* `albers_fwd()` and `albers_rev()` - Albers Equal Area conic projection
  - Supports single or two standard parallels
  - Vectorized on `lon0` parameter
  - Ideal for thematic maps requiring area preservation

* `polarstereo_fwd()` and `polarstereo_rev()` - Polar Stereographic projection
  - Configurable scale factor (default k0 = 0.994 for UPS)
  - Supports both north and south polar regions
  - `northp` parameter is vectorized

# geographiclib 0.3.2

## New features

* `tm_fwd()` and `tm_rev()` - Transverse Mercator projection with user-defined 
  central meridian and scale factor (series approximation, fast, ~5nm accuracy)
* `tm_exact_fwd()` and `tm_exact_rev()` - Transverse Mercator with exact
  formulation (slower but accurate everywhere)
* All TM functions are vectorized on `lon0` parameter

# geographiclib 0.3.1

## Improvements

* `azeq_fwd()` and `azeq_rev()` are now fully vectorized on `lon0` and `lat0`
  parameters, allowing different projection centers for each point. Output now
  includes `lon0` and `lat0` columns to track which center was used.

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
