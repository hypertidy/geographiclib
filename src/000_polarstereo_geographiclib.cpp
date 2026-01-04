#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <GeographicLib/PolarStereographic.hpp>
#include <GeographicLib/Constants.hpp>

using namespace std;
using namespace GeographicLib;

// Forward: Geographic (lon/lat) to Polar Stereographic (x/y)
[[cpp11::register]]
cpp11::writable::data_frame polarstereo_fwd_cpp(cpp11::doubles lon, cpp11::doubles lat,
                                                 cpp11::logicals northp, double k0) {
  size_t nn = lon.size();
  
  writable::doubles x(nn);
  writable::doubles y(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  const PolarStereographic& ps = PolarStereographic::UPS();
  
  for (size_t i = 0; i < nn; i++) {
    double xx, yy, gamma, k;
    ps.Forward(northp[i], lat[i], lon[i], xx, yy, gamma, k);
    
    // Apply custom scale factor (UPS uses 0.994)
    x[i] = xx * k0 / 0.994;
    y[i] = yy * k0 / 0.994;
    convergence[i] = gamma;
    scale[i] = k * k0 / 0.994;
  }
  
  writable::data_frame out({
    "x"_nm = x,
    "y"_nm = y,
    "convergence"_nm = convergence,
    "scale"_nm = scale,
    "lon"_nm = lon,
    "lat"_nm = lat,
    "northp"_nm = northp
  });
  
  return out;
}

// Reverse: Polar Stereographic (x/y) to Geographic (lon/lat)
[[cpp11::register]]
cpp11::writable::data_frame polarstereo_rev_cpp(cpp11::doubles x, cpp11::doubles y,
                                                 cpp11::logicals northp, double k0) {
  size_t nn = x.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  const PolarStereographic& ps = PolarStereographic::UPS();
  
  for (size_t i = 0; i < nn; i++) {
    double la, lo, gamma, k;
    // Undo custom scale factor
    ps.Reverse(northp[i], x[i] * 0.994 / k0, y[i] * 0.994 / k0, la, lo, gamma, k);
    
    lon[i] = lo;
    lat[i] = la;
    convergence[i] = gamma;
    scale[i] = k * k0 / 0.994;
  }
  
  writable::data_frame out({
    "lon"_nm = lon,
    "lat"_nm = lat,
    "convergence"_nm = convergence,
    "scale"_nm = scale,
    "x"_nm = x,
    "y"_nm = y,
    "northp"_nm = northp
  });
  
  return out;
}

// Forward with custom parameters (not using UPS defaults)
[[cpp11::register]]
cpp11::writable::data_frame polarstereo_fwd_custom_cpp(cpp11::doubles lon, cpp11::doubles lat,
                                                        cpp11::logicals northp, double k0) {
  size_t nn = lon.size();
  
  writable::doubles x(nn);
  writable::doubles y(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  // Create custom polar stereographic with specified scale
  const PolarStereographic ps(Constants::WGS84_a(), Constants::WGS84_f(), k0);
  
  for (size_t i = 0; i < nn; i++) {
    double xx, yy, gamma, k;
    ps.Forward(northp[i], lat[i], lon[i], xx, yy, gamma, k);
    
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
    "northp"_nm = northp
  });
  
  return out;
}

// Reverse with custom parameters
[[cpp11::register]]
cpp11::writable::data_frame polarstereo_rev_custom_cpp(cpp11::doubles x, cpp11::doubles y,
                                                        cpp11::logicals northp, double k0) {
  size_t nn = x.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  const PolarStereographic ps(Constants::WGS84_a(), Constants::WGS84_f(), k0);
  
  for (size_t i = 0; i < nn; i++) {
    double la, lo, gamma, k;
    ps.Reverse(northp[i], x[i], y[i], la, lo, gamma, k);
    
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
    "northp"_nm = northp
  });
  
  return out;
}
