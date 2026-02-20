#' Local Cartesian (ENU) coordinate system
#'
#' @description
#' Convert between geographic coordinates and a local Cartesian coordinate
#' system centered at a specified origin. The local system uses East-North-Up
#' (ENU) axes.
#'
#' @param x For forward conversion: a two-column matrix or data frame of
#'   coordinates (longitude, latitude) in decimal degrees, or a list with
#'   longitude and latitude components. Can also be a length-2 numeric vector
#'   for a single point.
#'   For reverse conversion: numeric vector of x (east) coordinates in meters.
#' @param y Numeric vector of y (north) coordinates in meters.
#' @param z Numeric vector of z (up) coordinates in meters.
#' @param h Numeric vector of heights above the ellipsoid in meters. Default is 0.
#' @param lon0 Longitude of the origin in decimal degrees.
#' @param lat0 Latitude of the origin in decimal degrees.
#' @param h0 Height of the origin above the ellipsoid in meters. Default is 0.
#'
#' @returns
#' * `localcartesian_fwd()`: Data frame with columns:
#'   - `x`: East coordinate in meters
#'   - `y`: North coordinate in meters
#'   - `z`: Up coordinate in meters
#'   - `lon`, `lat`, `h`: Input coordinates (echoed)
#'
#' * `localcartesian_rev()`: Data frame with columns:
#'   - `lon`: Longitude in decimal degrees
#'   - `lat`: Latitude in decimal degrees
#'   - `h`: Height above ellipsoid in meters
#'   - `x`, `y`, `z`: Input coordinates (echoed)
#'
#' @details
#' The local Cartesian coordinate system is useful for:
#' - Local surveys where a flat Earth approximation is valid
#' - Converting GPS positions to a local reference frame
#' - Robotics and navigation applications
#'
#' The coordinate system is:
#' - **x**: positive east
#' - **y**: positive north
#' - **z**: positive up (away from Earth's center)
#'
#' This is also known as an ENU (East-North-Up) coordinate system.
#'
#' @seealso [geocentric_fwd()] for Earth-Centered Earth-Fixed (ECEF) coordinates
#'
#' @export
#'
#' @examples
#' # Set up local system centered on London
#' london <- c(-0.1, 51.5)
#'
#' # Convert nearby points to local coordinates
#' pts <- cbind(
#'   lon = c(-0.1, -0.2, 0.0),
#'   lat = c(51.5, 51.6, 51.4)
#' )
#' localcartesian_fwd(pts, lon0 = london[1], lat0 = london[2])
#'
#' # Round-trip conversion
#' fwd <- localcartesian_fwd(pts, lon0 = -0.1, lat0 = 51.5)
#' localcartesian_rev(fwd$x, fwd$y, fwd$z, lon0 = -0.1, lat0 = 51.5)
localcartesian_fwd <- function(x, lon0, lat0, h = 0, h0 = 0) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)

  nn <- nrow(x)
  lon <- x[, 1L, drop = TRUE]
  lat <- x[, 2L, drop = TRUE]
  h <- rep_len(h, nn)

  localcartesian_fwd_cpp(lon, lat, h, lon0, lat0, h0)
}

#' @rdname localcartesian_fwd
#' @export
localcartesian_rev <- function(x, y, z, lon0, lat0, h0 = 0) {
  nn <- max(length(x), length(y), length(z))
  x <- rep_len(x, nn)
  y <- rep_len(y, nn)
  z <- rep_len(z, nn)

  localcartesian_rev_cpp(x, y, z, lon0, lat0, h0)
}
