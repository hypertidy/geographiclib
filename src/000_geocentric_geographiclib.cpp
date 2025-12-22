#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <GeographicLib/Geocentric.hpp>

using namespace std;
using namespace GeographicLib;

// Forward: Geographic (lon/lat/h) to Geocentric (X/Y/Z)
[[cpp11::register]]
cpp11::writable::data_frame geocentric_fwd_cpp(cpp11::doubles lon, cpp11::doubles lat,
                                                cpp11::doubles h) {
  size_t nn = lon.size();
  
  writable::doubles X(nn);
  writable::doubles Y(nn);
  writable::doubles Z(nn);
  
  const Geocentric& earth = Geocentric::WGS84();
  
  for (size_t i = 0; i < nn; i++) {
    double xx, yy, zz;
    earth.Forward(lat[i], lon[i], h[i], xx, yy, zz);
    X[i] = xx;
    Y[i] = yy;
    Z[i] = zz;
  }
  
  writable::data_frame out({
    "X"_nm = X,
    "Y"_nm = Y,
    "Z"_nm = Z,
    "lon"_nm = lon,
    "lat"_nm = lat,
    "h"_nm = h
  });
  
  return out;
}

// Reverse: Geocentric (X/Y/Z) to Geographic (lon/lat/h)
[[cpp11::register]]
cpp11::writable::data_frame geocentric_rev_cpp(cpp11::doubles X, cpp11::doubles Y,
                                                cpp11::doubles Z) {
  size_t nn = X.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::doubles h(nn);
  
  const Geocentric& earth = Geocentric::WGS84();
  
  for (size_t i = 0; i < nn; i++) {
    double la, lo, hh;
    earth.Reverse(X[i], Y[i], Z[i], la, lo, hh);
    lon[i] = lo;
    lat[i] = la;
    h[i] = hh;
  }
  
  writable::data_frame out({
    "lon"_nm = lon,
    "lat"_nm = lat,
    "h"_nm = h,
    "X"_nm = X,
    "Y"_nm = Y,
    "Z"_nm = Z
  });
  
  return out;
}
