#ifndef SRC_GEOGRAPHICLIB_H
#define SRC_GEOGRAPHICLIB_H

#include "rcpputil.h"
#include <GeographicLib/UTMUPS.hpp>
#include <GeographicLib/MGRS.hpp>

using namespace std;
using namespace GeographicLib;
using namespace Rcpp;
class GeogMGRS{
 public:
  GeogMGRS() {}
   //just experimenting
   void Forward (int zone, bool northp, double x, double y, int prec, std::string &mgrs) const;

  Rcpp::DataFrame utmups(Rcpp::NumericVector lon, Rcpp::NumericVector lat) const;
  std::vector<string> mgrs0(double lon, double lat, int precision) const;
  Rcpp::CharacterVector mgrs(Rcpp::NumericVector lon, Rcpp::NumericVector lat, Rcpp::IntegerVector precision) const;
 private:

};


RCPP_EXPOSED_CLASS(GeogMGRS)

#endif // SRC_GEOGRAPHICLIB_H
