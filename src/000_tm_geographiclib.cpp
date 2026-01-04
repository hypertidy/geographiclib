#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <GeographicLib/TransverseMercator.hpp>
#include <GeographicLib/TransverseMercatorExact.hpp>
#include <GeographicLib/Constants.hpp>

using namespace std;
using namespace GeographicLib;

// Forward: Geographic (lon/lat) to Transverse Mercator (x/y)
// Uses series approximation (fast, accurate to ~5 nm)
[[cpp11::register]]
cpp11::writable::data_frame tm_fwd_cpp(cpp11::doubles lon, cpp11::doubles lat,
                                        cpp11::doubles lon0, double k0) {
  size_t nn = lon.size();
  
  writable::doubles x(nn);
  writable::doubles y(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  const TransverseMercator& tm = TransverseMercator::UTM();
  
  for (size_t i = 0; i < nn; i++) {
    double xx, yy, gamma, k;
    tm.Forward(lon0[i], lat[i], lon[i], xx, yy, gamma, k);
    
    // Apply custom scale factor
    x[i] = xx * k0;
    y[i] = yy * k0;
    convergence[i] = gamma;
    scale[i] = k * k0;
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

// Reverse: Transverse Mercator (x/y) to Geographic (lon/lat)
[[cpp11::register]]
cpp11::writable::data_frame tm_rev_cpp(cpp11::doubles x, cpp11::doubles y,
                                        cpp11::doubles lon0, double k0) {
  size_t nn = x.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  const TransverseMercator& tm = TransverseMercator::UTM();
  
  for (size_t i = 0; i < nn; i++) {
    double la, lo, gamma, k;
    // Undo custom scale factor before reverse
    tm.Reverse(lon0[i], x[i] / k0, y[i] / k0, la, lo, gamma, k);
    
    lon[i] = lo;
    lat[i] = la;
    convergence[i] = gamma;
    scale[i] = k * k0;
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

// Forward: Geographic (lon/lat) to Transverse Mercator Exact (x/y)
// Uses exact formulation (slower, but accurate everywhere)
[[cpp11::register]]
cpp11::writable::data_frame tm_exact_fwd_cpp(cpp11::doubles lon, cpp11::doubles lat,
                                              cpp11::doubles lon0, double k0) {
  size_t nn = lon.size();
  
  writable::doubles x(nn);
  writable::doubles y(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  const TransverseMercatorExact& tm = TransverseMercatorExact::UTM();
  
  for (size_t i = 0; i < nn; i++) {
    double xx, yy, gamma, k;
    tm.Forward(lon0[i], lat[i], lon[i], xx, yy, gamma, k);
    
    x[i] = xx * k0;
    y[i] = yy * k0;
    convergence[i] = gamma;
    scale[i] = k * k0;
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

// Reverse: Transverse Mercator Exact (x/y) to Geographic (lon/lat)
[[cpp11::register]]
cpp11::writable::data_frame tm_exact_rev_cpp(cpp11::doubles x, cpp11::doubles y,
                                              cpp11::doubles lon0, double k0) {
  size_t nn = x.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  const TransverseMercatorExact& tm = TransverseMercatorExact::UTM();
  
  for (size_t i = 0; i < nn; i++) {
    double la, lo, gamma, k;
    tm.Reverse(lon0[i], x[i] / k0, y[i] / k0, la, lo, gamma, k);
    
    lon[i] = lo;
    lat[i] = la;
    convergence[i] = gamma;
    scale[i] = k * k0;
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
