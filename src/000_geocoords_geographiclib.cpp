#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <string>
#include <GeographicLib/GeoCoords.hpp>

using namespace std;
using namespace GeographicLib;

// Parse coordinate string (MGRS, UTM, or lat/lon) and return all representations
[[cpp11::register]]
cpp11::writable::data_frame geocoords_parse_cpp(cpp11::strings input) {
  size_t nn = input.size();
  
  writable::doubles lat(nn);
  writable::doubles lon(nn);
  writable::integers zone(nn);
  writable::logicals northp(nn);
  writable::doubles easting(nn);
  writable::doubles northing(nn);
  writable::doubles convergence(nn);
  writable::doubles scale(nn);
  
  for (size_t i = 0; i < nn; i++) {
    try {
      std::string s(input[i]);
      GeoCoords gc(s);
      
      lat[i] = gc.Latitude();
      lon[i] = gc.Longitude();
      zone[i] = gc.Zone();
      northp[i] = gc.Northp();
      easting[i] = gc.Easting();
      northing[i] = gc.Northing();
      convergence[i] = gc.Convergence();
      scale[i] = gc.Scale();
    } catch (...) {
      lat[i] = NA_REAL;
      lon[i] = NA_REAL;
      zone[i] = NA_INTEGER;
      northp[i] = NA_LOGICAL;
      easting[i] = NA_REAL;
      northing[i] = NA_REAL;
      convergence[i] = NA_REAL;
      scale[i] = NA_REAL;
    }
  }
  
  writable::data_frame out({
    "lat"_nm = lat,
    "lon"_nm = lon,
    "zone"_nm = zone,
    "northp"_nm = northp,
    "easting"_nm = easting,
    "northing"_nm = northing,
    "convergence"_nm = convergence,
    "scale"_nm = scale
  });
  
  return out;
}

// Get MGRS string from lat/lon
[[cpp11::register]]
cpp11::writable::strings geocoords_to_mgrs_cpp(cpp11::doubles lat, cpp11::doubles lon,
                                                cpp11::integers precision) {
  size_t nn = lat.size();
  writable::strings mgrs(nn);
  
  for (size_t i = 0; i < nn; i++) {
    try {
      GeoCoords gc(lat[i], lon[i]);
      mgrs[i] = gc.MGRSRepresentation(precision[i]);
    } catch (...) {
      mgrs[i] = NA_STRING;
    }
  }
  
  return mgrs;
}

// Get UTM string from lat/lon
[[cpp11::register]]
cpp11::writable::strings geocoords_to_utm_cpp(cpp11::doubles lat, cpp11::doubles lon,
                                               cpp11::integers precision) {
  size_t nn = lat.size();
  writable::strings utm(nn);
  
  for (size_t i = 0; i < nn; i++) {
    try {
      GeoCoords gc(lat[i], lon[i]);
      utm[i] = gc.UTMUPSRepresentation(precision[i]);
    } catch (...) {
      utm[i] = NA_STRING;
    }
  }
  
  return utm;
}