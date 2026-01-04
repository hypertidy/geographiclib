# GeographicLib Source Usage Analysis

Generated: 2026-01-04 (Updated)

## Summary

| Category | Count | Size |
|----------|-------|------|
| Total GeographicLib headers | 49 | 916 KB |
| Used headers | 32 | ~580 KB |
| **Unused headers** | 17 | 336 KB |
| Total GeographicLib .cpp files | 49 | 960 KB |
| Used .cpp files | 31 | ~660 KB |
| **Unused .cpp files** | 18 | 300 KB |
| Our wrapper files (000_*.cpp) | 17 | 105 KB |

**Approximately 33% of vendored source code is unused.**

## Headers We Directly Include (23)

These are included in our `src/000_*.cpp` wrapper files:

1. AlbersEqualArea
2. AzimuthalEquidistant
3. CassiniSoldner
4. Constants
5. Ellipsoid
6. GARS
7. Geocentric
8. Geodesic
9. GeodesicExact
10. GeodesicLine
11. GeodesicLineExact
12. Geohash
13. Georef
14. Gnomonic
15. LambertConformalConic
16. LocalCartesian
17. MGRS
18. OSGB
19. PolarStereographic
20. PolygonArea
21. Rhumb
22. TransverseMercator
23. TransverseMercatorExact
24. UTMUPS

## Transitive Dependencies (9 additional headers)

These are required by the headers we include:

1. Accumulator
2. AuxAngle
3. AuxLatitude
4. DAuxLatitude
5. DST
6. EllipticFunction
7. Math
8. RhumbLine (required by Rhumb)

## UNUSED Headers (17)

These headers are not used by our package:

| Header | Size | Description |
|--------|------|-------------|
| Angle.hpp | 28 KB | Template class for managing angles |
| CircularEngine.hpp | 8 KB | Spherical harmonic evaluation |
| DMS.hpp | 20 KB | Degrees/minutes/seconds parsing |
| GeoCoords.hpp | 24 KB | Combined MGRS/UTM/lat-lon class |
| Geoid.hpp | 20 KB | Geoid height lookup (requires data files) |
| GravityCircle.hpp | 12 KB | Gravity calculations on a circle |
| GravityModel.hpp | 24 KB | Earth gravity model (requires data files) |
| Intersect.hpp | 28 KB | Geodesic intersection calculations |
| MagneticCircle.hpp | 8 KB | Magnetic field on a circle |
| MagneticModel.hpp | 20 KB | Earth magnetic field model (requires data files) |
| NearestNeighbor.hpp | 36 KB | Nearest neighbor search |
| NormalGravity.hpp | 20 KB | Normal gravity calculations |
| SphericalEngine.hpp | 20 KB | Spherical harmonic engine |
| SphericalHarmonic.hpp | 16 KB | Spherical harmonics |
| SphericalHarmonic1.hpp | 12 KB | Spherical harmonics (variant) |
| SphericalHarmonic2.hpp | 16 KB | Spherical harmonics (variant) |
| Utility.hpp | 28 KB | Utility functions |

## UNUSED .cpp Files (21)

| File | Size | Notes |
|------|------|-------|
| AlbersEqualArea.cpp | 28 KB | |
| Angle.cpp | 4 KB | |
| Cartesian3.cpp | 12 KB | No header (internal?) |
| CircularEngine.cpp | 8 KB | |
| Conformal3.cpp | 8 KB | No header (internal?) |
| DMS.cpp | 20 KB | |
| Ellipsoid3.cpp | 4 KB | No header (internal?) |
| GeoCoords.cpp | 8 KB | |
| Geodesic3.cpp | 76 KB | No header (internal?) |
| GeodesicLine3.cpp | 68 KB | No header (internal?) - modified for R |
| Geoid.cpp | 28 KB | |
| GravityCircle.cpp | 4 KB | |
| GravityModel.cpp | 20 KB | |
| Intersect.cpp | 20 KB | |
| MagneticCircle.cpp | 4 KB | |
| MagneticModel.cpp | 16 KB | |
| NormalGravity.cpp | 12 KB | |
| PolarStereographic.cpp | 4 KB | |
| SphericalEngine.cpp | 32 KB | |
| Trigfun.cpp | 16 KB | Uses kissfft.hpp |
| Utility.cpp | 8 KB | |

## Notes

### Files We Cannot Remove

Some "unused" files may still be compiled but just not exposed in R:

1. **GeodesicLine3.cpp** - We modified this file to remove `cout` statements. It may be used internally by GeodesicExact.
2. **Trigfun.cpp** - Uses kissfft.hpp which we renamed. May be used by DST.cpp.
3. **Geodesic3.cpp, Cartesian3.cpp, Conformal3.cpp, Ellipsoid3.cpp** - These appear to be internal implementation files.

### Potential for Removal

The following could likely be safely removed (they require external data files or provide functionality we don't wrap):

- **Geoid.cpp/hpp** - Requires geoid data files
- **GravityModel.cpp/hpp, GravityCircle.cpp/hpp** - Requires gravity model data files  
- **MagneticModel.cpp/hpp, MagneticCircle.cpp/hpp** - Requires magnetic model data files
- **SphericalEngine.cpp/hpp, SphericalHarmonic*.hpp** - Used by gravity/magnetic models
- **NormalGravity.cpp/hpp** - Gravity calculations
- **CircularEngine.cpp/hpp** - Spherical harmonic evaluation

### Features We Could Add

These unused files represent features we could expose if desired:

1. **AlbersEqualArea** - Equal-area conic projection
2. **DMS** - Parse/format degrees-minutes-seconds strings
3. **GeoCoords** - Unified coordinate class (MGRS/UTM/lat-lon)
4. **Intersect** - Find intersection of geodesics
5. **NearestNeighbor** - Efficient nearest neighbor search
6. **PolarStereographic** - Direct access (currently via UTMUPS)

## Recommendations

1. **Keep all files for now** - The unused files don't significantly impact the installed package size (only source tarball)
2. **Consider removing** Geoid, GravityModel, MagneticModel if package size becomes an issue
3. **Future features**: Intersect (geodesic intersections) and DMS (parsing) would be useful additions
