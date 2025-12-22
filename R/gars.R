#' Global Area Reference System (GARS)
#'
#' @description
#' Convert geographic coordinates (longitude/latitude) to GARS codes,
#' or convert GARS codes back to coordinates.
#'
#' @param x A two-column matrix or data frame of coordinates (longitude, latitude)
#'   in decimal degrees, or a list with longitude and latitude components.
#'   Can also be a length-2 numeric vector for a single point.
#' @param precision Integer specifying the precision level (0, 1, or 2):
#'   * 0: 30-minute cells (5-character code)
#'   * 1: 15-minute quadrants (6-character code)
#'   * 2: 5-minute keypads (7-character code, maximum precision)
#' @param gars Character vector of GARS codes to convert back to coordinates.
#'
#' @returns
#' * `gars_fwd()`: Character vector of GARS codes.
#'
#' * `gars_rev()`: Data frame with columns:
#'   - `lon`: Longitude of cell center in decimal degrees
#'   - `lat`: Latitude of cell center in decimal degrees
#'   - `precision`: Precision level (0, 1, or 2)
#'   - `lat_resolution`: Cell half-height in degrees
#'   - `lon_resolution`: Cell half-width in degrees
#'
#' @details
#' GARS (Global Area Reference System) is a standardized geospatial reference
#' system used by the US military. It divides the Earth into cells using a
#' hierarchical grid:
#'
#' - **30-minute cells**: The base grid (720 × 360 cells globally)
#' - **15-minute quadrants**: Each 30-minute cell divided into 4 quadrants (1-4)
#' - **5-minute keypads**: Each quadrant divided into 9 keypads (1-9, like a phone keypad)
#'
#' A GARS code consists of:
#' - 3-digit longitude band (001-720)
#' - 2-letter latitude band (AA-QZ)
#' - Optional 1-digit quadrant (1-4)
#' - Optional 1-digit keypad (1-9)
#'
#' Example: "006AG39" = 5-minute cell at approximately (-177°, -89.5°)
#'
#' @seealso [mgrs_fwd()] for Military Grid Reference System, another military
#'   grid system.
#'
#' @export
#'
#' @examples
#' # Basic conversion
#' gars_fwd(c(-74, 40.7))
#'
#' # Different precision levels
#' gars_fwd(c(-74, 40.7), precision = 0)  # 30-minute
#' gars_fwd(c(-74, 40.7), precision = 1)  # 15-minute
#' gars_fwd(c(-74, 40.7), precision = 2)  # 5-minute
#'
#' # Multiple points
#' pts <- cbind(lon = c(-74, 139.7, 0), lat = c(40.7, 35.7, 51.5))
#' gars_fwd(pts, precision = 2)
#'
#' # Reverse conversion
#' gars_rev(c("213LR29", "498MH18", "361NS47"))
gars_fwd <- function(x, precision = 2L) {
  if (is.list(x) && !is.data.frame(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  
  nn <- nrow(x)
  precision <- as.integer(rep_len(precision, nn))
  
  if (any(precision < 0 | precision > 2)) {
    stop("precision must be 0, 1, or 2")
  }
  
  gars_fwd_cpp(x[, 1L, drop = TRUE], x[, 2L, drop = TRUE], precision)
}

#' @rdname gars_fwd
#' @export
gars_rev <- function(gars) {
  gars_rev_cpp(gars)
}
