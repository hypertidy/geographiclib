#include <cpp11.hpp>
using namespace cpp11;
namespace writable = cpp11::writable;

#include <string>
#include <GeographicLib/DMS.hpp>

using namespace std;
using namespace GeographicLib;

// Parse a DMS string and return the angle in degrees
// Also returns the hemisphere indicator (0=NONE, 1=LATITUDE, 2=LONGITUDE)
[[cpp11::register]]
cpp11::writable::data_frame dms_decode_cpp(cpp11::strings input) {
  size_t nn = input.size();
  
  writable::doubles angle(nn);
  writable::integers indicator(nn);
  
  for (size_t i = 0; i < nn; i++) {
    try {
      std::string s(input[i]);
      DMS::flag ind;
      double deg = DMS::Decode(s, ind);
      angle[i] = deg;
      indicator[i] = static_cast<int>(ind);
    } catch (...) {
      angle[i] = NA_REAL;
      indicator[i] = NA_INTEGER;
    }
  }
  
  writable::data_frame out({
    "angle"_nm = angle,
    "indicator"_nm = indicator
  });
  
  return out;
}

// Parse a pair of DMS strings to latitude and longitude
[[cpp11::register]]
cpp11::writable::data_frame dms_decode_latlon_cpp(cpp11::strings dmsa, 
                                                   cpp11::strings dmsb,
                                                   cpp11::logicals longfirst) {
  size_t nn = dmsa.size();
  
  writable::doubles lat(nn);
  writable::doubles lon(nn);
  
  for (size_t i = 0; i < nn; i++) {
    try {
      std::string sa(dmsa[i]);
      std::string sb(dmsb[i]);
      double lat_out, lon_out;
      DMS::DecodeLatLon(sa, sb, lat_out, lon_out, longfirst[i] == TRUE);
      lat[i] = lat_out;
      lon[i] = lon_out;
    } catch (...) {
      lat[i] = NA_REAL;
      lon[i] = NA_REAL;
    }
  }
  
  writable::data_frame out({
    "lat"_nm = lat,
    "lon"_nm = lon
  });
  
  return out;
}

// Parse a DMS string as an angle (no hemisphere designator allowed)
[[cpp11::register]]
cpp11::writable::doubles dms_decode_angle_cpp(cpp11::strings input) {
  size_t nn = input.size();
  writable::doubles angle(nn);
  
  for (size_t i = 0; i < nn; i++) {
    try {
      std::string s(input[i]);
      angle[i] = DMS::DecodeAngle(s);
    } catch (...) {
      angle[i] = NA_REAL;
    }
  }
  
  return angle;
}

// Parse a DMS string as an azimuth (E/W allowed, N/S not allowed)
[[cpp11::register]]
cpp11::writable::doubles dms_decode_azimuth_cpp(cpp11::strings input) {
  size_t nn = input.size();
  writable::doubles angle(nn);
  
  for (size_t i = 0; i < nn; i++) {
    try {
      std::string s(input[i]);
      angle[i] = DMS::DecodeAzimuth(s);
    } catch (...) {
      angle[i] = NA_REAL;
    }
  }
  
  return angle;
}

// Convert degrees to DMS string with specified trailing component
// component: 0=DEGREE, 1=MINUTE, 2=SECOND
// indicator: 0=NONE, 1=LATITUDE, 2=LONGITUDE, 3=AZIMUTH, 4=NUMBER
[[cpp11::register]]
cpp11::writable::strings dms_encode_cpp(cpp11::doubles angle, 
                                         cpp11::integers component,
                                         cpp11::integers prec,
                                         cpp11::integers indicator,
                                         cpp11::strings dmssep) {
  size_t nn = angle.size();
  writable::strings out(nn);
  
  for (size_t i = 0; i < nn; i++) {
    try {
      DMS::component comp = static_cast<DMS::component>(component[i]);
      DMS::flag ind = static_cast<DMS::flag>(indicator[i]);
      char sep = 0;
      std::string sep_str(dmssep[i]);
      if (!sep_str.empty()) {
        sep = sep_str[0];
      }
      out[i] = DMS::Encode(angle[i], comp, static_cast<unsigned>(prec[i]), ind, sep);
    } catch (...) {
      out[i] = NA_STRING;
    }
  }
  
  return out;
}

// Simpler encode using automatic trailing component selection based on precision
[[cpp11::register]]
cpp11::writable::strings dms_encode_auto_cpp(cpp11::doubles angle,
                                              cpp11::integers prec,
                                              cpp11::integers indicator,
                                              cpp11::strings dmssep) {
  size_t nn = angle.size();
  writable::strings out(nn);
  
  for (size_t i = 0; i < nn; i++) {
    try {
      DMS::flag ind = static_cast<DMS::flag>(indicator[i]);
      char sep = 0;
      std::string sep_str(dmssep[i]);
      if (!sep_str.empty()) {
        sep = sep_str[0];
      }
      out[i] = DMS::Encode(angle[i], static_cast<unsigned>(prec[i]), ind, sep);
    } catch (...) {
      out[i] = NA_STRING;
    }
  }
  
  return out;
}

// Convert degrees to degrees, minutes components
[[cpp11::register]]
cpp11::writable::data_frame dms_split_dm_cpp(cpp11::doubles angle) {
  size_t nn = angle.size();
  
  writable::doubles d(nn);
  writable::doubles m(nn);
  
  for (size_t i = 0; i < nn; i++) {
    if (ISNA(angle[i])) {
      d[i] = NA_REAL;
      m[i] = NA_REAL;
    } else {
      double d_out, m_out;
      DMS::Encode(angle[i], d_out, m_out);
      d[i] = d_out;
      m[i] = m_out;
    }
  }
  
  writable::data_frame out({
    "d"_nm = d,
    "m"_nm = m
  });
  
  return out;
}

// Convert degrees to degrees, minutes, seconds components
[[cpp11::register]]
cpp11::writable::data_frame dms_split_dms_cpp(cpp11::doubles angle) {
  size_t nn = angle.size();
  
  writable::doubles d(nn);
  writable::doubles m(nn);
  writable::doubles s(nn);
  
  for (size_t i = 0; i < nn; i++) {
    if (ISNA(angle[i])) {
      d[i] = NA_REAL;
      m[i] = NA_REAL;
      s[i] = NA_REAL;
    } else {
      double d_out, m_out, s_out;
      DMS::Encode(angle[i], d_out, m_out, s_out);
      d[i] = d_out;
      m[i] = m_out;
      s[i] = s_out;
    }
  }
  
  writable::data_frame out({
    "d"_nm = d,
    "m"_nm = m,
    "s"_nm = s
  });
  
  return out;
}

// Convert degrees, minutes, seconds to decimal degrees
[[cpp11::register]]
cpp11::writable::doubles dms_combine_cpp(cpp11::doubles d, 
                                          cpp11::doubles m, 
                                          cpp11::doubles s) {
  size_t nn = d.size();
  writable::doubles angle(nn);
  
  for (size_t i = 0; i < nn; i++) {
    if (ISNA(d[i])) {
      angle[i] = NA_REAL;
    } else {
      double m_val = ISNA(m[i]) ? 0.0 : m[i];
      double s_val = ISNA(s[i]) ? 0.0 : s[i];
      angle[i] = DMS::Decode(d[i], m_val, s_val);
    }
  }
  
  return angle;
}
