#include "000_GeogLIB.h"


std::vector<double> GeogMGRS::forward(double lon, double lat) const {
 int zone;
  bool northp;
  double x, y;
  UTMUPS::Forward(lat, lon, zone, northp, x, y);
  std::vector<double> out(2);
  out[0] = x;
  out[1] = y;
  return out;
}

std::vector<string> GeogMGRS::mgrs(double lon, double lat, int precision) const {
  int zone;
  bool northp;
  double x, y;
  UTMUPS::Forward(lat, lon, zone, northp, x, y);
  string mgrs;
  MGRS::Forward(zone, northp, x, y, lat, precision, mgrs);
  std::vector<string> out(1);
  out[0] = mgrs;
  return out;
}

// ****************************************************************************

RCPP_MODULE(mod_GeogMGRS) {
  Rcpp::class_<GeogMGRS>("GeogMGRS")

  .constructor
       ("Default constructor")
  .const_method("forward", &GeogMGRS::forward,
"Generate UTMUPS coord from lon,lat")

  .const_method("mgrs", &GeogMGRS::mgrs,
  "Generate UTMUPS coord from lon,lat")
  ;
}
