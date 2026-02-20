#' Ordnance Survey National Grid (Great Britain)
#'
#' @description
#' Convert between geographic coordinates and the Ordnance Survey
#' National Grid used in Great Britain.
#'
#' **Important:** These functions expect coordinates on the OSGB36 datum,
#' not WGS84. For WGS84 coordinates (e.g., from GPS), you need to perform
#' a datum transformation first using another package such as sf.
#'
#' @param x For `osgb_fwd()` and `osgb_gridref()`: a two-column matrix or
#'   data frame of OSGB36 coordinates (longitude, latitude) in decimal degrees.
#' @param easting Numeric vector of OSGB eastings in meters.
#' @param northing Numeric vector of OSGB northings in meters.
#' @param gridref Character vector of OSGB grid reference strings.
#' @param precision Integer specifying the precision of grid references:
#'   - -1: 500 km squares (first letter only)
#'   - 0: 100 km squares (two letters)
#'   - 1: 10 km (2 digits)
#'   - 2: 1 km (4 digits)
#'   - 3: 100 m (6 digits)
#'   - 4: 10 m (8 digits)
#'   - 5: 1 m (10 digits)
#'
#' @returns
#' * `osgb_fwd()`: Data frame with columns:
#'   - `easting`: OSGB easting in meters
#'   - `northing`: OSGB northing in meters
#'   - `convergence`: Grid convergence in degrees
#'   - `scale`: Scale factor
#'   - `lon`, `lat`: Input OSGB36 coordinates (echoed)
#'
#' * `osgb_rev()`: Data frame with columns:
#'   - `lon`: OSGB36 longitude in decimal degrees
#'   - `lat`: OSGB36 latitude in decimal degrees
#'   - `convergence`: Grid convergence in degrees
#'   - `scale`: Scale factor
#'   - `easting`, `northing`: Input coordinates (echoed)
#'
#' * `osgb_gridref()`: Character vector of grid reference strings.
#'
#' * `osgb_gridref_rev()`: Data frame with columns:
#'   - `lon`: OSGB36 longitude in decimal degrees
#'   - `lat`: OSGB36 latitude in decimal degrees
#'   - `easting`: OSGB easting in meters
#'   - `northing`: OSGB northing in meters
#'   - `precision`: Precision level of the grid reference
#'
#' @details
#' The Ordnance Survey National Grid is a geographic grid reference system
#' used in Great Britain. It uses the OSGB36 datum and a Transverse Mercator
#' projection.
#'
#' Grid references are alphanumeric codes like "TQ3080" for central London.
#' The format is two letters (100 km square) followed by an even number of digits.
#'
#' **Datum note:** The difference between WGS84 and OSGB36 can be up to ~100m.
#' For precise work, transform WGS84 coordinates to OSGB36 first.
#'
#' @export
#'
#' @examples
#' # OSGB36 coordinates for central London (not WGS84!)
#' # In practice, you would transform from WGS84 first
#' london_osgb36 <- c(-0.1270, 51.5072)
#'
#' # Convert to OSGB grid
#' osgb_fwd(london_osgb36)
#'
#' # Get grid reference at various precisions
#' osgb_gridref(london_osgb36, precision = 2)  # 1 km
#' osgb_gridref(london_osgb36, precision = 3)  # 100 m
#' osgb_gridref(london_osgb36, precision = 4)  # 10 m
#'
#' # Parse a grid reference
#' osgb_gridref_rev("TQ3080")
#'
#' # Round-trip conversion
#' fwd <- osgb_fwd(london_osgb36)
#' osgb_rev(fwd$easting, fwd$northing)
osgb_fwd <- function(x) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)

  lon <- x[, 1L, drop = TRUE]
  lat <- x[, 2L, drop = TRUE]

  osgb_fwd_cpp(lon, lat)
}

#' @rdname osgb_fwd
#' @export
osgb_rev <- function(easting, northing) {
  nn <- max(length(easting), length(northing))
  easting <- rep_len(easting, nn)
  northing <- rep_len(northing, nn)

  osgb_rev_cpp(easting, northing)
}

#' @rdname osgb_fwd
#' @export
osgb_gridref <- function(x, precision = 2L) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)

  nn <- nrow(x)
  lon <- x[, 1L, drop = TRUE]
  lat <- x[, 2L, drop = TRUE]
  precision <- as.integer(rep_len(precision, nn))

  if (any(precision < -1 | precision > 5)) {
    stop("precision must be between -1 and 5")
  }

  osgb_gridref_cpp(lon, lat, precision)
}

#' @rdname osgb_fwd
#' @export
osgb_gridref_rev <- function(gridref) {
  osgb_gridref_rev_cpp(gridref)
}
