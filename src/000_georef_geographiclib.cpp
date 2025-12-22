#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <string>
#include <GeographicLib/Georef.hpp>

using namespace std;
using namespace GeographicLib;

// Forward: Geographic (lon/lat) to Georef code
[[cpp11::register]]
cpp11::writable::strings georef_fwd_cpp(cpp11::doubles lon, cpp11::doubles lat,
                                         cpp11::integers precision) {
  size_t nn = lon.size();
  
  writable::strings georef(nn);
  
  for (size_t i = 0; i < nn; i++) {
    string code;
    Georef::Forward(lat[i], lon[i], precision[i], code);
    georef[i] = code;
  }
  
  return georef;
}

// Reverse: Georef code to Geographic (lon/lat)
[[cpp11::register]]
cpp11::writable::data_frame georef_rev_cpp(cpp11::strings georef) {
  size_t nn = georef.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::integers precision(nn);
  writable::doubles lat_resolution(nn);
  writable::doubles lon_resolution(nn);
  
  for (size_t i = 0; i < nn; i++) {
    double la, lo;
    int prec;
    
    std::string code(georef[i]);
    Georef::Reverse(code, la, lo, prec);
    
    lon[i] = lo;
    lat[i] = la;
    precision[i] = prec;
    
    // Calculate resolution: precision gives decimal places in minutes
    // prec -1 = 15 degrees, prec 0 = 1 degree, prec 1 = 1 minute, etc.
    double res;
    if (prec < 0) {
      res = 15.0;
    } else if (prec == 0) {
      res = 1.0;
    } else {
      // Each precision level is a power of 10 finer in minutes
      // prec 1 = 1 minute = 1/60 degrees
      // prec 2 = 0.1 minutes = 1/600 degrees
      // etc.
      double minutes = 1.0;
      for (int j = 1; j < prec; j++) {
        minutes /= 10.0;
      }
      res = minutes / 60.0;
    }
    lat_resolution[i] = res;
    lon_resolution[i] = res;
  }
  
  writable::data_frame out({
    "lon"_nm = lon,
    "lat"_nm = lat,
    "precision"_nm = precision,
    "lat_resolution"_nm = lat_resolution,
    "lon_resolution"_nm = lon_resolution
  });
  
  return out;
}
