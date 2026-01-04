#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <GeographicLib/GeoCoords.hpp>
#include <GeographicLib/Constants.hpp>

using namespace std;
using namespace GeographicLib;

// Parse coordinate strings in various formats
[[cpp11::register]]
cpp11::writable::data_frame geocoords_parse_cpp(cpp11::strings x) {
  R_xlen_t nn = x.size();

  writable::doubles lat(nn);
  writable::doubles lon(nn);
  writable::integers zone(nn);
  writable::logicals northp(nn);
  writable::doubles easting(nn);
  writable::doubles northing(nn);

  for (R_xlen_t i = 0; i < nn; i++) {
    if (x[i] == NA_STRING) {
      lat[i] = NA_REAL;
      lon[i] = NA_REAL;
      zone[i] = NA_INTEGER;
      northp[i] = NA_LOGICAL;
      easting[i] = NA_REAL;
      northing[i] = NA_REAL;
      continue;
    }

    try {
      string str(x[i]);
      GeoCoords gc(str);

      lat[i] = gc.Latitude();
      lon[i] = gc.Longitude();
      zone[i] = gc.Zone();
      northp[i] = gc.Northp() ? TRUE : FALSE;
      easting[i] = gc.Easting();
      northing[i] = gc.Northing();
    } catch (...) {
      lat[i] = NA_REAL;
      lon[i] = NA_REAL;
      zone[i] = NA_INTEGER;
      northp[i] = NA_LOGICAL;
      easting[i] = NA_REAL;
      northing[i] = NA_REAL;
    }
  }

  writable::data_frame out({
    "lat"_nm = lat,
      "lon"_nm = lon,
      "zone"_nm = zone,
      "northp"_nm = northp,
      "easting"_nm = easting,
      "northing"_nm = northing
  });

  return out;
}
