#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <GeographicLib/Geodesic.hpp>
#include <GeographicLib/Intersect.hpp>
#include <GeographicLib/Constants.hpp>

using namespace std;
using namespace GeographicLib;

// Find closest intersection of two geodesics defined by point + azimuth
// Vectorized: each row defines a pair of geodesics
[[cpp11::register]]
cpp11::writable::data_frame intersect_closest_cpp(
    cpp11::doubles latX, cpp11::doubles lonX, cpp11::doubles aziX,
    cpp11::doubles latY, cpp11::doubles lonY, cpp11::doubles aziY) {
  
  size_t nn = latX.size();
  
  writable::doubles x(nn);      // displacement along geodesic X
  writable::doubles y(nn);      // displacement along geodesic Y
  writable::integers c(nn);     // coincidence indicator
  writable::doubles lat(nn);    // latitude of intersection
  writable::doubles lon(nn);    // longitude of intersection
  
  const Geodesic& geod = Geodesic::WGS84();
  Intersect inter(geod);
  
  for (size_t i = 0; i < nn; i++) {
    if (ISNAN(latX[i]) || ISNAN(lonX[i]) || ISNAN(aziX[i]) ||
        ISNAN(latY[i]) || ISNAN(lonY[i]) || ISNAN(aziY[i])) {
      x[i] = NA_REAL;
      y[i] = NA_REAL;
      c[i] = NA_INTEGER;
      lat[i] = NA_REAL;
      lon[i] = NA_REAL;
      continue;
    }
    
    int coinc;
    Intersect::Point p = inter.Closest(latX[i], lonX[i], aziX[i],
                                        latY[i], lonY[i], aziY[i],
                                        Intersect::Point(0, 0), &coinc);
    
    x[i] = p.first;
    y[i] = p.second;
    c[i] = coinc;
    
    // Compute actual lat/lon of intersection by moving along geodesic X
    double la, lo, az;
    geod.Direct(latX[i], lonX[i], aziX[i], p.first, la, lo, az);
    lat[i] = la;
    lon[i] = lo;
  }
  
  writable::data_frame out({
    "x"_nm = x,
    "y"_nm = y,
    "coincidence"_nm = c,
    "lat"_nm = lat,
    "lon"_nm = lon
  });
  
  return out;
}

// Find intersection of two geodesic segments defined by endpoints
[[cpp11::register]]
cpp11::writable::data_frame intersect_segment_cpp(
    cpp11::doubles latX1, cpp11::doubles lonX1,
    cpp11::doubles latX2, cpp11::doubles lonX2,
    cpp11::doubles latY1, cpp11::doubles lonY1,
    cpp11::doubles latY2, cpp11::doubles lonY2) {
  
  size_t nn = latX1.size();
  
  writable::doubles x(nn);
  writable::doubles y(nn);
  writable::integers segmode(nn);
  writable::integers c(nn);
  writable::doubles lat(nn);
  writable::doubles lon(nn);
  
  const Geodesic& geod = Geodesic::WGS84();
  Intersect inter(geod);
  
  for (size_t i = 0; i < nn; i++) {
    if (ISNAN(latX1[i]) || ISNAN(lonX1[i]) || ISNAN(latX2[i]) || ISNAN(lonX2[i]) ||
        ISNAN(latY1[i]) || ISNAN(lonY1[i]) || ISNAN(latY2[i]) || ISNAN(lonY2[i])) {
      x[i] = NA_REAL;
      y[i] = NA_REAL;
      segmode[i] = NA_INTEGER;
      c[i] = NA_INTEGER;
      lat[i] = NA_REAL;
      lon[i] = NA_REAL;
      continue;
    }
    
    int sm, coinc;
    Intersect::Point p = inter.Segment(latX1[i], lonX1[i], latX2[i], lonX2[i],
                                        latY1[i], lonY1[i], latY2[i], lonY2[i],
                                        sm, &coinc);
    
    x[i] = p.first;
    y[i] = p.second;
    segmode[i] = sm;
    c[i] = coinc;
    
    // Compute actual lat/lon of intersection by moving along segment X
    // First get azimuth from point 1 to point 2
    double s12, azi1, azi2;
    geod.Inverse(latX1[i], lonX1[i], latX2[i], lonX2[i], s12, azi1, azi2);
    
    // Then move along that azimuth by distance x
    double la, lo, az;
    geod.Direct(latX1[i], lonX1[i], azi1, p.first, la, lo, az);
    lat[i] = la;
    lon[i] = lo;
  }
  
  writable::data_frame out({
    "x"_nm = x,
    "y"_nm = y,
    "segmode"_nm = segmode,
    "coincidence"_nm = c,
    "lat"_nm = lat,
    "lon"_nm = lon
  });
  
  return out;
}

