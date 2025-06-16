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
cpp11::doubles mgrs_rev_cpp(cpp11::strings mgrs) {
  // reverse calculation

  int zone, prec;
  bool northp;
  double x, y;
  MGRS::Reverse(mgrs[0], zone, northp, x, y, prec);
  double lat, lon;
  UTMUPS::Reverse(zone, northp, x, y, lat, lon);

  writable::doubles out(6);
  out[0] = lon;
  out[1] = lat;
  out[2] = x;
  out[3] = y;
  out[4] = zone;
  out[5] = northp;
  out.names() = {"lon", "lat", "x", "y", "zone", "northp"};
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
