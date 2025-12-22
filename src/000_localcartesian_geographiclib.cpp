#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <GeographicLib/LocalCartesian.hpp>
#include <GeographicLib/Geocentric.hpp>
#include <GeographicLib/Constants.hpp>

using namespace std;
using namespace GeographicLib;

// Forward: Geographic (lon/lat/h) to Local Cartesian (x/y/z) relative to origin
// x = east, y = north, z = up
[[cpp11::register]]
cpp11::writable::data_frame localcartesian_fwd_cpp(cpp11::doubles lon, cpp11::doubles lat, 
                                                    cpp11::doubles h,
                                                    double lon0, double lat0, double h0) {
  size_t nn = lon.size();
  
  writable::doubles x(nn);
  writable::doubles y(nn);
  writable::doubles z(nn);
  
  // Create local cartesian coordinate system centered at origin
  const Geocentric& earth = Geocentric::WGS84();
  LocalCartesian lc(lat0, lon0, h0, earth);
  
  for (size_t i = 0; i < nn; i++) {
    double xx, yy, zz;
    lc.Forward(lat[i], lon[i], h[i], xx, yy, zz);
    
    x[i] = xx;
    y[i] = yy;
    z[i] = zz;
  }
  
  writable::data_frame out({
    "x"_nm = x,
    "y"_nm = y,
    "z"_nm = z,
    "lon"_nm = lon,
    "lat"_nm = lat,
    "h"_nm = h
  });
  
  return out;
}

// Reverse: Local Cartesian (x/y/z) to Geographic (lon/lat/h)
[[cpp11::register]]
cpp11::writable::data_frame localcartesian_rev_cpp(cpp11::doubles x, cpp11::doubles y, 
                                                    cpp11::doubles z,
                                                    double lon0, double lat0, double h0) {
  size_t nn = x.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::doubles h(nn);
  
  const Geocentric& earth = Geocentric::WGS84();
  LocalCartesian lc(lat0, lon0, h0, earth);
  
  for (size_t i = 0; i < nn; i++) {
    double la, lo, hh;
    lc.Reverse(x[i], y[i], z[i], la, lo, hh);
    
    lon[i] = lo;
    lat[i] = la;
    h[i] = hh;
  }
  
  writable::data_frame out({
    "lon"_nm = lon,
    "lat"_nm = lat,
    "h"_nm = h,
    "x"_nm = x,
    "y"_nm = y,
    "z"_nm = z
  });
  
  return out;
}
