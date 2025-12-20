#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <string>
#include <GeographicLib/UTMUPS.hpp>

using namespace std;
using namespace GeographicLib;

// Forward: Geographic (lon/lat) to UTM/UPS (x/y)
[[cpp11::register]]
cpp11::writable::data_frame utmups_fwd_cpp(cpp11::doubles lon, cpp11::doubles lat) {
  size_t nn = lon.size();
  
  writable::doubles x(nn);
  writable::doubles y(nn);
  writable::integers zone(nn);
  writable::logicals northp(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  writable::strings crs(nn);
  
  for (size_t i = 0; i < nn; i++) {
    int z;
    bool np;
    double xx, yy, gamma, k;
    
    // Forward to UTM/UPS with convergence and scale
    UTMUPS::Forward(lat[i], lon[i], z, np, xx, yy, gamma, k);
    
    x[i] = xx;
    y[i] = yy;
    zone[i] = z;
    northp[i] = np;
    convergence[i] = gamma;
    scale[i] = k;
    
    // Build CRS string
    string crs_str;
    if (z == 0) {
      // Polar zones: UPS North (32661) or UPS South (32761)
      crs_str = np ? "EPSG:32661" : "EPSG:32761";
    } else {
      // Standard UTM zones: EPSG:326XX (north) or EPSG:327XX (south)
      int hemi_code = np ? 6 : 7;
      crs_str = "EPSG:32" + to_string(hemi_code) + (z < 10 ? "0" : "") + to_string(z);
    }
    crs[i] = crs_str;
  }
  
  writable::data_frame out({
    "x"_nm = x,
    "y"_nm = y,
    "zone"_nm = zone,
    "northp"_nm = northp,
    "convergence"_nm = convergence,
    "scale"_nm = scale,
    "lon"_nm = lon,
    "lat"_nm = lat,
    "crs"_nm = crs
  });
  
  return out;
}

// Reverse: UTM/UPS (x/y/zone/northp) to Geographic (lon/lat)
[[cpp11::register]]
cpp11::writable::data_frame utmups_rev_cpp(cpp11::doubles x, cpp11::doubles y, 
                                            cpp11::integers zone, cpp11::logicals northp) {
  size_t nn = x.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  writable::strings crs(nn);
  
  for (size_t i = 0; i < nn; i++) {
    double la, lo, gamma, k;
    int z = zone[i];
    bool np = northp[i];
    
    // Reverse to geographic with convergence and scale
    UTMUPS::Reverse(z, np, x[i], y[i], la, lo, gamma, k);
    
    lon[i] = lo;
    lat[i] = la;
    convergence[i] = gamma;
    scale[i] = k;
    
    // Build CRS string
    string crs_str;
    if (z == 0) {
      // Polar zones: UPS North (32661) or UPS South (32761)
      crs_str = np ? "EPSG:32661" : "EPSG:32761";
    } else {
      // Standard UTM zones: EPSG:326XX (north) or EPSG:327XX (south)
      int hemi_code = np ? 6 : 7;
      crs_str = "EPSG:32" + to_string(hemi_code) + (z < 10 ? "0" : "") + to_string(z);
    }
    crs[i] = crs_str;
  }
  
  writable::data_frame out({
    "lon"_nm = lon,
    "lat"_nm = lat,
    "x"_nm = x,
    "y"_nm = y,
    "zone"_nm = zone,
    "northp"_nm = northp,
    "convergence"_nm = convergence,
    "scale"_nm = scale,
    "crs"_nm = crs
  });
  
  return out;
}