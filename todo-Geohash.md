# TODO: Add Geohash Support to geographiclib Package

## Overview

Geohash is a compact string representation of geographic coordinates with the useful property that truncating characters from the end maintains proximity to the original location. The GeographicLib `Geohash` class provides conversion functions between lat/lon and geohash strings.

## GeographicLib Geohash API

The `Geohash` class provides:

### Core Functions

1. **Forward** - Convert lat/lon to geohash string
   - Input: `lat`, `lon` (degrees), `len` (geohash length, 0-18)
   - Output: geohash string
   - Length 18 provides ~1μm precision

2. **Reverse** - Convert geohash string to lat/lon
   - Input: `geohash` string, `centerp` (bool, return center or SW corner)
   - Output: `lat`, `lon` (degrees), `len` (decoded length)

### Utility Functions

3. **LatitudeResolution(len)** - Get latitude resolution in degrees for a given geohash length
4. **LongitudeResolution(len)** - Get longitude resolution in degrees for a given geohash length
5. **GeohashLength(res)** - Get required geohash length for a given resolution
6. **GeohashLength(latres, lonres)** - Get required geohash length for given lat/lon resolutions
7. **DecimalPrecision(len)** - Get decimal digits needed to match geohash precision

## Implementation Steps

### 1. Create C++ Interface (src/000_geohash_geographiclib.cpp)

```cpp
#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <string>
#include <GeographicLib/Geohash.hpp>

using namespace std;
using namespace GeographicLib;

// Forward: lat/lon to geohash (vectorized)
[[cpp11::register]]
cpp11::writable::strings geohash_fwd_cpp(cpp11::doubles lon, cpp11::doubles lat, 
                                          cpp11::integers len);

// Reverse: geohash to lat/lon (vectorized)
[[cpp11::register]]
cpp11::writable::data_frame geohash_rev_cpp(cpp11::strings geohash, bool centerp);

// Resolution functions
[[cpp11::register]]
cpp11::writable::doubles geohash_lat_resolution_cpp(cpp11::integers len);

[[cpp11::register]]
cpp11::writable::doubles geohash_lon_resolution_cpp(cpp11::integers len);

[[cpp11::register]]
cpp11::writable::integers geohash_length_cpp(cpp11::doubles res);

[[cpp11::register]]
cpp11::writable::integers geohash_decimal_precision_cpp(cpp11::integers len);
```

### 2. Create R Wrappers (R/geohash.R)

Functions to implement:

- `geohash_fwd(x, len = 12)` - Forward conversion (vectorized)
- `geohash_rev(geohash, center = TRUE)` - Reverse conversion (vectorized)
- `geohash_resolution(len)` - Get lat/lon resolution for length
- `geohash_length(res)` - Get required length for resolution
- `geohash_precision(len)` - Get decimal precision for length

### 3. Return Values

**geohash_fwd()**: Character vector of geohash strings

**geohash_rev()**: Data frame with columns:
- `lon` - Longitude (degrees)
- `lat` - Latitude (degrees)
- `len` - Decoded geohash length
- `lat_res` - Latitude resolution (degrees)
- `lon_res` - Longitude resolution (degrees)

### 4. Create Tests (tests/testthat/test-geohash.R)

Test cases:
- [ ] Single point forward conversion
- [ ] Vectorized forward conversion
- [ ] Different geohash lengths (0-18)
- [ ] Reverse conversion returns correct structure
- [ ] Reverse conversion `centerp` parameter works
- [ ] Round-trip conversion accuracy
- [ ] Resolution functions return expected values
- [ ] Edge cases: poles, dateline, equator
- [ ] Invalid input handling
- [ ] Geohash truncation maintains proximity

### 5. Add Documentation (roxygen2)

- [ ] Document all exported functions
- [ ] Include examples showing:
  - Basic forward/reverse conversion
  - Variable precision levels
  - Resolution queries
  - Comparison with MGRS

### 6. Update README.Rmd

Add section:

```markdown
## Geohash - Compact Location Encoding

Geohash provides a compact string representation of coordinates where truncating
characters maintains proximity:

```{r geohash-example}
# Convert coordinates to geohash
geohash_fwd(c(-0.1, 51.5), len = 8)  # London

# Higher precision
geohash_fwd(c(-0.1, 51.5), len = 12)

# Reverse conversion
geohash_rev("gcpuvpm")

# Truncating maintains proximity
geohash_rev(c("gcpuvpme", "gcpuvpm", "gcpuv", "gcp"))
```

### Resolution by length

| Length | Lat Resolution | Lon Resolution | Approx. Error |
|--------|----------------|----------------|---------------|
| 1      | ±2500 km       | ±5000 km       | Global        |
| 4      | ±20 km         | ±20 km         | City          |
| 6      | ±610 m         | ±1.2 km        | Neighborhood  |
| 8      | ±19 m          | ±19 m          | Street        |
| 10     | ±0.6 m         | ±0.6 m         | Precise       |
| 12     | ±19 mm         | ±19 mm         | Survey        |
```

### 7. Update NAMESPACE

After implementing, run:
```r
cpp11::cpp_register()
devtools::document()
```

## Comparison with Existing Functions

| Feature | MGRS | Geohash |
|---------|------|---------|
| Character set | Alphanumeric | Base32 (lowercase) |
| Precision control | 0-5 levels | 1-18 characters |
| Truncation property | No | Yes (hierarchical) |
| Zone-based | Yes (UTM/UPS) | No (global grid) |
| Polar support | Yes (UPS) | Yes |

## Priority

Medium - Useful addition that complements MGRS with a different encoding scheme popular in web applications and databases (e.g., Elasticsearch, Redis).

## References

- https://en.wikipedia.org/wiki/Geohash
- http://geohash.org/
- GeographicLib documentation: https://geographiclib.sourceforge.io/C++/doc/classGeographicLib_1_1Geohash.html
