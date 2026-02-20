#' Convert coordinates to/from Geohash
#'
#' @description
#' Convert geographic coordinates (longitude/latitude) to Geohash strings,
#' or convert Geohash strings back to coordinates.
#'
#' @param x A two-column matrix or data frame of coordinates (longitude, latitude)
#'   in decimal degrees, or a list with longitude and latitude components.
#'   Can also be a length-2 numeric vector for a single point.
#' @param len Integer specifying the length of the Geohash string (1-18).
#'   Default is 12, which gives approximately 19mm precision. Can be a vector
#'   to specify different lengths for each point.
#' @param geohash Character vector of Geohash strings to convert back to coordinates.
#' @param resolution Numeric. Desired resolution in degrees for `geohash_length()`.
#' @param lat_resolution Numeric. Desired latitude resolution in degrees.
#' @param lon_resolution Numeric. Desired longitude resolution in degrees.
#'
#' @returns
#' * `geohash_fwd()`: Character vector of Geohash strings.
#'
#' * `geohash_rev()`: Data frame with columns:
#'   - `lon`: Longitude in decimal degrees (center of cell)
#'   - `lat`: Latitude in decimal degrees (center of cell)
#'   - `len`: Length of the Geohash string
#'   - `lat_resolution`: Latitude resolution in degrees (half-height of cell)
#'   - `lon_resolution`: Longitude resolution in degrees (half-width of cell)
#'
#' * `geohash_resolution()`: Data frame with columns:
#'   - `len`: Geohash length
#'   - `lat_resolution`: Latitude resolution in degrees
#'   - `lon_resolution`: Longitude resolution in degrees
#'
#' * `geohash_length()`: Integer, minimum Geohash length to achieve the
#'   specified resolution.
#'
#' @details
#' Geohash is a geocoding system that encodes geographic coordinates into a
#' short string of letters and digits. It has a useful property: truncating
#' a Geohash reduces precision but the truncated code still refers to a
#' location containing the original point.
#'
#' The Geohash length determines precision:
#' - Length 1: ~5000 km
#' - Length 4: ~20 km
#' - Length 6: ~610 m
#' - Length 8: ~19 m
#' - Length 10: ~0.6 m
#' - Length 12: ~19 mm (default)
#' - Length 18: ~0.0001 mm (maximum)
#'
#' Both `geohash_fwd()` and `geohash_rev()` are fully vectorized.
#'
#' @seealso [mgrs_fwd()] for Military Grid Reference System encoding,
#'   which provides a different grid-based coordinate system.
#'
#' @export
#'
#' @examples
#' # Single point conversion
#' (gh <- geohash_fwd(c(147.325, -42.881)))
#' geohash_rev(gh)
#'
#' # Multiple points with varying precision
#' pts <- cbind(
#'   lon = c(147, -74, 0),
#'   lat = c(-42, 40.7, 51.5)
#' )
#' geohash_fwd(pts, len = c(6, 8, 12))
#'
#' # Truncation preserves containment
#' gh <- geohash_fwd(c(147.325, -42.881), len = 12)
#' substr(gh, 1, 6)  # Lower precision, but still contains original point
#'
#' # Resolution for different lengths
#' geohash_resolution(1:12)
#'
#' # Find length needed for ~1km precision
#' geohash_length(1/111)  # ~1 degree / 111 km
geohash_fwd <- function(x, len = 12L) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)

  nn <- nrow(x)
  len <- as.integer(rep_len(len, nn))

  if (any(len < 1 | len > 18)) {
    stop("len must be between 1 and 18")
  }

  geohash_fwd_cpp(x[, 1L, drop = TRUE], x[, 2L, drop = TRUE], len)
}

#' @rdname geohash_fwd
#' @export
geohash_rev <- function(geohash) {
  geohash_rev_cpp(geohash)
}

#' @rdname geohash_fwd
#' @export
geohash_resolution <- function(len) {
  len <- as.integer(len)
  if (any(len < 1 | len > 18)) {
    stop("len must be between 1 and 18")
  }
  geohash_resolution_cpp(len)
}

#' @rdname geohash_fwd
#' @export
geohash_length <- function(resolution = NULL, lat_resolution = NULL, lon_resolution = NULL) {
  if (!is.null(resolution)) {
    return(geohash_length_for_precision_cpp(resolution))
  }
  if (!is.null(lat_resolution) && !is.null(lon_resolution)) {
    return(geohash_length_for_precisions_cpp(lat_resolution, lon_resolution))
  }
  stop("Specify either 'resolution' or both 'lat_resolution' and 'lon_resolution'")
}
