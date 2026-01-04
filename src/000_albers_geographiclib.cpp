#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <GeographicLib/AlbersEqualArea.hpp>
#include <GeographicLib/Constants.hpp>

using namespace std;
using namespace GeographicLib;

// Forward: Geographic (lon/lat) to Albers Equal Area (x/y)
// Uses two standard parallels
[[cpp11::register]]
cpp11::writable::data_frame albers_fwd_cpp(cpp11::doubles lon, cpp11::doubles lat,
                                            cpp11::doubles lon0,
                                            double stdlat1, double stdlat2, double k1) {
  size_t nn = lon.size();
  
  writable::doubles x(nn);
  writable::doubles y(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  // Create Albers projection with two standard parallels
  const AlbersEqualArea albers(Constants::WGS84_a(), Constants::WGS84_f(),
                                stdlat1, stdlat2, k1);
  
  for (size_t i = 0; i < nn; i++) {
    double xx, yy, gamma, k;
    albers.Forward(lon0[i], lat[i], lon[i], xx, yy, gamma, k);
    
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
    "lat"_nm = lat,
    "lon0"_nm = lon0
  });
  
  return out;
}

// Reverse: Albers Equal Area (x/y) to Geographic (lon/lat)
[[cpp11::register]]
cpp11::writable::data_frame albers_rev_cpp(cpp11::doubles x, cpp11::doubles y,
                                            cpp11::doubles lon0,
                                            double stdlat1, double stdlat2, double k1) {
  size_t nn = x.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  const AlbersEqualArea albers(Constants::WGS84_a(), Constants::WGS84_f(),
                                stdlat1, stdlat2, k1);
  
  for (size_t i = 0; i < nn; i++) {
    double la, lo, gamma, k;
    albers.Reverse(lon0[i], x[i], y[i], la, lo, gamma, k);
    
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
    "y"_nm = y,
    "lon0"_nm = lon0
  });
  
  return out;
}

// Forward using single standard parallel (special case)
[[cpp11::register]]
cpp11::writable::data_frame albers_fwd_single_cpp(cpp11::doubles lon, cpp11::doubles lat,
                                                   cpp11::doubles lon0,
                                                   double stdlat, double k0) {
  size_t nn = lon.size();
  
  writable::doubles x(nn);
  writable::doubles y(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  // Single standard parallel
  const AlbersEqualArea albers(Constants::WGS84_a(), Constants::WGS84_f(),
                                stdlat, k0);
  
  for (size_t i = 0; i < nn; i++) {
    double xx, yy, gamma, k;
    albers.Forward(lon0[i], lat[i], lon[i], xx, yy, gamma, k);
    
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
    "lat"_nm = lat,
    "lon0"_nm = lon0
  });
  
  return out;
}

// Reverse using single standard parallel
[[cpp11::register]]
cpp11::writable::data_frame albers_rev_single_cpp(cpp11::doubles x, cpp11::doubles y,
                                                   cpp11::doubles lon0,
                                                   double stdlat, double k0) {
  size_t nn = x.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  const AlbersEqualArea albers(Constants::WGS84_a(), Constants::WGS84_f(),
                                stdlat, k0);
  
  for (size_t i = 0; i < nn; i++) {
    double la, lo, gamma, k;
    albers.Reverse(lon0[i], x[i], y[i], la, lo, gamma, k);
    
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
    "y"_nm = y,
    "lon0"_nm = lon0
  });
  
  return out;
}
