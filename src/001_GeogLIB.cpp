# include <R.h>
# include <Rinternals.h>

#include <GeographicLib/UTMUPS.hpp>
#include <GeographicLib/MGRS.hpp>

using namespace std;
using namespace GeographicLib;

SEXP utmups(SEXP lon, SEXP lat) {
  R_xlen_t nn = LENGTH(lon);

  const char *names[] = {"x", "y", "zone", "northp", ""};

  // dataframe output
  SEXP out = PROTECT(Rf_mkNamed(VECSXP, names));
  //const char *classnames[] = {"tbl_df", "tbl", "data.frame"};
  SEXP classnames = PROTECT(Rf_allocVector(STRSXP, 3));
  SET_STRING_ELT(classnames, 0, Rf_mkChar("tbl_df"));
  SET_STRING_ELT(classnames, 1, Rf_mkChar("tbl"));
  SET_STRING_ELT(classnames, 2, Rf_mkChar("data.frame"));
  Rf_setAttrib(out, R_ClassSymbol, classnames);

  // member columns of out dataframe
  SEXP x_ = PROTECT(Rf_allocVector(REALSXP, nn));
  SEXP y_ = PROTECT(Rf_allocVector(REALSXP, nn));
  SEXP zone_ = PROTECT(Rf_allocVector(INTSXP, nn));
  SEXP northp_ = PROTECT(Rf_allocVector(LGLSXP, nn));

  // variables for UTMUPS to write to in loop
  int zone;
  bool northp;
  double x, y;

  // save the index for efficiency of macro
  double* plon = REAL(lon);
  double* plat = REAL(lat);
  double* px = REAL(x_);
  double* py = REAL(y_);
  int* pzone = INTEGER(zone_);
  int* pnorthp = LOGICAL(northp_);

  for (R_xlen_t i = 0; i < nn; i++) {
   UTMUPS::Forward(plat[i], plon[i], zone, northp, x, y);
   px[i] = x;
   py[i] = y;
   pzone[i] = zone;
   pnorthp[i] = northp;
  }

  SET_VECTOR_ELT(out, 0, x_);
  SET_VECTOR_ELT(out, 0, y_);
  SET_VECTOR_ELT(out, 0, zone_);
  SET_VECTOR_ELT(out, 0, northp_);

  UNPROTECT(6);
  return out;
}
