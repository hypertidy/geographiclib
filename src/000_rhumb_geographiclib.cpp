#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <string>
#include <GeographicLib/Rhumb.hpp>

using namespace std;
using namespace GeographicLib;

// Direct problem: Given start point, azimuth, and distance, find end point
// Fully vectorized on all inputs
[[cpp11::register]]
cpp11::writable::data_frame rhumb_direct_cpp(cpp11::doubles lon1, cpp11::doubles lat1,
                                              cpp11::doubles azi12, cpp11::doubles s12) {
  size_t nn = lon1.size();
  
  writable::doubles lon2(nn);
  writable::doubles lat2(nn);
  writable::doubles S12(nn);  // area under rhumb line
  
  const Rhumb& rhumb = Rhumb::WGS84();
  
  for (size_t i = 0; i < nn; i++) {
    double la2, lo2, area;
    
    rhumb.Direct(lat1[i], lon1[i], azi12[i], s12[i], la2, lo2, area);
    
    lon2[i] = lo2;
    lat2[i] = la2;
    S12[i] = area;
  }
  
  writable::data_frame out({
    "lon1"_nm = lon1,
    "lat1"_nm = lat1,
    "azi12"_nm = azi12,
    "s12"_nm = s12,
    "lon2"_nm = lon2,
    "lat2"_nm = lat2,
    "S12"_nm = S12
  });
  
  return out;
}

// Inverse problem: Given two points, find distance and azimuth
// Fully vectorized
[[cpp11::register]]
cpp11::writable::data_frame rhumb_inverse_cpp(cpp11::doubles lon1, cpp11::doubles lat1,
                                               cpp11::doubles lon2, cpp11::doubles lat2) {
  size_t nn = lon1.size();
  
  writable::doubles s12(nn);       // distance
  writable::doubles azi12(nn);     // azimuth
  writable::doubles S12(nn);       // area under rhumb line
  
  const Rhumb& rhumb = Rhumb::WGS84();
  
  for (size_t i = 0; i < nn; i++) {
    double ss12, az12, area;
    
    rhumb.Inverse(lat1[i], lon1[i], lat2[i], lon2[i], ss12, az12, area);
    
    s12[i] = ss12;
    azi12[i] = az12;
    S12[i] = area;
  }
  
  writable::data_frame out({
    "lon1"_nm = lon1,
    "lat1"_nm = lat1,
    "lon2"_nm = lon2,
    "lat2"_nm = lat2,
    "s12"_nm = s12,
    "azi12"_nm = azi12,
    "S12"_nm = S12
  });
  
  return out;
}

// Generate points along a rhumb line between two points
// n_points specifies number of points including start and end
[[cpp11::register]]
cpp11::writable::data_frame rhumb_path_cpp(double lon1, double lat1,
                                            double lon2, double lat2,
                                            int n_points) {
  
  writable::doubles lon(n_points);
  writable::doubles lat(n_points);
  writable::doubles s(n_points);    // distance from start
  
  const Rhumb& rhumb = Rhumb::WGS84();
  
  // First get the total distance and azimuth
  double s12, azi12, S12;
  rhumb.Inverse(lat1, lon1, lat2, lon2, s12, azi12, S12);
  
  // Create a rhumb line
  RhumbLine line = rhumb.Line(lat1, lon1, azi12);
  
  for (int i = 0; i < n_points; i++) {
    double frac = (n_points > 1) ? (double)i / (n_points - 1) : 0.0;
    double dist = frac * s12;
    
    double la, lo;
    line.Position(dist, la, lo);
    
    lon[i] = lo;
    lat[i] = la;
    s[i] = dist;
  }
  
  writable::data_frame out({
    "lon"_nm = lon,
    "lat"_nm = lat,
    "s"_nm = s,
    "azi12"_nm = azi12
  });
  
  return out;
}

// Generate points along a rhumb line given start, azimuth, and distances
[[cpp11::register]]
cpp11::writable::data_frame rhumb_line_cpp(double lon1, double lat1,
                                            double azi12, cpp11::doubles distances) {
  
  size_t nn = distances.size();
  
  writable::doubles lon(nn);
  writable::doubles lat(nn);
  
  const Rhumb& rhumb = Rhumb::WGS84();
  RhumbLine line = rhumb.Line(lat1, lon1, azi12);
  
  for (size_t i = 0; i < nn; i++) {
    double la, lo;
    line.Position(distances[i], la, lo);
    
    lon[i] = lo;
    lat[i] = la;
  }
  
  writable::data_frame out({
    "lon"_nm = lon,
    "lat"_nm = lat,
    "azi"_nm = azi12,
    "s"_nm = distances
  });
  
  return out;
}

// Pairwise rhumb distances (element-wise between two equal-length vectors)
[[cpp11::register]]
cpp11::writable::doubles rhumb_distance_pairwise_cpp(cpp11::doubles lon1, cpp11::doubles lat1,
                                                      cpp11::doubles lon2, cpp11::doubles lat2) {
  size_t nn = lon1.size();
  
  writable::doubles dist(nn);
  
  const Rhumb& rhumb = Rhumb::WGS84();
  
  for (size_t i = 0; i < nn; i++) {
    double s12, azi12;
    rhumb.Inverse(lat1[i], lon1[i], lat2[i], lon2[i], s12, azi12);
    dist[i] = s12;
  }
  
  return dist;
}

// Compute rhumb distance matrix between two sets of points
// Returns a vector in row-major order (for reshaping to matrix in R)
[[cpp11::register]]
cpp11::writable::doubles rhumb_distance_matrix_cpp(cpp11::doubles lon1, cpp11::doubles lat1,
                                                    cpp11::doubles lon2, cpp11::doubles lat2) {
  size_t n1 = lon1.size();
  size_t n2 = lon2.size();
  
  writable::doubles dist(n1 * n2);
  
  const Rhumb& rhumb = Rhumb::WGS84();
  
  for (size_t i = 0; i < n1; i++) {
    for (size_t j = 0; j < n2; j++) {
      double s12, azi12;
      rhumb.Inverse(lat1[i], lon1[i], lat2[j], lon2[j], s12, azi12);
      dist[i * n2 + j] = s12;
    }
  }
  
  return dist;
}
