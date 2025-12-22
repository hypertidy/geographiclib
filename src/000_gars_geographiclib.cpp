#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <string>
#include <GeographicLib/GARS.hpp>

using namespace std;
using namespace GeographicLib;

// Forward: Geographic (lon/lat) to GARS code
[[cpp11::register]]
cpp11::writable::strings gars_fwd_cpp(cpp11::doubles lon, cpp11::doubles lat,
                                       cpp11::integers precision) {
  size_t nn = lon.size();
  
  writable::strings gars(nn);
  
  for (size_t i = 0; i < nn; i++) {
    string code;
    GARS::Forward(lat[i], lon[i], precision[i], code);
    gars[i] = code;
  }
  
  return gars;
}

// Reverse: GARS code to Geographic (lon/lat)
[[cpp11::register]]
cpp11::writable::data_frame gars_rev_cpp(cpp11::strings gars) {
  size_t nn = gars.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::integers precision(nn);
  writable::doubles lat_resolution(nn);
  writable::doubles lon_resolution(nn);
  
  for (size_t i = 0; i < nn; i++) {
    double la, lo;
    int prec;
    
    std::string code(gars[i]);
    GARS::Reverse(code, la, lo, prec);
    
    lon[i] = lo;
    lat[i] = la;
    precision[i] = prec;
    
    // Calculate resolution based on precision
    // GARS: precision 0 = 30', precision 1 = 15', precision 2 = 5'
    double res;
    if (prec == 0) {
      res = 0.5;  // 30 minutes = 0.5 degrees
    } else if (prec == 1) {
      res = 0.25; // 15 minutes = 0.25 degrees
    } else {
      res = 5.0 / 60.0; // 5 minutes
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
