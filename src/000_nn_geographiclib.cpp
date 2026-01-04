#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <vector>
#include <utility>
#include <GeographicLib/Geodesic.hpp>
#include <GeographicLib/NearestNeighbor.hpp>
#include <GeographicLib/Constants.hpp>

using namespace std;
using namespace GeographicLib;

// Position type: lat, lon pair
typedef pair<double, double> pos_t;

// Distance functor for geodesic distances
class GeodesicDist {
private:
  Geodesic _geod;
public:
  explicit GeodesicDist(const Geodesic& geod) : _geod(geod) {}
  
  double operator()(const pos_t& a, const pos_t& b) const {
    double s12;
    _geod.Inverse(a.first, a.second, b.first, b.second, s12);
    return s12;
  }
};

// Build a nearest neighbor index and find k nearest neighbors for query points
[[cpp11::register]]
cpp11::writable::list nn_search_cpp(
    cpp11::doubles dataset_lat, cpp11::doubles dataset_lon,
    cpp11::doubles query_lat, cpp11::doubles query_lon,
    int k) {
  
  size_t n_data = dataset_lat.size();
  size_t n_query = query_lat.size();
  
  // Build dataset vector
  vector<pos_t> dataset(n_data);
  for (size_t i = 0; i < n_data; i++) {
    dataset[i] = make_pair(dataset_lat[i], dataset_lon[i]);
  }
  
  // Create distance functor and build the tree
  GeodesicDist dist(Geodesic::WGS84());
  NearestNeighbor<double, pos_t, GeodesicDist> nn(dataset, dist);
  
  // Each query point gets k neighbors (or fewer if dataset is smaller)
  int actual_k = min(k, static_cast<int>(n_data));
  
  writable::integers idx(n_query * actual_k);
  writable::doubles distances(n_query * actual_k);
  
  // Search for each query point
  for (size_t i = 0; i < n_query; i++) {
    if (ISNAN(query_lat[i]) || ISNAN(query_lon[i])) {
      for (int j = 0; j < actual_k; j++) {
        idx[i * actual_k + j] = NA_INTEGER;
        distances[i * actual_k + j] = NA_REAL;
      }
      continue;
    }
    
    pos_t query = make_pair(query_lat[i], query_lon[i]);
    vector<int> ind(actual_k);
    
    // Search - pass k as parameter
    nn.Search(dataset, dist, query, ind, actual_k);
    
    for (int j = 0; j < actual_k; j++) {
      if (ind[j] >= 0) {
        idx[i * actual_k + j] = ind[j] + 1;  // 1-based indexing for R
        // Compute distance to this neighbor
        distances[i * actual_k + j] = dist(query, dataset[ind[j]]);
      } else {
        idx[i * actual_k + j] = NA_INTEGER;
        distances[i * actual_k + j] = NA_REAL;
      }
    }
  }
  
  // Set dimensions for matrix output (k rows, n_query cols)
  idx.attr("dim") = writable::integers({actual_k, static_cast<int>(n_query)});
  distances.attr("dim") = writable::integers({actual_k, static_cast<int>(n_query)});
  
  writable::list out;
  out.push_back({"index"_nm = idx});
  out.push_back({"distance"_nm = distances});
  
  return out;
}

// Find all neighbors within a given radius
[[cpp11::register]]
cpp11::writable::list nn_search_radius_cpp(
    cpp11::doubles dataset_lat, cpp11::doubles dataset_lon,
    cpp11::doubles query_lat, cpp11::doubles query_lon,
    double radius) {
  
  size_t n_data = dataset_lat.size();
  size_t n_query = query_lat.size();
  
  // Build dataset vector
  vector<pos_t> dataset(n_data);
  for (size_t i = 0; i < n_data; i++) {
    dataset[i] = make_pair(dataset_lat[i], dataset_lon[i]);
  }
  
  // Create distance functor and build the tree
  GeodesicDist dist(Geodesic::WGS84());
  NearestNeighbor<double, pos_t, GeodesicDist> nn(dataset, dist);
  
  // Output is a list of data frames (variable number of neighbors per query)
  writable::list out(n_query);
  
  for (size_t i = 0; i < n_query; i++) {
    if (ISNAN(query_lat[i]) || ISNAN(query_lon[i])) {
      writable::integers empty_idx;
      writable::doubles empty_dist;
      writable::data_frame df({
        "index"_nm = empty_idx,
        "distance"_nm = empty_dist
      });
      out[i] = df;
      continue;
    }
    
    pos_t query = make_pair(query_lat[i], query_lon[i]);
    
    // Search for all points with maxdist = radius
    // k = n_data to get all potential neighbors
    vector<int> ind(n_data);
    nn.Search(dataset, dist, query, ind, static_cast<int>(n_data), radius);
    
    // Collect valid results (ind[j] >= 0 means a valid neighbor was found)
    writable::integers r_idx;
    writable::doubles r_dist;
    
    for (size_t j = 0; j < ind.size(); j++) {
      if (ind[j] >= 0) {
        double d = dist(query, dataset[ind[j]]);
        r_idx.push_back(ind[j] + 1);  // 1-based for R
        r_dist.push_back(d);
      }
    }
    
    writable::data_frame df({
      "index"_nm = r_idx,
      "distance"_nm = r_dist
    });
    out[i] = df;
  }
  
  return out;
}
