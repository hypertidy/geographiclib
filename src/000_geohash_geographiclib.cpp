#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <string>
#include <GeographicLib/Geohash.hpp>

using namespace std;
using namespace GeographicLib;

// Forward: Geographic (lon/lat) to Geohash string
// Fully vectorized on coordinates and length
[[cpp11::register]]
cpp11::writable::strings geohash_fwd_cpp(cpp11::doubles lon, cpp11::doubles lat,
                                          cpp11::integers len) {
  size_t nn = lon.size();
  
  writable::strings geohash(nn);
  
  for (size_t i = 0; i < nn; i++) {
    string gh;
    Geohash::Forward(lat[i], lon[i], len[i], gh);
    geohash[i] = gh;
  }
  
  return geohash;
}

// Reverse: Geohash string to Geographic (lon/lat)
// Returns center point and resolution information
[[cpp11::register]]
cpp11::writable::data_frame geohash_rev_cpp(cpp11::strings geohash) {
  size_t nn = geohash.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::integers len(nn);
  writable::doubles lat_resolution(nn);
  writable::doubles lon_resolution(nn);
  
  for (size_t i = 0; i < nn; i++) {
    double la, lo, lat_res, lon_res;
    int length;
    
    Geohash::Reverse(geohash[i], la, lo, length);
    Geohash::Resolution(length, lat_res, lon_res);
    
    lon[i] = lo;
    lat[i] = la;
    len[i] = length;
    lat_resolution[i] = lat_res;
    lon_resolution[i] = lon_res;
  }
  
  writable::data_frame out({
    "lon"_nm = lon,
    "lat"_nm = lat,
    "len"_nm = len,
    "lat_resolution"_nm = lat_resolution,
    "lon_resolution"_nm = lon_resolution
  });
  
  return out;
}

// Get resolution (precision) for a given geohash length
[[cpp11::register]]
cpp11::writable::data_frame geohash_resolution_cpp(cpp11::integers len) {
  size_t nn = len.size();
  
  writable::doubles lat_resolution(nn);
  writable::doubles lon_resolution(nn);
  
  for (size_t i = 0; i < nn; i++) {
    double lat_res, lon_res;
    Geohash::Resolution(len[i], lat_res, lon_res);
    lat_resolution[i] = lat_res;
    lon_resolution[i] = lon_res;
  }
  
  writable::data_frame out({
    "len"_nm = len,
    "lat_resolution"_nm = lat_resolution,
    "lon_resolution"_nm = lon_resolution
  });
  
  return out;
}

// Get minimum length needed to achieve given precision
[[cpp11::register]]
int geohash_length_for_precision_cpp(double resolution) {
  return Geohash::GeohashLength(resolution);
}

// Get minimum length needed for given lat/lon precisions
[[cpp11::register]]
int geohash_length_for_precisions_cpp(double lat_resolution, double lon_resolution) {
  return Geohash::GeohashLength(lat_resolution, lon_resolution);
}
