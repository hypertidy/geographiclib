#' Polar Stereographic projection
#'
#' @description
#' Convert geographic coordinates to/from Polar Stereographic projection.
#' This conformal projection is used for polar regions and is the basis
#' for the Universal Polar Stereographic (UPS) system.
#'
#' @param x For forward conversion: a two-column matrix or data frame of
#'   coordinates (longitude, latitude) in decimal degrees.
#'   For reverse conversion: numeric vector of x (easting) coordinates in meters.
#' @param y Numeric vector of y (northing) coordinates in meters (reverse only).
#' @param northp Logical indicating hemisphere: TRUE for north polar, FALSE for
#'   south polar. Can be a vector for different hemispheres per point.
#' @param k0 Scale factor at the pole. Default is 0.994 (UPS standard).
#'   Use k0 = 1 for true stereographic.
#'
#' @returns Data frame with columns:
#' * For forward conversion:
#'   - `x`: Easting in meters from pole
#'   - `y`: Northing in meters from pole
#'   - `convergence`: Grid convergence in degrees
#'   - `scale`: Scale factor at the point
#'   - `lon`, `lat`: Input coordinates (echoed)
#'   - `northp`: Hemisphere indicator (echoed)
#'
#' * For reverse conversion:
#'   - `lon`: Longitude in decimal degrees
#'   - `lat`: Latitude in decimal degrees
#'   - `convergence`: Grid convergence in degrees
#'   - `scale`: Scale factor at the point
#'   - `x`, `y`: Input coordinates (echoed)
#'   - `northp`: Hemisphere indicator (echoed)
#'
#' @details
#' The Polar Stereographic projection is a conformal azimuthal projection
#' centered on either pole. It is ideal for mapping polar regions because:
#' - It preserves local angles and shapes
#' - Directions from the pole are true
#' - Scale distortion is minimal near the pole
#'
#' **UPS (Universal Polar Stereographic)**
#' The default k0 = 0.994 corresponds to the UPS system used by:
#' - NATO military mapping
#' - EPSG:32661 (UPS North) and EPSG:32761 (UPS South)
#' - High-latitude extensions of UTM
#'
#' UPS is used for latitudes poleward of 84°N and 80°S.
#'
#' **Common scale factors:**
#' - k0 = 0.994: UPS standard
#' - k0 = 1.0: True stereographic (scale = 1 at pole)
#' - k0 = 0.97276901289: NSIDC Sea Ice Polar Stereographic
#'
#' @seealso [utmups_fwd()] for automatic UTM/UPS selection based on latitude.
#'
#' @export
#'
#' @examples
#' # Antarctic stations
#' stations <- cbind(
#'   lon = c(166.67, 77.97, -43.53, 0),
#'   lat = c(-77.85, -67.60, -60.72, -90)
#' )
#' polarstereo_fwd(stations, northp = FALSE)
#'
#' # Arctic points
#' arctic <- cbind(lon = c(0, 90, 180, -90), lat = c(85, 85, 85, 85))
#' polarstereo_fwd(arctic, northp = TRUE)
#'
#' # True stereographic (k0 = 1)
#' polarstereo_fwd(stations, northp = FALSE, k0 = 1.0)
#'
#' # NSIDC Sea Ice projection
#' polarstereo_fwd(stations, northp = FALSE, k0 = 0.97276901289)
#'
#' # South Pole is at origin
#' sp <- polarstereo_fwd(c(0, -90), northp = FALSE)
#' sp$x  # 0
#' sp$y  # 0
#'
#' # Round-trip conversion
#' fwd <- polarstereo_fwd(stations, northp = FALSE)
#' polarstereo_rev(fwd$x, fwd$y, northp = FALSE)
polarstereo_fwd <- function(x, northp, k0 = 0.994) {
  if (is.list(x) && !is.data.frame(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  
  lon <- x[, 1L, drop = TRUE]
  lat <- x[, 2L, drop = TRUE]
  
  nn <- length(lon)
  northp <- as.logical(rep_len(northp, nn))
  
  polarstereo_fwd_custom_cpp(lon, lat, northp, k0)
}

#' @rdname polarstereo_fwd
#' @export
polarstereo_rev <- function(x, y, northp, k0 = 0.994) {
  nn <- max(length(x), length(y), length(northp))
  x <- rep_len(x, nn)
  y <- rep_len(y, nn)
  northp <- as.logical(rep_len(northp, nn))
  
  polarstereo_rev_custom_cpp(x, y, northp, k0)
}
