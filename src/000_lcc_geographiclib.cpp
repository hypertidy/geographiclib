#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <GeographicLib/LambertConformalConic.hpp>
#include <GeographicLib/Constants.hpp>

using namespace std;
using namespace GeographicLib;

// Forward: Geographic (lon/lat) to LCC (x/y)
// Uses a single standard parallel (tangent cone)
[[cpp11::register]]
cpp11::writable::data_frame lcc_fwd_cpp(cpp11::doubles lon, cpp11::doubles lat,
                                         double lon0, double lat0, double stdlat,
                                         double k0) {
  size_t nn = lon.size();
  
  writable::doubles x(nn);
  writable::doubles y(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  // Create LCC projection with single standard parallel
  const LambertConformalConic lcc(Constants::WGS84_a(), Constants::WGS84_f(), 
                                   stdlat, k0);
  
  for (size_t i = 0; i < nn; i++) {
    double xx, yy, gamma, k;
    lcc.Forward(lon0, lat[i], lon[i], xx, yy, gamma, k);
    
    x[i] = xx;
    y[i] = yy;
    convergence[i] = gamma;
    scale[i] = k;
  }
  
  writable::data_frame out({
    "x"_nm = x,
    "y"_nm = y,
    "convergence"_nm = convergence,
    "scale"_nm = scale,
    "lon"_nm = lon,
    "lat"_nm = lat
  });
  
  return out;
}

// Forward: Geographic (lon/lat) to LCC (x/y)
// Uses two standard parallels (secant cone)
[[cpp11::register]]
cpp11::writable::data_frame lcc_fwd2_cpp(cpp11::doubles lon, cpp11::doubles lat,
                                          double lon0, double lat0, 
                                          double stdlat1, double stdlat2,
                                          double k1) {
  size_t nn = lon.size();
  
  writable::doubles x(nn);
  writable::doubles y(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  // Create LCC projection with two standard parallels
  const LambertConformalConic lcc(Constants::WGS84_a(), Constants::WGS84_f(), 
                                   stdlat1, stdlat2, k1);
  
  for (size_t i = 0; i < nn; i++) {
    double xx, yy, gamma, k;
    lcc.Forward(lon0, lat[i], lon[i], xx, yy, gamma, k);
    
    x[i] = xx;
    y[i] = yy;
    convergence[i] = gamma;
    scale[i] = k;
  }
  
  writable::data_frame out({
    "x"_nm = x,
    "y"_nm = y,
    "convergence"_nm = convergence,
    "scale"_nm = scale,
    "lon"_nm = lon,
    "lat"_nm = lat
  });
  
  return out;
}

// Reverse: LCC (x/y) to Geographic (lon/lat)
// Uses a single standard parallel (tangent cone)
[[cpp11::register]]
cpp11::writable::data_frame lcc_rev_cpp(cpp11::doubles x, cpp11::doubles y,
                                         double lon0, double lat0, double stdlat,
                                         double k0) {
  size_t nn = x.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  // Create LCC projection with single standard parallel
  const LambertConformalConic lcc(Constants::WGS84_a(), Constants::WGS84_f(), 
                                   stdlat, k0);
  
  for (size_t i = 0; i < nn; i++) {
    double la, lo, gamma, k;
    lcc.Reverse(lon0, x[i], y[i], la, lo, gamma, k);
    
    lon[i] = lo;
    lat[i] = la;
    convergence[i] = gamma;
    scale[i] = k;
  }
  
  writable::data_frame out({
    "lon"_nm = lon,
    "lat"_nm = lat,
    "convergence"_nm = convergence,
    "scale"_nm = scale,
    "x"_nm = x,
    "y"_nm = y
  });
  
  return out;
}

// Reverse: LCC (x/y) to Geographic (lon/lat)
// Uses two standard parallels (secant cone)
[[cpp11::register]]
cpp11::writable::data_frame lcc_rev2_cpp(cpp11::doubles x, cpp11::doubles y,
                                          double lon0, double lat0,
                                          double stdlat1, double stdlat2,
                                          double k1) {
  size_t nn = x.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  // Create LCC projection with two standard parallels
  const LambertConformalConic lcc(Constants::WGS84_a(), Constants::WGS84_f(), 
                                   stdlat1, stdlat2, k1);
  
  for (size_t i = 0; i < nn; i++) {
    double la, lo, gamma, k;
    lcc.Reverse(lon0, x[i], y[i], la, lo, gamma, k);
    
    lon[i] = lo;
    lat[i] = la;
    convergence[i] = gamma;
    scale[i] = k;
  }
  
  writable::data_frame out({
    "lon"_nm = lon,
    "lat"_nm = lat,
    "convergence"_nm = convergence,
    "scale"_nm = scale,
    "x"_nm = x,
    "y"_nm = y
  });
  
  return out;
}
