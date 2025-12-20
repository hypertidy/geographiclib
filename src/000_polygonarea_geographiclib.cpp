#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <GeographicLib/PolygonArea.hpp>
#include <GeographicLib/Geodesic.hpp>
#include <GeographicLib/Constants.hpp>

using namespace std;
using namespace GeographicLib;

// Compute geodesic polygon area and perimeter on the ellipsoid
// Takes vectors of lon/lat coordinates defining polygon vertices
// Polygons can be split by an id vector to compute multiple polygons at once
[[cpp11::register]]
cpp11::writable::data_frame polygonarea_cpp(cpp11::doubles lon, cpp11::doubles lat,
                                            cpp11::integers id, bool polyline) {

  // Get unique polygon IDs and count them
  size_t nn = lon.size();

  // Find unique IDs and their counts
  std::vector<int> unique_ids;
  std::vector<size_t> start_idx;
  std::vector<size_t> counts;

  int current_id = id[0];
  unique_ids.push_back(current_id);
  start_idx.push_back(0);
  size_t count = 1;

  for (size_t i = 1; i < nn; i++) {
    if (id[i] != current_id) {
      counts.push_back(count);
      current_id = id[i];
      unique_ids.push_back(current_id);
      start_idx.push_back(i);
      count = 1;
    } else {
      count++;
    }
  }
  counts.push_back(count);

  size_t n_polys = unique_ids.size();

  // Output vectors
  writable::doubles area(n_polys);
  writable::doubles perimeter(n_polys);
  writable::integers n_points(n_polys);
  writable::integers polygon_id(n_polys);

  // Use WGS84 geodesic
  const Geodesic& geod = Geodesic::WGS84();

  for (size_t p = 0; p < n_polys; p++) {
    PolygonArea poly(geod, polyline);

    size_t start = start_idx[p];
    size_t end = start + counts[p];

    for (size_t i = start; i < end; i++) {
      poly.AddPoint(lat[i], lon[i]);
    }

    double perim, ar;
    unsigned npts = poly.Compute(false, true, perim, ar);

    area[p] = ar;
    perimeter[p] = perim;
    n_points[p] = (int)npts;
    polygon_id[p] = unique_ids[p];
  }

  writable::data_frame out({
    "id"_nm = polygon_id,
      "area"_nm = area,
      "perimeter"_nm = perimeter,
      "n"_nm = n_points
  });

  return out;
}

// Simplified version for a single polygon (no id needed)
[[cpp11::register]]
cpp11::writable::list polygonarea_single_cpp(cpp11::doubles lon, cpp11::doubles lat,
                                             bool polyline) {

  const Geodesic& geod = Geodesic::WGS84();
  PolygonArea poly(geod, polyline);

  size_t nn = lon.size();
  for (size_t i = 0; i < nn; i++) {
    poly.AddPoint(lat[i], lon[i]);
  }

  double perimeter, area;
  unsigned n = poly.Compute(false, true, perimeter, area);

  writable::list out({
    "area"_nm = area,
      "perimeter"_nm = perimeter,
      "n"_nm = (int)n
  });

  return out;
}

// Test polygon at each vertex - returns cumulative area and perimeter
[[cpp11::register]]
cpp11::writable::data_frame polygonarea_cumulative_cpp(cpp11::doubles lon, cpp11::doubles lat,
                                                       bool polyline) {

  size_t nn = lon.size();

  writable::doubles area(nn);
  writable::doubles perimeter(nn);

  const Geodesic& geod = Geodesic::WGS84();
  PolygonArea poly(geod, polyline);

  for (size_t i = 0; i < nn; i++) {
    poly.AddPoint(lat[i], lon[i]);

    double perim, ar;
    poly.TestPoint(lat[i], lon[i], false, true, perim, ar);

    area[i] = ar;
    perimeter[i] = perim;
  }

  writable::data_frame out({
    "lon"_nm = lon,
      "lat"_nm = lat,
      "area"_nm = area,
      "perimeter"_nm = perimeter
  });

  return out;
}
