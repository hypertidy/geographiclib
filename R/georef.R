#' World Geographic Reference System (Georef)
#'
#' @description
#' Convert geographic coordinates (longitude/latitude) to World Geographic
#' Reference System (Georef) codes, or convert Georef codes back to coordinates.
#'
#' @param x A two-column matrix or data frame of coordinates (longitude, latitude)
#'   in decimal degrees, or a list with longitude and latitude components.
#'   Can also be a length-2 numeric vector for a single point.
#' @param precision Integer specifying the precision level (-1 to 11):
#'   * -1: 15-degree cells (2-character code)
#'   * 0: 1-degree cells (4-character code)
#'   * 1: 1-minute cells (6-character code)
#'   * 2: 0.1-minute cells (8-character code)
#'   * Higher values give progressively finer precision
#' @param georef Character vector of Georef codes to convert back to coordinates.
#'
#' @returns
#' * `georef_fwd()`: Character vector of Georef codes.
#'
#' * `georef_rev()`: Data frame with columns:
#'   - `lon`: Longitude of cell center in decimal degrees
#'   - `lat`: Latitude of cell center in decimal degrees
#'   - `precision`: Precision level
#'   - `lat_resolution`: Cell half-height in degrees
#'   - `lon_resolution`: Cell half-width in degrees
#'
#' @details
#' The World Geographic Reference System (Georef) is a grid-based geocode
#' system used primarily for air navigation. It was developed by the US
#' and adopted by ICAO (International Civil Aviation Organization).
#'
#' The Georef code structure:
#' - First letter: 15° longitude band (A-Z, omitting I and O)
#' - Second letter: 15° latitude band (A-M, omitting I)
#' - Third letter: 1° longitude within band (A-Q, omitting I and O)
#' - Fourth letter: 1° latitude within band (A-Q, omitting I and O)
#' - Remaining digits: minutes (and fractions) of longitude and latitude
#'
#' Example: "GJPJ3217" represents approximately (0.54°, 51.28°)
#'
#' @seealso [gars_fwd()] for Global Area Reference System, [mgrs_fwd()] for
#'   Military Grid Reference System.
#'
#' @export
#'
#' @examples
#' # Basic conversion
#' georef_fwd(c(-0.1, 51.5))
#'
#' # Different precision levels
#' georef_fwd(c(-0.1, 51.5), precision = -1)  # 15-degree
#' georef_fwd(c(-0.1, 51.5), precision = 0)   # 1-degree
#' georef_fwd(c(-0.1, 51.5), precision = 1)   # 1-minute
#' georef_fwd(c(-0.1, 51.5), precision = 2)   # 0.1-minute
#'
#' # Multiple points
#' pts <- cbind(lon = c(-74, 139.7, 0), lat = c(40.7, 35.7, 51.5))
#' georef_fwd(pts)
#'
#' # Reverse conversion
#' georef_rev(c("GJPJ3217", "SKNA2342", "FJBL0630"))
georef_fwd <- function(x, precision = 2L) {
  if (is.list(x) && !is.data.frame(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  
  nn <- nrow(x)
  precision <- as.integer(rep_len(precision, nn))
  
  if (any(precision < -1 | precision > 11)) {
    stop("precision must be between -1 and 11")
  }
  
  georef_fwd_cpp(x[, 1L, drop = TRUE], x[, 2L, drop = TRUE], precision)
}

#' @rdname georef_fwd
#' @export
georef_rev <- function(georef) {
  georef_rev_cpp(georef)
}
