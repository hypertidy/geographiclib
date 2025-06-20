#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;


// Example of using the GeographicLib::PolygonArea class


#include <iostream>
#include <exception>
#include <GeographicLib/PolygonArea.hpp>
#include <GeographicLib/Geodesic.hpp>
#include <GeographicLib/Constants.hpp>

using namespace std;
using namespace GeographicLib;

[[cpp11::register]]
cpp11::doubles polygonarea_cpp() {
    Geodesic geod(Constants::WGS84_a(), Constants::WGS84_f());
    // Alternatively: const Geodesic& geod = Geodesic::WGS84();
    PolygonArea poly(geod);
    poly.AddPoint( 52,  0);     // London
    poly.AddPoint( 41,-74);     // New York
    poly.AddPoint(-23,-43);     // Rio de Janeiro
    poly.AddPoint(-26, 28);     // Johannesburg
    double perimeter, area;
    unsigned n = poly.Compute(false, true, perimeter, area);
    //cout << n << " " << perimeter << " " << area << "\n";
    // This adds a test for a bug fix for AddEdge.  (Implements the
    // Planimeter29 test in geodtest.c.)
   // PolygonArea poly1(geod);
  //  poly1.AddPoint(0,0);
  //  poly1.AddEdge(90,1000);
  //  poly1.AddEdge(0,1000);
  //  poly1.AddEdge(-90,1000);
  //  n = poly1.Compute(false, true, perimeter, area);
    // The area should be 1e6.  Prior to the fix it was 1e6 - A/2, where
    // A = ellipsoid area.
    //cout << n << " " << perimeter << " " << area << "\n";
   writable::doubles out(3);
   out[0] = area;
   out[1] = perimeter;
   out[3] = (double)n;
   out.names() = {"area", "perimeter", "n"};
   return out;
}
