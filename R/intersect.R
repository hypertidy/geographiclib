#' Geodesic intersections
#'
#' @description
#' Find the intersection of two geodesics on the WGS84 ellipsoid. Several
#' methods are available:
#'
#' * `geodesic_intersect()` - Find the closest intersection of two geodesics
#'   defined by starting points and azimuths
#' * `geodesic_intersect_segment()` - Find the intersection of two geodesic
#'   segments defined by their endpoints
#' * `geodesic_intersect_next()` - Find the next closest intersection from a
#'   known intersection point
#' * `geodesic_intersect_all()` - Find all intersections within a maximum
#'   distance
#'
#' @param x Coordinates for geodesic X: a vector of `c(lon, lat)`, a matrix
#'   with columns `[lon, lat]`, or a list with `lon` and `lat` components.
#' @param azi_x Azimuth(s) for geodesic X in degrees.
#' @param y Coordinates for geodesic Y (same format as `x`).
#' @param azi_y Azimuth(s) for geodesic Y in degrees.
#' @param x1,x2 Start and end coordinates for segment X.
#' @param y1,y2 Start and end coordinates for segment Y.
#' @param maxdist Maximum distance (in meters) for finding all intersections.
#'
#' @returns
#' A data frame with columns:
#' * `x` - Displacement along geodesic X from its starting point (meters)
#' * `y` - Displacement along geodesic Y from its starting point (meters)
#' * `coincidence` - Indicator: 0 = normal intersection, +1 = geodesics are
#'   parallel and coincident, -1 = geodesics are antiparallel and coincident
#' * `lat` - Latitude of intersection point (degrees)
#' * `lon` - Longitude of intersection point (degrees)
#'
#' For `geodesic_intersect_segment()`, an additional column `segmode` indicates
#' whether the intersection lies within both segments (0), or which segment(s)
#' the intersection lies outside of.
#'
#' For `geodesic_intersect_all()`, returns a list of data frames (one per input
#' pair of geodesics).
#'
#' @details
#' The intersection point is found using the algorithm described in:
#'
#' C. F. F. Karney, "Geodesic intersections", J. Surveying Eng. 150(3),
#' 04024005:1-9 (2024). \doi{10.1061/JSUED2.SUENG-1483}
#'
#' The "closest" intersection minimizes the L1 distance, defined as
#' `|x| + |y|` where `x` and `y` are the displacements along the two geodesics.
#'
#' For segment intersection, `segmode` encodes whether the intersection lies

