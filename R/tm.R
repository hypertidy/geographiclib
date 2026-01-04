#' Transverse Mercator projection
#'
#' @description
#' Convert geographic coordinates to/from Transverse Mercator projection
#' with user-specified central meridian and scale factor.
#'
#' Two versions are provided:
#' - `tm_fwd()`/`tm_rev()`: Series approximation, fast, accurate to ~5 nanometers
#' - `tm_exact_fwd()`/`tm_exact_rev()`: Exact formulation, slower but accurate everywhere
#'
#' @param x For forward conversion: a two-column matrix or data frame of
#'   coordinates (longitude, latitude) in decimal degrees.
#'   For reverse conversion: numeric vector of x (easting) coordinates in meters.
#' @param y Numeric vector of y (northing) coordinates in meters (reverse only).
#' @param lon0 Central meridian in decimal degrees. Can be a vector to specify
#'   different central meridians for each point.
#' @param k0 Scale factor on the central meridian. Default is 0.9996 (UTM).
#'   Common values: 0.9996 (UTM), 1.0 (many national grids), 0.9999 (some state planes).
#'
#' @returns Data frame with columns:
#' * For forward conversion:
#'   - `x`: Easting in meters
#'   - `y`: Northing in meters
#'   - `convergence`: Grid convergence in degrees
#'   - `scale`: Scale factor at the point
#'   - `lon`, `lat`: Input coordinates (echoed)
#'   - `lon0`: Central meridian (echoed)
#'
#' * For reverse conversion:
#'   - `lon`: Longitude in decimal degrees
#'   - `lat`: Latitude in decimal degrees
#'   - `convergence`: Grid convergence in degrees
#'   - `scale`: Scale factor at the point
#'   - `x`, `y`: Input coordinates (echoed)
#'   - `lon0`: Central meridian (echoed)
#'
#' @details
#' The Transverse Mercator projection is a conformal cylindrical projection
#' commonly used for:
#' - UTM (Universal Transverse Mercator) zones
#' - Many national and state coordinate systems
#' - Large-scale topographic mapping
#'
#' Unlike `utmups_fwd()` which automatically selects UTM zones, these functions
#' allow you to specify any central meridian and scale factor.
#'
#' The series approximation (`tm_fwd`/`tm_rev`) is accurate to ~5 nanometers
#' within 3900 km of the central meridian. The exact version
#' (`tm_exact_fwd`/`tm_exact_rev`) is slower but works accurately everywhere.
#'
#' The `lon0` parameter is vectorized, allowing different central meridians
#' for each point (useful for processing data across multiple zones).
#'
#' @seealso [utmups_fwd()] for automatic UTM zone selection.
#'
#' @export
#'
#' @examples
#' # Basic Transverse Mercator (like UTM zone 55)
#' pts <- cbind(lon = c(147, 148, 149), lat = c(-42, -43, -44))
#' tm_fwd(pts, lon0 = 147, k0 = 0.9996)
#'
#' # Compare with UTM
#' utmups_fwd(pts)
#'
#' # Custom scale factor (k0 = 1.0)
#' tm_fwd(pts, lon0 = 147, k0 = 1.0)
#'
#' # Different central meridian for each point
#' tm_fwd(pts, lon0 = c(147, 148, 149), k0 = 0.9996)
#'
#' # Round-trip conversion
#' fwd <- tm_fwd(pts, lon0 = 147, k0 = 0.9996)
#' tm_rev(fwd$x, fwd$y, lon0 = 147, k0 = 0.9996)
#'
#' # Exact version for high precision or extreme locations
#' tm_exact_fwd(pts, lon0 = 147, k0 = 0.9996)
tm_fwd <- function(x, lon0, k0 = 0.9996) {
  if (is.list(x) && !is.data.frame(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  
  lon <- x[, 1L, drop = TRUE]
  lat <- x[, 2L, drop = TRUE]
  
  # Recycle lon0 to match coordinate length
  nn <- length(lon)
  lon0 <- rep_len(lon0, nn)
  
  tm_fwd_cpp(lon, lat, lon0, k0)
}

#' @rdname tm_fwd
#' @export
tm_rev <- function(x, y, lon0, k0 = 0.9996) {
  nn <- max(length(x), length(y), length(lon0))
  x <- rep_len(x, nn)
  y <- rep_len(y, nn)
  lon0 <- rep_len(lon0, nn)
  
  tm_rev_cpp(x, y, lon0, k0)
}

#' @rdname tm_fwd
#' @export
tm_exact_fwd <- function(x, lon0, k0 = 0.9996) {
  if (is.list(x) && !is.data.frame(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  
  lon <- x[, 1L, drop = TRUE]
  lat <- x[, 2L, drop = TRUE]
  
  nn <- length(lon)
  lon0 <- rep_len(lon0, nn)
  
  tm_exact_fwd_cpp(lon, lat, lon0, k0)
}

#' @rdname tm_fwd
#' @export
tm_exact_rev <- function(x, y, lon0, k0 = 0.9996) {
  nn <- max(length(x), length(y), length(lon0))
  x <- rep_len(x, nn)
  y <- rep_len(y, nn)
  lon0 <- rep_len(lon0, nn)
  
  tm_exact_rev_cpp(x, y, lon0, k0)
}
