#' Convert between geodetic and geocentric (ECEF) coordinates
#'
#' @description
#' Convert geographic coordinates (longitude/latitude/height) to geocentric
#' Earth-Centered Earth-Fixed (ECEF) Cartesian coordinates (X/Y/Z), or convert
#' ECEF coordinates back to geographic coordinates.
#'
#' @param x For forward conversion: a two or three-column matrix or data frame
#'   of coordinates (longitude, latitude) or (longitude, latitude, height) in
#'   decimal degrees and meters. Can also be a list with lon, lat, and
#'   optionally h components.
#'   For reverse conversion: numeric vector of X coordinates in meters.
#' @param y Numeric vector of Y coordinates in meters for reverse conversion.
#' @param z Numeric vector of Z coordinates in meters for reverse conversion.
#' @param h Numeric vector of heights above the ellipsoid in meters. Default is 0.
#'
#' @returns Data frame with columns:
#' * For forward conversion:
#'   - `X`, `Y`, `Z`: Geocentric ECEF coordinates in meters
#'   - `lon`, `lat`, `h`: Input coordinates (echoed)
#'
#' * For reverse conversion:
#'   - `lon`: Longitude in decimal degrees
#'   - `lat`: Latitude in decimal degrees
#'   - `h`: Height above ellipsoid in meters
#'   - `X`, `Y`, `Z`: Input coordinates (echoed)
#'
#' @details
#' The geocentric coordinate system (also called ECEF - Earth-Centered
#' Earth-Fixed) is a Cartesian coordinate system with:
#' - Origin at the Earth's center of mass
#' - X-axis pointing to the intersection of the equator and prime meridian
#' - Y-axis pointing to the intersection of the equator and 90°E
#' - Z-axis pointing to the North Pole
#'
#' This coordinate system is commonly used in GPS and satellite applications.
#' All calculations use the WGS84 ellipsoid.
#'
#' @seealso [utmups_fwd()] for projected coordinates.
#'
#' @export
#'
#' @examples
#' # Convert London to ECEF
#' geocentric_fwd(c(-0.1, 51.5))
#'
#' # With height
#' geocentric_fwd(c(-0.1, 51.5), h = 100)
#'
#' # Multiple points
#' pts <- cbind(lon = c(0, 90, -90), lat = c(0, 0, 0))
#' geocentric_fwd(pts)
#'
#' # Round-trip
#' fwd <- geocentric_fwd(c(-0.1, 51.5, 100))
#' geocentric_rev(fwd$X, fwd$Y, fwd$Z)
geocentric_fwd <- function(x, h = 0) {
  if (is.list(x) ) {
    if (!is.null(x$h)) h <- x$h
    x <- do.call(cbind, x[c("lon", "lat")])
  }
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  if (length(x) == 3) {
    h <- x[3]
    x <- matrix(x[1:2], ncol = 2)
  }

  nn <- nrow(x)
  h <- rep_len(h, nn)

  geocentric_fwd_cpp(x[, 1L, drop = TRUE], x[, 2L, drop = TRUE], h)
}

#' @rdname geocentric_fwd
#' @export
geocentric_rev <- function(x, y, z) {
  nn <- max(length(x), length(y), length(z))
  x <- rep_len(x, nn)
  y <- rep_len(y, nn)
  z <- rep_len(z, nn)

  geocentric_rev_cpp(x, y, z)
}
