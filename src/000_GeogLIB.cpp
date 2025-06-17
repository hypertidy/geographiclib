#include "000_GeogLIB.h"

Rcpp::DataFrame GeogMGRS::utmups(Rcpp::NumericVector lon, Rcpp::NumericVector lat) const {
  int zone;
  bool northp;
  double x, y;
  size_t nn = lon.size();
  Rcpp::NumericVector x_(nn);
  Rcpp::NumericVector y_(nn);
  Rcpp::LogicalVector northp_(nn);
  Rcpp::IntegerVector zone_(nn);
  for (size_t i = 0; i < nn; i++) {
    UTMUPS::Forward(lat[i], lon[i], zone, northp, x, y);
    x_[i] = x;
    y_[i] = y;
    zone_[i] = zone;
    northp_[i] = northp;
  }
  DataFrame df = DataFrame::create( Named("x") = x_, _["y"] = y_, _["zone"] = zone_, _["northp"] = northp_);
  df.attr("class") = Rcpp::CharacterVector::create("tbl_df", "tbl", "data.frame");
  return df;
}

std::vector<string> GeogMGRS::mgrs0(double lon, double lat, int precision) const {
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

// we have a problem here with precision not having a default and not being vectorized
// x <- new(GeogMGRS); x$mgrs(c(147, 0), c(-42, 0), c(0, 5)); # [1] "55GEP"           "31NAA6602100000"
Rcpp::CharacterVector GeogMGRS::mgrs(Rcpp::NumericVector lon, Rcpp::NumericVector lat, Rcpp::IntegerVector precision) const {
  int zone;
  bool northp;
  double x, y;
  string mgrs;
  size_t nn = lon.size();
  Rcpp::NumericVector x_(nn);
  Rcpp::NumericVector y_(nn);
  CharacterVector mgrs_(nn);
  for (size_t i = 0; i < nn; i++) {
    UTMUPS::Forward(lat[i], lon[i], zone, northp, x, y);
    MGRS::Forward(zone, northp, x, y, lat[i], precision[i], mgrs);
    mgrs_[i] = mgrs;
  }

  return mgrs_;
}

// just experimenting
void GeogMGRS::Forward(int zone, bool northp, double x, double y, int prec, std::string &mgrs) const {
  MGRS::Forward(zone, northp, x, y, 0, prec, mgrs);

}

// ****************************************************************************

RCPP_MODULE(mod_GeogMGRS) {
  Rcpp::class_<GeogMGRS>("GeogMGRS")

  .constructor
       ("Default constructor")
  .const_method("Forward", &GeogMGRS::Forward, "forward")

  .const_method("utmups", &GeogMGRS::utmups,
"Generate UTMUPS coord from lon,lat, returns x,y,zone,northp in a dataframe")
  .const_method("mgrs0", &GeogMGRS::mgrs,
"Generate UTMUPS coordinate (single) from lon,lat")
  .const_method("mgrs", &GeogMGRS::mgrs,
  "Generate UTMUPS coordinates from lon,lat[,precision]")
  ;
}