// Find next closest intersection from a known intersection point
[[cpp11::register]]
cpp11::writable::data_frame intersect_next_cpp(
    cpp11::doubles latX, cpp11::doubles lonX,
    cpp11::doubles aziX, cpp11::doubles aziY) {
  
  size_t nn = latX.size();
  
  writable::doubles x(nn);
  writable::doubles y(nn);
  writable::integers c(nn);
  writable::doubles lat(nn);
  writable::doubles lon(nn);
  
  const Geodesic& geod = Geodesic::WGS84();
  Intersect inter(geod);
  
  for (size_t i = 0; i < nn; i++) {
    if (ISNAN(latX[i]) || ISNAN(lonX[i]) || ISNAN(aziX[i]) || ISNAN(aziY[i])) {
      x[i] = NA_REAL;
      y[i] = NA_REAL;
      c[i] = NA_INTEGER;
      lat[i] = NA_REAL;
      lon[i] = NA_REAL;
      continue;
    }
    
    int coinc;
    Intersect::Point p = inter.Next(latX[i], lonX[i], aziX[i], aziY[i], &coinc);
    
    x[i] = p.first;
    y[i] = p.second;
    c[i] = coinc;
    
    // Compute actual lat/lon
    double la, lo, az;
    geod.Direct(latX[i], lonX[i], aziX[i], p.first, la, lo, az);
    lat[i] = la;
    lon[i] = lo;
  }
  
  writable::data_frame out({
    "x"_nm = x,
    "y"_nm = y,
    "coincidence"_nm = c,
    "lat"_nm = lat,
    "lon"_nm = lon
  });
  
  return out;
}

// Find all intersections within a maximum distance
// Returns a list of data frames (one per input row)
[[cpp11::register]]
cpp11::writable::list intersect_all_cpp(
    cpp11::doubles latX, cpp11::doubles lonX, cpp11::doubles aziX,
    cpp11::doubles latY, cpp11::doubles lonY, cpp11::doubles aziY,
    cpp11::doubles maxdist) {
  
  size_t nn = latX.size();
  
  const Geodesic& geod = Geodesic::WGS84();
  Intersect inter(geod);
  
  writable::list out(nn);
  
  for (size_t i = 0; i < nn; i++) {
    if (ISNAN(latX[i]) || ISNAN(lonX[i]) || ISNAN(aziX[i]) ||
        ISNAN(latY[i]) || ISNAN(lonY[i]) || ISNAN(aziY[i]) ||
        ISNAN(maxdist[i])) {
      // Return empty data frame for NA inputs
      writable::doubles x_empty;
      writable::doubles y_empty;
      writable::integers c_empty;
      writable::doubles lat_empty;
      writable::doubles lon_empty;
      
      writable::data_frame df({
        "x"_nm = x_empty,
        "y"_nm = y_empty,
        "coincidence"_nm = c_empty,
        "lat"_nm = lat_empty,
        "lon"_nm = lon_empty
      });
      out[i] = df;
      continue;
    }
    
    vector<int> coinc;
    vector<Intersect::Point> pts = inter.All(
      latX[i], lonX[i], aziX[i],
      latY[i], lonY[i], aziY[i],
      maxdist[i], coinc
    );
    
    size_t np = pts.size();
    writable::doubles x_out(np);
    writable::doubles y_out(np);
    writable::integers c_out(np);
    writable::doubles lat_out(np);
    writable::doubles lon_out(np);
    
    for (size_t j = 0; j < np; j++) {
      x_out[j] = pts[j].first;
      y_out[j] = pts[j].second;
      c_out[j] = coinc[j];
      
      double la, lo, az;
      geod.Direct(latX[i], lonX[i], aziX[i], pts[j].first, la, lo, az);
      lat_out[j] = la;
      lon_out[j] = lo;
    }
    
    writable::data_frame df({
      "x"_nm = x_out,
      "y"_nm = y_out,
      "coincidence"_nm = c_out,
      "lat"_nm = lat_out,
      "lon"_nm = lon_out
    });
    out[i] = df;
  }
  
  return out;
}
