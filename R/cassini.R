#' Cassini-Soldner projection
#'
#' @description
#' Convert between geographic coordinates and the Cassini-Soldner projection.
#' This is a transverse cylindrical equidistant projection historically used
#' for large-scale mapping.
#'
#' @param x For forward conversion: a two-column matrix or data frame of
#'   coordinates (longitude, latitude) in decimal degrees.
#'   For reverse conversion: numeric vector of x (easting) coordinates in meters.
#' @param y Numeric vector of y (northing) coordinates in meters.
#' @param lon0 Longitude of the central meridian in decimal degrees.
#' @param lat0 Latitude of the origin in decimal degrees.
#'
#' @returns Data frame with columns:
#' * For forward conversion:
#'   - `x`: Easting in meters
#'   - `y`: Northing in meters
#'   - `azi`: Azimuth of the geodesic from the central point (degrees)
#'   - `rk`: Reciprocal of the azimuthal scale
#'   - `lon`, `lat`: Input coordinates (echoed)
#'
#' * For reverse conversion:
#'   - `lon`: Longitude in decimal degrees
#'   - `lat`: Latitude in decimal degrees
#'   - `azi`: Azimuth of the geodesic from the central point (degrees)
#'   - `rk`: Reciprocal of the azimuthal scale
#'   - `x`, `y`: Input coordinates (echoed)
#'
#' @details
#' The Cassini-Soldner projection was historically used for large-scale
#' topographic mapping before UTM became standard. It is still used in some
#' countries and for historical map analysis.
#'
#' Key properties:
#' - Distances along the central meridian are preserved
#' - Transverse cylindrical equidistant projection
#' - Not conformal (angles are not preserved)
#'
#' @seealso [utmups_fwd()] for UTM projection, [lcc_fwd()] for Lambert
#'   Conformal Conic
#'
#' @export
#'
#' @examples
#' # Project relative to a central meridian
#' pts <- cbind(lon = c(-100, -99, -101), lat = c(40, 41, 39))
#' cassini_fwd(pts, lon0 = -100, lat0 = 40)
#'
#' # Round-trip
#' fwd <- cassini_fwd(pts, lon0 = -100, lat0 = 40)
#' cassini_rev(fwd$x, fwd$y, lon0 = -100, lat0 = 40)
cassini_fwd <- function(x, lon0, lat0) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)

  lon <- x[, 1L, drop = TRUE]
  lat <- x[, 2L, drop = TRUE]

  cassini_fwd_cpp(lon, lat, lon0, lat0)
}

#' @rdname cassini_fwd
#' @export
cassini_rev <- function(x, y, lon0, lat0) {
  nn <- max(length(x), length(y))
  x <- rep_len(x, nn)
  y <- rep_len(y, nn)

  cassini_rev_cpp(x, y, lon0, lat0)
}
