#' Convert coordinates to/from UTM/UPS projection
#'
#' @description
#' Convert geographic coordinates (longitude/latitude) to UTM or UPS projected
#' coordinates, or convert projected coordinates back to geographic coordinates.
#'
#' @param x A two-column matrix or data frame of coordinates (longitude, latitude)
#'   in decimal degrees for forward conversion, or a list with longitude and 
#'   latitude components. Can also be a length-2 numeric vector for a single point.
#' @param easting Numeric vector of easting values (x coordinates) in meters for 
#'   reverse conversion.
#' @param northing Numeric vector of northing values (y coordinates) in meters for 
#'   reverse conversion.
#' @param zone Integer vector of UTM zone numbers (1-60) or 0 for UPS (polar regions).
#' @param northp Logical vector indicating hemisphere: TRUE for northern hemisphere,
#'   FALSE for southern hemisphere.
#'
#' @returns
#' * `utmups_fwd()`: Data frame with columns:
#'   - `x`: Easting in meters
#'   - `y`: Northing in meters
#'   - `zone`: UTM zone number (1-60) or 0 for UPS
#'   - `northp`: Logical, TRUE for northern hemisphere
#'   - `convergence`: Meridian convergence in degrees (angle between true north and grid north)
#'   - `scale`: Scale factor at the point (dimensionless, typically near 1.0)
#'   - `lon`: Longitude in decimal degrees (echoed from input)
#'   - `lat`: Latitude in decimal degrees (echoed from input)
#'   - `crs`: EPSG code string for the UTM/UPS projection
#' 
#' * `utmups_rev()`: Data frame with columns:
#'   - `lon`: Longitude in decimal degrees
#'   - `lat`: Latitude in decimal degrees
#'   - `x`: Easting in meters (echoed from input)
#'   - `y`: Northing in meters (echoed from input)
#'   - `zone`: UTM zone number (echoed from input)
#'   - `northp`: Hemisphere indicator (echoed from input)
#'   - `convergence`: Meridian convergence in degrees
#'   - `scale`: Scale factor at the point
#'   - `crs`: EPSG code string for the UTM/UPS projection
#'
#' @details
#' The Universal Transverse Mercator (UTM) system divides the Earth into 60
#' zones, each 6 degrees of longitude wide. For polar regions (latitude > 84°N 
#' or < 80°S), the Universal Polar Stereographic (UPS) system is used instead,
#' indicated by zone = 0.
#'
#' Both functions are fully vectorized. Missing values (NA) are not currently
#' supported.
#'
#' The convergence angle represents the angle between true north and grid north
#' at a point. The scale factor represents the ratio of the scale along a line
#' to the scale on the reference surface (typically very close to 1.0).
#'
#' @export
#'
#' @examples
#' # Single point forward conversion
#' result <- utmups_fwd(c(147.325, -42.881))
#' result
#'
#' # Multiple points
#' pts <- cbind(lon = c(147, 148, -100, 0),
#'              lat = c(-42, -43, -42, 0))
#' utmups_fwd(pts)
#'
#' # Reverse conversion
#' utmups_rev(result$x, result$y, result$zone, result$northp)
#'
#' # Round-trip conversion
#' fwd <- utmups_fwd(pts)
#' rev <- utmups_rev(fwd$x, fwd$y, fwd$zone, fwd$northp)
#' cbind(original = pts, converted = rev[, c("lon", "lat")])
#'
#' # Polar regions use UPS (zone 0)
#' polar <- cbind(c(147, 148, -100), c(88, -88, -85))
#' utmups_fwd(polar)
utmups_fwd <- function(x) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  utmups_fwd_cpp(x[, 1L, drop = TRUE], x[, 2L, drop = TRUE])
}

#' @rdname utmups_fwd
#' @export
utmups_rev <- function(easting, northing, zone, northp) {
  # Ensure all inputs have same length
  nn <- max(length(easting), length(northing), length(zone), length(northp))
  easting <- rep_len(easting, nn)
  northing <- rep_len(northing, nn)
  zone <- as.integer(rep_len(zone, nn))
  northp <- as.logical(rep_len(northp, nn))
  
  utmups_rev_cpp(easting, northing, zone, northp)
}