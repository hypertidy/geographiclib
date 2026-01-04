# GeographicLib Usage Analysis

**Last updated:** 2026-01-05

This document analyzes which parts of the vendored GeographicLib C++ library
are used by the R package, and which remain unused.

## Summary

| Category | Count | Status |
|----------|-------|--------|
| **Fully Used** | 20 | Core functionality exposed to R |
| **Partially Used** | 3 | Some features exposed, others available |
| **Not Used** | 13 | Available but not exposed |

## Fully Used Components

These GeographicLib classes are wrapped and exposed to R users:

| Component | R Functions | Description |
|-----------|-------------|-------------|
| **AlbersEqualArea** | `albers_fwd()`, `albers_inv()` | Albers equal-area conic projection |
| **AzimuthalEquidistant** | `azimuthal_fwd()`, `azimuthal_inv()` | Azimuthal equidistant projection |
| **CassiniSoldner** | `cassini_fwd()`, `cassini_inv()` | Cassini-Soldner projection |
| **DMS** | `dms_decode()`, `dms_encode()`, `dms_split()`, `dms_combine()` | Degrees-minutes-seconds conversion |
| **Ellipsoid** | `ellipsoid()`, `ellipsoid_radius()`, `ellipsoid_area()` | Ellipsoid parameters and calculations |
| **GARS** | `gars_fwd()`, `gars_inv()` | Global Area Reference System |
| **Geocentric** | `geocentric_fwd()`, `geocentric_inv()` | ECEF coordinate conversion |
| **GeoCoords** | `geocoords_parse()`, `geocoords_to_mgrs()`, `geocoords_to_utm()` | Universal coordinate parsing |
| **Geodesic** | `geodesic_direct()`, `geodesic_inverse()`, `geodesic_waypoints()` | Exact geodesic calculations |
| **GeodesicExact** | `geodesic_direct()`, `geodesic_inverse()` (with `exact=TRUE`) | High-precision geodesics using elliptic integrals |
| **GeodesicLine** | `geodesic_waypoints()` | Points along a geodesic path |
| **GeodesicLineExact** | `geodesic_waypoints()` (with `exact=TRUE`) | Exact waypoint calculations |
| **Geohash** | `geohash_fwd()`, `geohash_inv()` | Geohash encoding/decoding |
| **Georef** | `georef_fwd()`, `georef_inv()` | World Geographic Reference System |
| **Gnomonic** | `gnomonic_fwd()`, `gnomonic_inv()` | Gnomonic projection |
| **Intersect** | `geodesic_intersect()`, `geodesic_intersect_segment()`, `geodesic_intersect_next()`, `geodesic_intersect_all()` | Geodesic intersection finding |
| **LambertConformalConic** | `lcc_fwd()`, `lcc_inv()` | Lambert conformal conic projection |
| **LocalCartesian** | `localcartesian_fwd()`, `localcartesian_inv()` | Local ENU coordinates |
| **MGRS** | `mgrs_fwd()`, `mgrs_inv()` | Military Grid Reference System |
| **NearestNeighbor** | `geodesic_nn()`, `geodesic_nn_radius()` | Spatial nearest neighbor search |
| **OSGB** | `osgb_fwd()`, `osgb_inv()` | Ordnance Survey National Grid |
| **PolarStereographic** | `polarstereo_fwd()`, `polarstereo_inv()` | Polar stereographic projection |
| **PolygonArea** | `polygon_area()` | Geodesic polygon area and perimeter |
| **Rhumb** | `rhumb_direct()`, `rhumb_inverse()` | Rhumb line (loxodrome) calculations |
| **RhumbLine** | `rhumb_waypoints()` | Points along a rhumb line |
| **TransverseMercator** | `tm_fwd()`, `tm_inv()` | Transverse Mercator projection |
| **TransverseMercatorExact** | `tm_fwd()`, `tm_inv()` (with `exact=TRUE`) | Exact TM using elliptic integrals |
| **UTMUPS** | `utm_fwd()`, `utm_inv()` | UTM/UPS projections |

## Partially Used Components

These components have some functionality exposed, with additional features available:

| Component | Used | Available but not exposed |
|-----------|------|---------------------------|
| **DMS** | Decode, Encode | `Flag` enum for hemisphere indicators, `Encode()` with explicit trailing component |
| **Ellipsoid** | Basic parameters, radii, area | `RectifyingLatitude()`, `AuthalicLatitude()`, `ConformalLatitude()`, `IsometricLatitude()`, `CircleRadius()`, `CircleHeight()` |
| **Geodesic** | Direct, Inverse, Line | GenDirect, GenInverse (mask-based output selection) |

## Not Used Components

These GeographicLib classes are included but not exposed to R:

| Component | Description | Potential Use |
|-----------|-------------|---------------|
| **Accumulator** | High-precision summation | Internal use for polygon area |
| **CircularEngine** | Circular harmonic sums | Gravity/magnetic models |
| **DST** | Discrete Sine Transform | Internal for TransverseMercatorExact |
| **EllipticFunction** | Elliptic integrals and functions | Internal for exact calculations |
| **GravityCircle** | Gravity on a circle of latitude | Geophysics applications |
| **GravityModel** | Earth gravity field models | Requires external data files |
| **Geoid** | Geoid height calculations | Requires external data files |
| **MagneticCircle** | Magnetic field on a circle | Geophysics applications |
| **MagneticModel** | Earth magnetic field models | Requires external data files |
| **NormalGravity** | Reference gravity field | Geophysics applications |
| **SphericalEngine** | Spherical harmonic sums | Gravity/magnetic models |
| **SphericalHarmonic** | Spherical harmonic series | Gravity/magnetic models |
| **SphericalHarmonic1/2** | Spherical harmonic variants | Gravity/magnetic models |

