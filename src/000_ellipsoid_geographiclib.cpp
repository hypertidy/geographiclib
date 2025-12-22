#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <GeographicLib/Ellipsoid.hpp>
#include <GeographicLib/Constants.hpp>

using namespace std;
using namespace GeographicLib;

// Get WGS84 ellipsoid parameters
[[cpp11::register]]
cpp11::writable::list ellipsoid_params_cpp() {
  const Ellipsoid& ell = Ellipsoid::WGS84();
  
  // Calculate semi-minor axis from a and f
  double a = ell.EquatorialRadius();
  double f = ell.Flattening();
  double b = a * (1 - f);
  
  writable::list out;
  out.push_back({"a"_nm = a});
  out.push_back({"f"_nm = f});
  out.push_back({"b"_nm = b});
  out.push_back({"e2"_nm = ell.EccentricitySq()});
  out.push_back({"ep2"_nm = ell.SecondEccentricitySq()});
  out.push_back({"n"_nm = ell.ThirdFlattening()});
  out.push_back({"area"_nm = ell.Area()});
  out.push_back({"volume"_nm = ell.Volume()});
  
  return out;
}

// Circle of latitude: radius and quarter meridian distance
[[cpp11::register]]
cpp11::writable::data_frame ellipsoid_circle_cpp(cpp11::doubles lat) {
  size_t nn = lat.size();
  
  writable::doubles radius(nn);
  writable::doubles quarter_meridian(nn);
  writable::doubles meridian_distance(nn);
  
  const Ellipsoid& ell = Ellipsoid::WGS84();
  
  for (size_t i = 0; i < nn; i++) {
    radius[i] = ell.CircleRadius(lat[i]);
    quarter_meridian[i] = ell.QuarterMeridian();
    meridian_distance[i] = ell.MeridianDistance(lat[i]);
  }
  
  writable::data_frame out({
    "lat"_nm = lat,
    "radius"_nm = radius,
    "quarter_meridian"_nm = quarter_meridian,
    "meridian_distance"_nm = meridian_distance
  });
  
  return out;
}

// Parametric, geocentric, and rectifying latitudes
[[cpp11::register]]
cpp11::writable::data_frame ellipsoid_latitudes_cpp(cpp11::doubles lat) {
  size_t nn = lat.size();
  
  writable::doubles parametric(nn);
  writable::doubles geocentric(nn);
  writable::doubles rectifying(nn);
  writable::doubles authalic(nn);
  writable::doubles conformal(nn);
  writable::doubles isometric(nn);
  
  const Ellipsoid& ell = Ellipsoid::WGS84();
  
  for (size_t i = 0; i < nn; i++) {
    parametric[i] = ell.ParametricLatitude(lat[i]);
    geocentric[i] = ell.GeocentricLatitude(lat[i]);
    rectifying[i] = ell.RectifyingLatitude(lat[i]);
    authalic[i] = ell.AuthalicLatitude(lat[i]);
    conformal[i] = ell.ConformalLatitude(lat[i]);
    isometric[i] = ell.IsometricLatitude(lat[i]);
  }
  
  writable::data_frame out({
    "lat"_nm = lat,
    "parametric"_nm = parametric,
    "geocentric"_nm = geocentric,
    "rectifying"_nm = rectifying,
    "authalic"_nm = authalic,
    "conformal"_nm = conformal,
    "isometric"_nm = isometric
  });
  
  return out;
}

// Inverse latitude conversions
[[cpp11::register]]
cpp11::writable::data_frame ellipsoid_latitudes_inv_cpp(cpp11::doubles lat, 
                                                         cpp11::strings type) {
  size_t nn = lat.size();
  
  writable::doubles geographic(nn);
  
  const Ellipsoid& ell = Ellipsoid::WGS84();
  std::string lat_type(type[0]);
  
  for (size_t i = 0; i < nn; i++) {
    if (lat_type == "parametric") {
      geographic[i] = ell.InverseParametricLatitude(lat[i]);
    } else if (lat_type == "geocentric") {
      geographic[i] = ell.InverseGeocentricLatitude(lat[i]);
    } else if (lat_type == "rectifying") {
      geographic[i] = ell.InverseRectifyingLatitude(lat[i]);
    } else if (lat_type == "authalic") {
      geographic[i] = ell.InverseAuthalicLatitude(lat[i]);
    } else if (lat_type == "conformal") {
      geographic[i] = ell.InverseConformalLatitude(lat[i]);
    } else if (lat_type == "isometric") {
      geographic[i] = ell.InverseIsometricLatitude(lat[i]);
    } else {
      geographic[i] = lat[i];  // Unknown type, return as-is
    }
  }
  
  writable::data_frame out({
    "input"_nm = lat,
    "geographic"_nm = geographic
  });
  
  return out;
}

// Curvatures at a given latitude
[[cpp11::register]]
cpp11::writable::data_frame ellipsoid_curvature_cpp(cpp11::doubles lat) {
  size_t nn = lat.size();
  
  writable::doubles meridional(nn);          // M
  writable::doubles transverse(nn);          // N
  writable::doubles normal_curvature(nn);
  
  const Ellipsoid& ell = Ellipsoid::WGS84();
  
  for (size_t i = 0; i < nn; i++) {
    meridional[i] = ell.MeridionalCurvatureRadius(lat[i]);
    transverse[i] = ell.TransverseCurvatureRadius(lat[i]);
    normal_curvature[i] = ell.NormalCurvatureRadius(lat[i], 0);  // azi=0 for meridional
  }
  
  writable::data_frame out({
    "lat"_nm = lat,
    "meridional"_nm = meridional,
    "transverse"_nm = transverse
  });
  
  return out;
}
