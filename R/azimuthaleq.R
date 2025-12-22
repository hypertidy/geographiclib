#' Azimuthal Equidistant projection
#'
#' @description
#' Convert geographic coordinates (longitude/latitude) to Azimuthal Equidistant
#' projected coordinates, or convert projected coordinates back to geographic
#' coordinates. The projection is centered on a specified point.
#'
#' @param x For forward conversion: a two-column matrix or data frame of
#'   coordinates (longitude, latitude) in decimal degrees.
#'   For reverse conversion: numeric vector of x coordinates in meters.
#' @param y Numeric vector of y coordinates in meters for reverse conversion.
#' @param lon0 Longitude of the projection center in decimal degrees.
#' @param lat0 Latitude of the projection center in decimal degrees.
#'
#' @returns Data frame with columns:
#' * For forward conversion:
#'   - `x`, `y`: Projected coordinates in meters
#'   - `azi`: Azimuth from center to point (degrees)
#'   - `scale`: Scale factor at the point
#'   - `lon`, `lat`: Input coordinates (echoed)
#'
#' * For reverse conversion:
#'   - `lon`, `lat`: Geographic coordinates in decimal degrees
#'   - `azi`: Azimuth from center to point (degrees)
#'   - `scale`: Scale factor at the point
#'   - `x`, `y`: Input coordinates (echoed)
#'
#' @details
#' The Azimuthal Equidistant projection preserves distances and directions
#' from the center point. Key properties:
#'
#' - All points at the same distance from the center lie on a circle
#' - All directions from the center are correct
#' - Scale is 1 along radial lines from the center
#' - Scale increases perpendicular to radial lines
#'
#' This projection is commonly used for:
#' - Airline route maps centered on a hub city
#' - Seismic monitoring (distances from epicenter)
#' - Radio/communications coverage maps
#' - UN emblem (polar aspect)
#'
#' All calculations use the WGS84 ellipsoid with exact geodesic calculations.
#'
#' @seealso [geodesic_direct()] for calculating destinations along azimuths.
#'
#' @export
#'
#' @examples
#' # Project points relative to London
#' pts <- cbind(lon = c(-74, 139.7, 151.2), lat = c(40.7, 35.7, -33.9))
#' azeq_fwd(pts, lon0 = -0.1, lat0 = 51.5)
#'
#' # Distance from center equals sqrt(x^2 + y^2)
#' result <- azeq_fwd(c(-74, 40.7), lon0 = -0.1, lat0 = 51.5)
#' sqrt(result$x^2 + result$y^2)  # Distance in meters
#'
#' # Round-trip conversion
#' fwd <- azeq_fwd(pts, lon0 = -0.1, lat0 = 51.5)
#' azeq_rev(fwd$x, fwd$y, lon0 = -0.1, lat0 = 51.5)
azeq_fwd <- function(x, lon0, lat0) {
  if (is.list(x) && !is.data.frame(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  
  azimuthaleq_fwd_cpp(x[, 1L, drop = TRUE], x[, 2L, drop = TRUE], lon0, lat0)
}

#' @rdname azeq_fwd
#' @export
azeq_rev <- function(x, y, lon0, lat0) {
  nn <- max(length(x), length(y))
  x <- rep_len(x, nn)
  y <- rep_len(y, nn)
  
  azimuthaleq_rev_cpp(x, y, lon0, lat0)
}