## Header-Only Utilities

These are internal utilities used by the exposed components:

| Header | Purpose |
|--------|---------|
| **Constants.hpp** | WGS84 constants, Math utilities |
| **Math.hpp** | Mathematical helper functions |
| **Utility.hpp** | String parsing, formatting |

## Source Files Analysis

### Used Source Files (compiled and linked)

```
AlbersEqualArea.cpp       - Albers projection
AzimuthalEquidistant.cpp  - Azimuthal equidistant projection
CassiniSoldner.cpp        - Cassini-Soldner projection
DMS.cpp                   - DMS parsing/formatting
DST.cpp                   - Internal for TM exact
Ellipsoid.cpp             - Ellipsoid calculations
EllipticFunction.cpp      - Internal for exact calculations
GARS.cpp                  - GARS encoding
GeoCoords.cpp             - Coordinate parsing
Geocentric.cpp            - ECEF conversion
Geodesic.cpp              - Core geodesic calculations
GeodesicExact.cpp         - Exact geodesics
GeodesicLine.cpp          - Geodesic paths
GeodesicLineExact.cpp     - Exact geodesic paths
Geohash.cpp               - Geohash encoding
Georef.cpp                - Georef encoding
Gnomonic.cpp              - Gnomonic projection
Intersect.cpp             - Geodesic intersections
LambertConformalConic.cpp - LCC projection
LocalCartesian.cpp        - Local ENU coordinates
MGRS.cpp                  - MGRS encoding
OSGB.cpp                  - British National Grid
PolarStereographic.cpp    - Polar stereographic
PolygonArea.cpp           - Polygon area/perimeter
Rhumb.cpp                 - Rhumb lines
TransverseMercator.cpp    - TM projection
TransverseMercatorExact.cpp - Exact TM projection
UTMUPS.cpp                - UTM/UPS projection
```

### Unused Source Files (compiled but not directly called from R)

```
Accumulator.cpp           - Used internally by PolygonArea
GravityCircle.cpp         - Not exposed
GravityModel.cpp          - Not exposed (requires data files)
Geoid.cpp                 - Not exposed (requires data files)
MagneticCircle.cpp        - Not exposed
MagneticModel.cpp         - Not exposed (requires data files)
NormalGravity.cpp         - Not exposed
SphericalEngine.cpp       - Used by gravity/magnetic models
```

### Header-Only Components (no .cpp file)

```
CircularEngine.hpp        - Template for circular harmonics
NearestNeighbor.hpp       - Template for spatial search (USED)
SphericalHarmonic.hpp     - Template for spherical harmonics
SphericalHarmonic1.hpp    - Template variant
SphericalHarmonic2.hpp    - Template variant
```

## R Package Wrapper Files

```
src/000_albers_geographiclib.cpp      - AlbersEqualArea wrapper
src/000_azimuthal_geographiclib.cpp   - AzimuthalEquidistant wrapper
src/000_cassini_geographiclib.cpp     - CassiniSoldner wrapper
src/000_dms_geographiclib.cpp         - DMS wrapper
src/000_ellipsoid_geographiclib.cpp   - Ellipsoid wrapper
src/000_gars_geographiclib.cpp        - GARS wrapper
src/000_geocentric_geographiclib.cpp  - Geocentric wrapper
src/000_geocoords_geographiclib.cpp   - GeoCoords wrapper
src/000_geodesic_geographiclib.cpp    - Geodesic/GeodesicExact wrapper
src/000_geohash_geographiclib.cpp     - Geohash wrapper
src/000_georef_geographiclib.cpp      - Georef wrapper
src/000_gnomonic_geographiclib.cpp    - Gnomonic wrapper
src/000_intersect_geographiclib.cpp   - Intersect wrapper
src/000_lcc_geographiclib.cpp         - LambertConformalConic wrapper
src/000_localcartesian_geographiclib.cpp - LocalCartesian wrapper
src/000_mgrs_geographiclib.cpp        - MGRS wrapper
src/000_nn_geographiclib.cpp          - NearestNeighbor wrapper
src/000_osgb_geographiclib.cpp        - OSGB wrapper
src/000_polarstereo_geographiclib.cpp - PolarStereographic wrapper
src/000_polygon_geographiclib.cpp     - PolygonArea wrapper
src/000_rhumb_geographiclib.cpp       - Rhumb wrapper
src/000_tm_geographiclib.cpp          - TransverseMercator wrapper
src/000_utm_geographiclib.cpp         - UTMUPS wrapper
```

## Recommendations

### Do Not Remove Any Files

All source files should be retained because:

1. **Internal Dependencies**: Components like `Accumulator`, `EllipticFunction`, 
   and `DST` are used internally by exposed functionality
2. **Future Expansion**: Unused components may be exposed in future versions
3. **Compilation**: All files are compiled together; selective removal could 
   break the build

### Potential Future Additions

Components that could be exposed with additional work:

| Component | Effort | Notes |
|-----------|--------|-------|
| **Geoid** | Medium | Requires bundling or downloading data files (~2-400 MB) |
| **GravityModel** | Medium | Requires data files; specialized use case |
| **MagneticModel** | Medium | Requires data files; time-varying |
| **NormalGravity** | Low | Reference gravity; specialized use case |
| **Auxiliary Latitudes** | Low | Already have some in Ellipsoid; could expand |

### Coverage Statistics

- **Classes Exposed**: 27 of 40 (~68%)
- **Core Geodesy**: 100% coverage
- **Projections**: 100% coverage (9 projections)
- **Grid References**: 100% coverage (5 systems)
- **Coordinate Utilities**: 100% coverage
- **Geophysics**: 0% coverage (requires external data)
