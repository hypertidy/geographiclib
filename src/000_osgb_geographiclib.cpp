#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <string>
#include <GeographicLib/OSGB.hpp>

using namespace std;
using namespace GeographicLib;

// Forward: Geographic OSGB36 (lon/lat) to OSGB grid (easting/northing)
// Note: Input should be on OSGB36 datum, not WGS84
[[cpp11::register]]
cpp11::writable::data_frame osgb_fwd_cpp(cpp11::doubles lon, cpp11::doubles lat) {
  size_t nn = lon.size();
  
  writable::doubles easting(nn);
  writable::doubles northing(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  for (size_t i = 0; i < nn; i++) {
    double e, n, gamma, k;
    
    OSGB::Forward(lat[i], lon[i], e, n, gamma, k);
    
    easting[i] = e;
    northing[i] = n;
    convergence[i] = gamma;
    scale[i] = k;
  }
  
  writable::data_frame out({
    "easting"_nm = easting,
    "northing"_nm = northing,
    "convergence"_nm = convergence,
    "scale"_nm = scale,
    "lon"_nm = lon,
    "lat"_nm = lat
  });
  
  return out;
}

// Reverse: OSGB grid (easting/northing) to Geographic OSGB36 (lon/lat)
// Note: Output is on OSGB36 datum, not WGS84
[[cpp11::register]]
cpp11::writable::data_frame osgb_rev_cpp(cpp11::doubles easting, cpp11::doubles northing) {
  size_t nn = easting.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  for (size_t i = 0; i < nn; i++) {
    double la, lo, gamma, k;
    
    OSGB::Reverse(easting[i], northing[i], la, lo, gamma, k);
    
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
    "easting"_nm = easting,
    "northing"_nm = northing
  });
  
  return out;
}

// Forward to OSGB grid reference string
// Note: Input should be on OSGB36 datum
[[cpp11::register]]
cpp11::writable::strings osgb_gridref_cpp(cpp11::doubles lon, cpp11::doubles lat,
                                           cpp11::integers precision) {
  size_t nn = lon.size();
  
  writable::strings gridref(nn);
  
  for (size_t i = 0; i < nn; i++) {
    double e, n, gamma, k;
    
    // Forward to grid
    OSGB::Forward(lat[i], lon[i], e, n, gamma, k);
    
    // Convert to grid reference string
    string gr;
    OSGB::GridReference(e, n, precision[i], gr);
    gridref[i] = gr;
  }
  
  return gridref;
}

// Reverse from OSGB grid reference string
// Note: Output is on OSGB36 datum
[[cpp11::register]]
cpp11::writable::data_frame osgb_gridref_rev_cpp(cpp11::strings gridref) {
  size_t nn = gridref.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::doubles easting(nn);
  writable::doubles northing(nn);
  writable::integers precision(nn);
  
  for (size_t i = 0; i < nn; i++) {
    double e, n;
    int prec;
    
    // Parse grid reference
    std::string gr_str(gridref[i]);
    OSGB::GridReference(gr_str, e, n, prec);
    
    // Reverse to OSGB36
    double la, lo, gamma, k;
    OSGB::Reverse(e, n, la, lo, gamma, k);
    
    lon[i] = lo;
    lat[i] = la;
    easting[i] = e;
    northing[i] = n;
    precision[i] = prec;
  }
  
  writable::data_frame out({
    "lon"_nm = lon,
    "lat"_nm = lat,
    "easting"_nm = easting,
    "northing"_nm = northing,
    "precision"_nm = precision
  });
  
  return out;
}
