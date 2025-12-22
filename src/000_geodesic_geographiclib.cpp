#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <GeographicLib/Geodesic.hpp>
#include <GeographicLib/GeodesicLine.hpp>
#include <GeographicLib/Constants.hpp>

using namespace std;
using namespace GeographicLib;

// Direct problem: Given start point, azimuth, and distance, find end point
// Uses series approximation (faster than GeodesicExact, accurate to ~15 nanometers)
[[cpp11::register]]
cpp11::writable::data_frame geodesic_direct_fast_cpp(cpp11::doubles lon1, cpp11::doubles lat1,
                                                      cpp11::doubles azi1, cpp11::doubles s12) {
  size_t nn = lon1.size();
  
  writable::doubles lon2(nn);
  writable::doubles lat2(nn);
  writable::doubles azi2(nn);
  writable::doubles m12(nn);
  writable::doubles M12(nn);
  writable::doubles M21(nn);
  writable::doubles S12(nn);
  
  const Geodesic& geod = Geodesic::WGS84();
  
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
[[cpp11::register]]
cpp11::writable::data_frame geodesic_inverse_fast_cpp(cpp11::doubles lon1, cpp11::doubles lat1,
                                                       cpp11::doubles lon2, cpp11::doubles lat2) {
  size_t nn = lon1.size();
  
  writable::doubles s12(nn);
  writable::doubles azi1(nn);
  writable::doubles azi2(nn);
  writable::doubles m12(nn);
  writable::doubles M12(nn);
  writable::doubles M21(nn);
  writable::doubles S12(nn);
  
  const Geodesic& geod = Geodesic::WGS84();
  
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
[[cpp11::register]]
cpp11::writable::data_frame geodesic_path_fast_cpp(double lon1, double lat1,
                                                    double lon2, double lat2,
                                                    int n_points) {
  
  writable::doubles lon(n_points);
  writable::doubles lat(n_points);
  writable::doubles azi(n_points);
  writable::doubles s(n_points);
  
  const Geodesic& geod = Geodesic::WGS84();
  
  double s12, azi1, azi2;
  geod.Inverse(lat1, lon1, lat2, lon2, s12, azi1, azi2);
  
  GeodesicLine line = geod.Line(lat1, lon1, azi1);
  
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

// Pairwise distances
[[cpp11::register]]
cpp11::writable::doubles geodesic_distance_fast_cpp(cpp11::doubles lon1, cpp11::doubles lat1,
                                                     cpp11::doubles lon2, cpp11::doubles lat2) {
  size_t nn = lon1.size();
  
  writable::doubles dist(nn);
  
  const Geodesic& geod = Geodesic::WGS84();
  
  for (size_t i = 0; i < nn; i++) {
    double s12;
    geod.Inverse(lat1[i], lon1[i], lat2[i], lon2[i], s12);
    dist[i] = s12;
  }
  
  return dist;
}

// Distance matrix
[[cpp11::register]]
cpp11::writable::doubles geodesic_distance_matrix_fast_cpp(cpp11::doubles lon1, cpp11::doubles lat1,
                                                            cpp11::doubles lon2, cpp11::doubles lat2) {
  size_t n1 = lon1.size();
  size_t n2 = lon2.size();
  
  writable::doubles dist(n1 * n2);
  
  const Geodesic& geod = Geodesic::WGS84();
  
  for (size_t i = 0; i < n1; i++) {
    for (size_t j = 0; j < n2; j++) {
      double s12;
      geod.Inverse(lat1[i], lon1[i], lat2[j], lon2[j], s12);
      dist[i * n2 + j] = s12;
    }
  }
  
  return dist;
}
