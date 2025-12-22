#' Gnomonic projection
#'
#' @description
#' Convert between geographic coordinates and the gnomonic projection.
#' In this projection, geodesics (shortest paths) appear as straight lines,
#' making it useful for navigation and great circle route planning.
#'
#' @param x For forward conversion: a two-column matrix or data frame of
#'   coordinates (longitude, latitude) in decimal degrees.
#'   For reverse conversion: numeric vector of x coordinates in meters.
#' @param y Numeric vector of y coordinates in meters.
#' @param lon0 Longitude of the projection center in decimal degrees.
#' @param lat0 Latitude of the projection center in decimal degrees.
#'
#' @returns Data frame with columns:
#' * For forward conversion:
#'   - `x`: X coordinate in meters
#'   - `y`: Y coordinate in meters
#'   - `azi`: Azimuth of the geodesic at the center (degrees)
#'   - `rk`: Reciprocal of the azimuthal scale
#'   - `lon`, `lat`: Input coordinates (echoed)
#'
#' * For reverse conversion:
#'   - `lon`: Longitude in decimal degrees
#'   - `lat`: Latitude in decimal degrees
#'   - `azi`: Azimuth of the geodesic at the center (degrees)
#'   - `rk`: Reciprocal of the azimuthal scale
#'   - `x`, `y`: Input coordinates (echoed)
#'
#' @details
#' The gnomonic projection has a unique property: all geodesics (great circles
#' on a sphere, shortest paths on an ellipsoid) appear as straight lines.
#' This makes it invaluable for:
#' - Planning great circle routes in aviation and shipping
#' - Seismic ray path analysis
#' - Radio wave propagation studies
#'
#' Limitations:
#' - Can only show less than a hemisphere
#' - Extreme distortion away from the center
#' - Neither conformal nor equal-area
#'
#' @seealso [azeq_fwd()] for azimuthal equidistant projection
#'
#' @export
#'
#' @examples
#' # Project cities relative to London
#' cities <- cbind(
#'   lon = c(-74, 139.7, 151.2, 2.3),
#'   lat = c(40.7, 35.7, -33.9, 48.9)
#' )
#' gnomonic_fwd(cities, lon0 = -0.1, lat0 = 51.5)
#'
#' # Great circle route appears as straight line
#' # London to NYC path
#' path <- geodesic_path(c(-0.1, 51.5), c(-74, 40.7), n = 10)
#' projected <- gnomonic_fwd(cbind(path$lon, path$lat), lon0 = -37, lat0 = 46)
#' # x and y should be approximately linear
#' plot(projected$x, projected$y, type = "l")
gnomonic_fwd <- function(x, lon0, lat0) {
  if (is.list(x) && !is.data.frame(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  
  lon <- x[, 1L, drop = TRUE]
  lat <- x[, 2L, drop = TRUE]
  
  gnomonic_fwd_cpp(lon, lat, lon0, lat0)
}

#' @rdname gnomonic_fwd
#' @export
gnomonic_rev <- function(x, y, lon0, lat0) {
  nn <- max(length(x), length(y))
  x <- rep_len(x, nn)
  y <- rep_len(y, nn)
  
  gnomonic_rev_cpp(x, y, lon0, lat0)
}
