#' Azimuthal Equidistant projection
#'
#' @description
#' Convert geographic coordinates to/from Azimuthal Equidistant projection
#' centered on a specified point. This projection preserves distances from
#' the center point.
#'
#' @param x For forward conversion: a two-column matrix or data frame of
#'   coordinates (longitude, latitude) in decimal degrees.
#'   For reverse conversion: numeric vector of x coordinates in meters.
#' @param y Numeric vector of y coordinates in meters (for reverse conversion).
#' @param lon0 Longitude of projection center in decimal degrees. Can be a
#'   vector to specify different centers for each point.
#' @param lat0 Latitude of projection center in decimal degrees. Can be a
#'   vector to specify different centers for each point.
#'
#' @returns Data frame with columns:
#' * For forward conversion:
#'   - `x`: Easting in meters from center
#'   - `y`: Northing in meters from center
#'   - `azi`: Azimuth from center to point (degrees)
#'   - `scale`: Scale factor at the point
#'   - `lon`, `lat`: Input coordinates (echoed)
#'   - `lon0`, `lat0`: Center coordinates (echoed)
#'
#' * For reverse conversion:
#'   - `lon`: Longitude in decimal degrees
#'   - `lat`: Latitude in decimal degrees
#'   - `azi`: Azimuth from center to point (degrees)
#'   - `scale`: Scale factor at the point
#'   - `x`, `y`: Input coordinates (echoed)
#'   - `lon0`, `lat0`: Center coordinates (echoed)
#'
#' @details
#' The Azimuthal Equidistant projection shows all points at their true distance
#' and direction from the center point. It is commonly used for:
#' - Radio/telecommunications range maps
#' - Seismic wave propagation studies
#' - Air route distance calculations
#' - UN emblem (centered on North Pole)
#'
#' The projection is neither conformal nor equal-area, but distances from the
#' center are preserved exactly.
#'
#' All parameters (`x`, `lon0`, `lat0`) are vectorized and recycled to a
#' common length, allowing different projection centers for each point.
#'
#' @export
#'
#' @examples
#' # Project cities relative to Sydney
#' cities <- cbind(
#'   lon = c(-74, 139.7, 0),
#'   lat = c(40.7, 35.7, 51.5)
#' )
#' azeq_fwd(cities, lon0 = 151.2, lat0 = -33.9)
#'
#' # Distance from Sydney = sqrt(x^2 + y^2)
#' result <- azeq_fwd(cities, lon0 = 151.2, lat0 = -33.9)
#' sqrt(result$x^2 + result$y^2) / 1000  # km
#'
#' # Different center for each point (e.g., distance from home city)
#' homes <- cbind(lon = c(151.2, 139.7, -0.1), lat = c(-33.9, 35.7, 51.5))
#' destinations <- cbind(lon = c(-74, -74, -74), lat = c(40.7, 40.7, 40.7))
#' azeq_fwd(destinations, lon0 = homes[,1], lat0 = homes[,2])
azeq_fwd <- function(x, lon0, lat0) {
  if (is.list(x) && !is.data.frame(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  
  lon <- x[, 1L, drop = TRUE]
  lat <- x[, 2L, drop = TRUE]
  
  # Recycle all inputs to common length
  nn <- max(length(lon), length(lon0), length(lat0))
  lon <- rep_len(lon, nn)
  lat <- rep_len(lat, nn)
  lon0 <- rep_len(lon0, nn)
  lat0 <- rep_len(lat0, nn)
  
  azimuthaleq_fwd_cpp(lon, lat, lon0, lat0)
}

#' @rdname azeq_fwd
#' @export
azeq_rev <- function(x, y, lon0, lat0) {
  # Recycle all inputs to common length
  nn <- max(length(x), length(y), length(lon0), length(lat0))
  x <- rep_len(x, nn)
  y <- rep_len(y, nn)
  lon0 <- rep_len(lon0, nn)
  lat0 <- rep_len(lat0, nn)
  
  azimuthaleq_rev_cpp(x, y, lon0, lat0)
}
