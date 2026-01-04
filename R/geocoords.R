#' Parse and convert geographic coordinates
#'
#' @description
#' Parse coordinate strings in various formats (MGRS, UTM, DMS) and convert
#' between representations.
#'
#' @param x Character vector of coordinate strings to parse, or for conversion
#'   functions a two-column matrix of (longitude, latitude).
#' @param precision Integer precision for output strings (0-11 for MGRS).
#'
#' @returns
#' * `geocoords_parse()`: Data frame with columns lat, lon, zone, northp,
#'   easting, northing, convergence, scale
#' * `geocoords_to_mgrs()`: Character vector of MGRS strings
#' * `geocoords_to_utm()`: Character vector of UTM/UPS strings
#'
#' @details
#' The `geocoords_parse()` function accepts various input formats:
#' - MGRS codes: "33TWN0500049000", "33T 505000 4900000"
#' - UTM: "33N 505000 4900000"
#' - DMS: "44d 0' 0\" N 33d 0' 0\" E"
#' - Decimal: "44.0 33.0"
#'
#' @export
#' @examples
#' # Parse MGRS
#' geocoords_parse("33TWN0500049000")
#'
#' # Parse UTM
#' geocoords_parse("33N 505000 4900000")
#'
#' # Convert to MGRS
#' geocoords_to_mgrs(cbind(lon = c(147, -74), lat = c(-42, 40)))
geocoords_parse <- function(x) {
 geocoords_parse_cpp(as.character(x))
}

#' @rdname geocoords_parse
#' @export
geocoords_to_mgrs <- function(x, precision = 5L) {
  if (is.list(x) && !is.data.frame(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  
  lon <- x[, 1L, drop = TRUE]
  lat <- x[, 2L, drop = TRUE]
  precision <- as.integer(rep_len(precision, length(lat)))
  
  geocoords_to_mgrs_cpp(lat, lon, precision)
}

#' @rdname geocoords_parse
#' @export
geocoords_to_utm <- function(x, precision = 0L) {
  if (is.list(x) && !is.data.frame(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  
  lon <- x[, 1L, drop = TRUE]
  lat <- x[, 2L, drop = TRUE]
  precision <- as.integer(rep_len(precision, length(lat)))
  
  geocoords_to_utm_cpp(lat, lon, precision)
}