#' within the segments:
#' * `segmode = 0` means the intersection lies within both segments
#' * Non-zero values indicate the intersection lies outside one or both segments
#'
#' The coincidence indicator is useful for detecting when geodesics are
#' parallel or antiparallel at their intersection.
#'
#' @seealso [geodesic_inverse()] for computing azimuths between points
#'
#' @export
#'
#' @examples
#' # Two geodesics from different starting points
#' # Geodesic X: starts at (0, 0), azimuth 45 degrees
#' # Geodesic Y: starts at (1, 0), azimuth 315 degrees
#' geodesic_intersect(c(0, 0), 45, c(1, 0), 315)
#'
#' # Vectorized: multiple pairs of geodesics
#' geodesic_intersect(
#'   cbind(c(0, 0, 0), c(0, 0, 0)),
#'   c(30, 45, 60),
#'   cbind(c(1, 1, 1), c(0, 0, 0)),
#'   c(330, 315, 300)
#' )
geodesic_intersect <- function(x, azi_x, y, azi_y) {
  # Parse x coordinates
  if (is.list(x) && !is.data.frame(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)

  # Parse y coordinates
  if (is.list(y) && !is.data.frame(y)) y <- do.call(cbind, y[1:2])
  if (length(y) == 2) y <- matrix(y, ncol = 2)

  # Recycle to common length
nn <- max(nrow(x), nrow(y), length(azi_x), length(azi_y))
  lonX <- rep_len(x[, 1], nn)
  latX <- rep_len(x[, 2], nn)
  lonY <- rep_len(y[, 1], nn)
  latY <- rep_len(y[, 2], nn)
  azi_x <- rep_len(azi_x, nn)
  azi_y <- rep_len(azi_y, nn)

  intersect_closest_cpp(latX, lonX, azi_x, latY, lonY, azi_y)
}

#' @rdname geodesic_intersect
#' @export
#'
#' @examples
#' # Intersection of two geodesic segments
#' # Segment X: (0, -1) to (0, 1)
#' # Segment Y: (-1, 0) to (1, 0)
#' geodesic_intersect_segment(
#'   c(0, -1), c(0, 1),
#'   c(-1, 0), c(1, 0)
#' )
geodesic_intersect_segment <- function(x1, x2, y1, y2) {
  # Parse coordinates
  if (is.list(x1) && !is.data.frame(x1)) x1 <- do.call(cbind, x1[1:2])
  if (length(x1) == 2) x1 <- matrix(x1, ncol = 2)
  if (is.list(x2) && !is.data.frame(x2)) x2 <- do.call(cbind, x2[1:2])
  if (length(x2) == 2) x2 <- matrix(x2, ncol = 2)
  if (is.list(y1) && !is.data.frame(y1)) y1 <- do.call(cbind, y1[1:2])
  if (length(y1) == 2) y1 <- matrix(y1, ncol = 2)
  if (is.list(y2) && !is.data.frame(y2)) y2 <- do.call(cbind, y2[1:2])
  if (length(y2) == 2) y2 <- matrix(y2, ncol = 2)

  # Recycle to common length
  nn <- max(nrow(x1), nrow(x2), nrow(y1), nrow(y2))
  lonX1 <- rep_len(x1[, 1], nn)
  latX1 <- rep_len(x1[, 2], nn)
  lonX2 <- rep_len(x2[, 1], nn)
  latX2 <- rep_len(x2[, 2], nn)
  lonY1 <- rep_len(y1[, 1], nn)
  latY1 <- rep_len(y1[, 2], nn)
  lonY2 <- rep_len(y2[, 1], nn)
  latY2 <- rep_len(y2[, 2], nn)

  intersect_segment_cpp(latX1, lonX1, latX2, lonX2, latY1, lonY1, latY2, lonY2)
}

#' @rdname geodesic_intersect
#' @export
#'
#' @examples
#' # Find the next intersection from a known intersection point
#' # Two geodesics crossing at (0, 0) with azimuths 45 and 315
#' geodesic_intersect_next(c(0, 0), 45, 315)
geodesic_intersect_next <- function(x, azi_x, azi_y) {
  # Parse coordinates
  if (is.list(x) && !is.data.frame(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)

  # Recycle to common length
  nn <- max(nrow(x), length(azi_x), length(azi_y))
  lonX <- rep_len(x[, 1], nn)
  latX <- rep_len(x[, 2], nn)
  azi_x <- rep_len(azi_x, nn)
  azi_y <- rep_len(azi_y, nn)

  intersect_next_cpp(latX, lonX, azi_x, azi_y)
}

#' @rdname geodesic_intersect
#' @export
#'
#' @examples
#' # Find all intersections within 1,000,000 meters
#' geodesic_intersect_all(c(0, 0), 45, c(1, 0), 315, maxdist = 1e6)
geodesic_intersect_all <- function(x, azi_x, y, azi_y, maxdist) {
  # Parse x coordinates
  if (is.list(x) && !is.data.frame(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)

  # Parse y coordinates
  if (is.list(y) && !is.data.frame(y)) y <- do.call(cbind, y[1:2])
  if (length(y) == 2) y <- matrix(y, ncol = 2)

  # Recycle to common length
  nn <- max(nrow(x), nrow(y), length(azi_x), length(azi_y), length(maxdist))
  lonX <- rep_len(x[, 1], nn)
  latX <- rep_len(x[, 2], nn)
  lonY <- rep_len(y[, 1], nn)
  latY <- rep_len(y[, 2], nn)
  azi_x <- rep_len(azi_x, nn)
  azi_y <- rep_len(azi_y, nn)
  maxdist <- rep_len(maxdist, nn)

  result <- intersect_all_cpp(latX, lonX, azi_x, latY, lonY, azi_y, maxdist)

  # Return single data frame if only one input pair
  if (nn == 1) {
    return(result[[1]])
  }
  result
}
