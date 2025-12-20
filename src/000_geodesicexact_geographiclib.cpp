#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <string>
#include <GeographicLib/GeodesicExact.hpp>
#include <GeographicLib/GeodesicLineExact.hpp>
#include <GeographicLib/Constants.hpp>

using namespace std;
using namespace GeographicLib;

// Direct problem: Given start point, azimuth, and distance, find end point
// Fully vectorized on all inputs
[[cpp11::register]]
cpp11::writable::data_frame geodesic_direct_cpp(cpp11::doubles lon1, cpp11::doubles lat1,
                                                 cpp11::doubles azi1, cpp11::doubles s12) {
  size_t nn = lon1.size();
  
  writable::doubles lon2(nn);
  writable::doubles lat2(nn);
  writable::doubles azi2(nn);
  writable::doubles m12(nn);       // reduced length
  writable::doubles M12(nn);       // geodesic scale factor 1->2
  writable::doubles M21(nn);       // geodesic scale factor 2->1
  writable::doubles S12(nn);       // area under geodesic
  
  const GeodesicExact& geod = GeodesicExact::WGS84();
  
  for (size_t i = 0; i < nn; i++) {
    double la2, lo2, az2, m, MM12, MM21, SS12;
    
    geod.Direct(lat1[i], lon1[i], azi1[i], s12[i],
                la2, lo2, az2, m, MM12, MM21, SS12);
    
    lon2[i] = lo2;
    lat2[i] = la2;
    azi2[i] = az2;
    m12[i] = m;
    M12[i] = MM12;
    M21[i] = MM21;
    S12[i] = SS12;
  }
  
  writable::data_frame out({
    "lon1"_nm = lon1,
    "lat1"_nm = lat1,
    "azi1"_nm = azi1,
    "s12"_nm = s12,
    "lon2"_nm = lon2,
    "lat2"_nm = lat2,
    "azi2"_nm = azi2,
    "m12"_nm = m12,
    "M12"_nm = M12,
    "M21"_nm = M21,
    "S12"_nm = S12
  });
  
  return out;
}

// Inverse problem: Given two points, find distance and azimuths
// Fully vectorized
[[cpp11::register]]
cpp11::writable::data_frame geodesic_inverse_cpp(cpp11::doubles lon1, cpp11::doubles lat1,
                                                  cpp11::doubles lon2, cpp11::doubles lat2) {
  size_t nn = lon1.size();
  
  writable::doubles s12(nn);       // distance
  writable::doubles azi1(nn);      // forward azimuth at point 1
  writable::doubles azi2(nn);      // forward azimuth at point 2
  writable::doubles m12(nn);       // reduced length
  writable::doubles M12(nn);       // geodesic scale factor 1->2
  writable::doubles M21(nn);       // geodesic scale factor 2->1
  writable::doubles S12(nn);       // area under geodesic
  
  const GeodesicExact& geod = GeodesicExact::WGS84();
  
  for (size_t i = 0; i < nn; i++) {
    double ss12, az1, az2, m, MM12, MM21, SS12;
    
    geod.Inverse(lat1[i], lon1[i], lat2[i], lon2[i],
                 ss12, az1, az2, m, MM12, MM21, SS12);
    
    s12[i] = ss12;
    azi1[i] = az1;
    azi2[i] = az2;
    m12[i] = m;
    M12[i] = MM12;
    M21[i] = MM21;
    S12[i] = SS12;
  }
  
  writable::data_frame out({
    "lon1"_nm = lon1,
    "lat1"_nm = lat1,
    "lon2"_nm = lon2,
    "lat2"_nm = lat2,
    "s12"_nm = s12,
    "azi1"_nm = azi1,
    "azi2"_nm = azi2,
    "m12"_nm = m12,
    "M12"_nm = M12,
    "M21"_nm = M21,
    "S12"_nm = S12
  });
  
  return out;
}

// Generate points along a geodesic line between two points
// n_points specifies number of points including start and end
[[cpp11::register]]
cpp11::writable::data_frame geodesic_path_cpp(double lon1, double lat1,
                                               double lon2, double lat2,
                                               int n_points) {
  
  writable::doubles lon(n_points);
  writable::doubles lat(n_points);
  writable::doubles azi(n_points);
  writable::doubles s(n_points);    // distance from start
  
  const GeodesicExact& geod = GeodesicExact::WGS84();
  
  // First get the total distance and azimuth
  double s12, azi1, azi2;
  geod.Inverse(lat1, lon1, lat2, lon2, s12, azi1, azi2);
  
  // Create a geodesic line
  GeodesicLineExact line = geod.Line(lat1, lon1, azi1);
  
  for (int i = 0; i < n_points; i++) {
    double frac = (n_points > 1) ? (double)i / (n_points - 1) : 0.0;
    double dist = frac * s12;
    
    double la, lo, az;
    line.Position(dist, la, lo, az);
    
    lon[i] = lo;
    lat[i] = la;
    azi[i] = az;
    s[i] = dist;
  }
  
  writable::data_frame out({
    "lon"_nm = lon,
    "lat"_nm = lat,
    "azi"_nm = azi,
    "s"_nm = s
  });
  
  return out;
}

// Generate points along a geodesic given start, azimuth, and distances
[[cpp11::register]]
cpp11::writable::data_frame geodesic_line_cpp(double lon1, double lat1,
                                               double azi1, cpp11::doubles distances) {
  
  size_t nn = distances.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  writable::doubles azi(nn);
  
  const GeodesicExact& geod = GeodesicExact::WGS84();
  GeodesicLineExact line = geod.Line(lat1, lon1, azi1);
  
  for (size_t i = 0; i < nn; i++) {
    double la, lo, az;
    line.Position(distances[i], la, lo, az);
    
    lon[i] = lo;
    lat[i] = la;
    azi[i] = az;
  }
  
  writable::data_frame out({
    "lon"_nm = lon,
    "lat"_nm = lat,
    "azi"_nm = azi,
    "s"_nm = distances
  });
  
  return out;
}

// Compute distance matrix between two sets of points
// Returns a vector in row-major order (for reshaping to matrix in R)
[[cpp11::register]]
cpp11::writable::doubles geodesic_distance_matrix_cpp(cpp11::doubles lon1, cpp11::doubles lat1,
                                                       cpp11::doubles lon2, cpp11::doubles lat2) {
  size_t n1 = lon1.size();
  size_t n2 = lon2.size();
  
  writable::doubles dist(n1 * n2);
  
  const GeodesicExact& geod = GeodesicExact::WGS84();
  
  for (size_t i = 0; i < n1; i++) {
    for (size_t j = 0; j < n2; j++) {
      double s12;
      geod.Inverse(lat1[i], lon1[i], lat2[j], lon2[j], s12);
      dist[i * n2 + j] = s12;
    }
  }
  
  return dist;
}

// Pairwise distances (element-wise between two equal-length vectors)
[[cpp11::register]]
cpp11::writable::doubles geodesic_distance_pairwise_cpp(cpp11::doubles lon1, cpp11::doubles lat1,
                                                         cpp11::doubles lon2, cpp11::doubles lat2) {
  size_t nn = lon1.size();
  
  writable::doubles dist(nn);
  
  const GeodesicExact& geod = GeodesicExact::WGS84();
  
  for (size_t i = 0; i < nn; i++) {
    double s12;
    geod.Inverse(lat1[i], lon1[i], lat2[i], lon2[i], s12);
    dist[i] = s12;
  }
  
  return dist;
}