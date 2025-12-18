#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

//// https://geographiclib.sourceforge.io/C++/doc/classGeographicLib_1_1MGRS.html
#include <string>
#include <GeographicLib/UTMUPS.hpp>
#include <GeographicLib/MGRS.hpp>

using namespace std;
using namespace GeographicLib;


string mgrs_fwd0(double lon, double lat, int precision) {
  // Sample forward calculation
  //double lat = -42.881, lon = 147.325; // nipaluna
  int zone;
  bool northp;
  double x, y;
  UTMUPS::Forward(lat, lon, zone, northp, x, y);
  string mgrs;
  MGRS::Forward(zone, northp, x, y, lat, precision, mgrs);
  return mgrs;
}
[[cpp11::register]]
cpp11::strings mgrs_fwd_cpp(cpp11::doubles lon, cpp11::doubles lat, cpp11::integers precision) {
  size_t nn = lon.size();
  int zone;
  bool northp;
  double x, y;
  string mgrs;
  writable::strings out(nn);
  for (size_t i = 0; i < nn; i++) {
   UTMUPS::Forward(lat[i], lon[i], zone, northp, x, y);
    MGRS::Forward(zone, northp, x, y, lat[i], precision[i], mgrs);
    out[i] = mgrs;
  }
 return out;
}

[[cpp11::register]]
cpp11::writable::data_frame mgrs_rev_cpp(cpp11::strings mgrs) {
  size_t nn = mgrs.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::doubles x(nn);
  writable::doubles y(nn);
  writable::integers zone(nn);
  writable::logicals northp(nn);
  writable::integers precision(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  writable::strings grid_zone(nn);
  writable::strings square_100km(nn);
  writable::strings crs(nn);
  
  for (size_t i = 0; i < nn; i++) {
    int z, prec;
    bool np;
    double xx, yy, la, lo, gamma, k;
    string gridzone, block, easting, northing;
    
    // Reverse MGRS to UTM/UPS coordinates
    MGRS::Reverse(mgrs[i], z, np, xx, yy, prec);
    
    // Decode MGRS components
    MGRS::Decode(mgrs[i], gridzone, block, easting, northing);
    
    // Reverse to geographic with convergence and scale
    UTMUPS::Reverse(z, np, xx, yy, la, lo, gamma, k);
    
    lon[i] = lo;
    lat[i] = la;
    x[i] = xx;
    y[i] = yy;
    zone[i] = z;
    northp[i] = np;
    precision[i] = prec;
    convergence[i] = gamma;
    scale[i] = k;
    grid_zone[i] = gridzone;
    square_100km[i] = block;
    
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
    "precision"_nm = precision,
    "convergence"_nm = convergence,
    "scale"_nm = scale,
    "grid_zone"_nm = grid_zone,
    "square_100km"_nm = square_100km,
    "crs"_nm = crs
  });
  
  return out;
}


[[cpp11::register]]
cpp11::strings mgrs_decode_cpp(cpp11::strings mgrs) {
  string gridzone, block, easting, northing;
  MGRS::Decode(mgrs[0], gridzone, block, easting, northing);
  writable::strings out(4);
  out[0] = gridzone;
  out[1] = block;
  out[2] = easting;
  out[3] = northing;
  out.names() = {"gridzone", "block", "easting", "northing"};
  return out;
}


