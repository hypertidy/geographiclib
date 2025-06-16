#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

//// https://geographiclib.sourceforge.io/C++/doc/classGeographicLib_1_1MGRS.html
#include <string>
#include <GeographicLib/UTMUPS.hpp>
#include <GeographicLib/MGRS.hpp>

using namespace std;
using namespace GeographicLib;
[[cpp11::register]]
cpp11::strings mgrs_fwd_cpp(cpp11::doubles ll) {

  // Sample forward calculation
  //double lat = -42.881, lon = 147.325; // nipaluna
  double lon = ll[0];
  double lat = ll[1];
  int zone;
  bool northp;
  double x, y;
  UTMUPS::Forward(lat, lon, zone, northp, x, y);
  string mgrs;
  MGRS::Forward(zone, northp, x, y, lat, 5, mgrs);

  writable::strings out(1);
  out[0] = mgrs;
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
