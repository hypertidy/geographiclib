
#' Convert coordinates to/from Military Grid Reference System (MGRS)
#'
#' @description
#' Convert geographic coordinates (longitude/latitude) to MGRS grid reference
#' strings, or convert MGRS strings back to coordinates.
#'
#' @param x A two-column matrix or data frame of coordinates (longitude, latitude)
#'   in decimal degrees, or a list with longitude and latitude components.
#'   Can also be a length-2 numeric vector for a single point.
#' @param precision Integer between 0 and 5 (default 5) specifying the precision
#'   of the MGRS grid reference:
#'   * 0: 100 km precision
#'   * 1: 10 km precision
#'   * 2: 1 km precision
#'   * 3: 100 m precision
#'   * 4: 10 m precision
#'   * 5: 1 m precision (full precision)
#'
#'   Can be a vector to specify different precisions for each point.
#' @param code Character vector of MGRS grid reference strings to convert back
#'   to coordinates.
#'
#' @returns
#' * `mgrs_fwd()`: Character vector of MGRS grid reference strings
#' * `mgrs_rev()`: Data frame with columns:
#'   - `lon`: Longitude in decimal degrees
#'   - `lat`: Latitude in decimal degrees
#'   - `x`: Easting in meters (UTM/UPS projection)
#'   - `y`: Northing in meters (UTM/UPS projection)
#'   - `zone`: UTM zone number (0 for polar UPS regions)
#'   - `northp`: Logical, TRUE for northern hemisphere, FALSE for southern
#'   - `precision`: Integer precision level (0-5) encoded in the MGRS string
#'   - `convergence`: Meridian convergence in degrees (angle between true north and grid north)
#'   - `scale`: Scale factor at the point (dimensionless, typically near 1.0)
#'   - `grid_zone`: Grid zone designator (e.g., "51P", "04L")
#'   - `square_100km`: 100km square identifier (e.g., "SM", "GH")
#'   - `crs`: EPSG code string for the appropriate UTM/UPS projection
#'     (e.g., "EPSG:32755" for UTM zone 55S, "EPSG:32661" for UPS North)
#' @details
#' The Military Grid Reference System (MGRS) is a geocoordinate standard used
#' by NATO militaries for locating points on Earth. It is an alternative to
#' latitude/longitude that uses a hierarchical grid system.
#'
#' Both functions are fully vectorized. Missing values (NA) are not currently
#' supported.
#'
#' For polar regions (latitude > 84°N or < 80°S), the Universal Polar
#' Stereographic (UPS) system is used instead of UTM, indicated by zone = 0.
#'
#' @export
#'
#' @examples
#' # Single point conversion
#' (code <- mgrs_fwd(cbind(147.325, -42.881)))
#' mgrs_rev(code)
#'
#' # Multiple points with varying precision
#' x <- cbind(lon = c(-63.22, 34.02, 49.45, 45.67, 47.4),
#'            lat = c(17.62, -1.9, 37.47, 39.84, 33.15))
#' codes <- mgrs_fwd(x, precision = c(5, 4, 3, 2, 1))
#' codes
#'
#' # Reverse conversion returns detailed coordinate information
#' result <- mgrs_rev(codes)
#' result
#'
#' # Polar regions use UPS (zone 0)
#' polar_codes <- mgrs_fwd(cbind(c(147, -100), c(88, -88)))
#' mgrs_rev(polar_codes)
mgrs_fwd <- function(x, precision = 5L) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  precision <- as.integer(rep(precision, length.out = dim(x)[1L]))
  if (any(precision > 5 | precision < 0)) stop("precision values out of bounds, must be 0,1,2,3,4, or 5")
  mgrs_fwd_cpp(x[,1L, drop = TRUE], x[,2L, drop = TRUE], precision)
}


#' @rdname mgrs_fwd
#' @export
mgrs_rev <- function(code) {
  mgrs_rev_cpp(code)
}