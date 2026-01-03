#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <GeographicLib/AzimuthalEquidistant.hpp>
#include <GeographicLib/Geodesic.hpp>

using namespace std;
using namespace GeographicLib;

// Forward: Geographic (lon/lat) to Azimuthal Equidistant (x/y)
// Vectorized on lon, lat, lon0, lat0
[[cpp11::register]]
cpp11::writable::data_frame azimuthaleq_fwd_cpp(cpp11::doubles lon, cpp11::doubles lat,
                                                 cpp11::doubles lon0, cpp11::doubles lat0) {
  size_t nn = lon.size();
  
  writable::doubles x(nn);
  writable::doubles y(nn);
  writable::doubles azi(nn);
  writable::doubles rk(nn);
  
  const Geodesic& geod = Geodesic::WGS84();
  AzimuthalEquidistant proj(geod);
  
  for (size_t i = 0; i < nn; i++) {
    double xx, yy, azz, rkk;
    proj.Forward(lat0[i], lon0[i], lat[i], lon[i], xx, yy, azz, rkk);
    x[i] = xx;
    y[i] = yy;
    azi[i] = azz;
    rk[i] = rkk;
  }
  
  writable::data_frame out({
    "x"_nm = x,
    "y"_nm = y,
    "azi"_nm = azi,
    "scale"_nm = rk,
    "lon"_nm = lon,
    "lat"_nm = lat,
    "lon0"_nm = lon0,
    "lat0"_nm = lat0
  });
  
  return out;
}

// Reverse: Azimuthal Equidistant (x/y) to Geographic (lon/lat)
// Vectorized on x, y, lon0, lat0
[[cpp11::register]]
cpp11::writable::data_frame azimuthaleq_rev_cpp(cpp11::doubles x, cpp11::doubles y,
                                                 cpp11::doubles lon0, cpp11::doubles lat0) {
  size_t nn = x.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::doubles azi(nn);
  writable::doubles rk(nn);
  
  const Geodesic& geod = Geodesic::WGS84();
  AzimuthalEquidistant proj(geod);
  
  for (size_t i = 0; i < nn; i++) {
    double la, lo, azz, rkk;
    proj.Reverse(lat0[i], lon0[i], x[i], y[i], la, lo, azz, rkk);
    lon[i] = lo;
    lat[i] = la;
    azi[i] = azz;
    rk[i] = rkk;
  }
  
  writable::data_frame out({
    "lon"_nm = lon,
    "lat"_nm = lat,
    "azi"_nm = azi,
    "scale"_nm = rk,
    "x"_nm = x,
    "y"_nm = y,
    "lon0"_nm = lon0,
    "lat0"_nm = lat0
  });
  
  return out;
}
