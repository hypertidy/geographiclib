#ifndef SRC_GEOGRAPHICLIB_H
#define SRC_GEOGRAPHICLIB_H

#include "rcpputil.h"
#include <GeographicLib/UTMUPS.hpp>
#include <GeographicLib/MGRS.hpp>

using namespace std;
using namespace GeographicLib;

class GeogMGRS{
 public:
   GeogMGRS() {}
  std::vector<double> forward(double lon, double lat) const;

   std::vector<string> mgrs(double lon, double lat, int precision) const;

 private:

};

RCPP_EXPOSED_CLASS(GeogMGRS)

#endif // SRC_GEOGRAPHICLIB_H
