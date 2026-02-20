#' Rhumb line (loxodrome) calculations on the WGS84 ellipsoid
#'
#' @description
#' Solve rhumb line problems on the WGS84 ellipsoid. A rhumb line (or loxodrome)
#' is a path of constant bearing, which appears as a straight line on a Mercator
#' projection. Unlike geodesics, rhumb lines are not the shortest path between
#' two points, but they are easier to navigate as they maintain a constant
#' compass heading.
#'
#' @param x A two-column matrix or data frame of starting coordinates
#'   (longitude, latitude) in decimal degrees.
#' @param azi Numeric vector of azimuths (bearings) in degrees, measured
#'   clockwise from north.
#' @param s Numeric vector of distances in meters.
#' @param y A two-column matrix or data frame of ending coordinates
#'   (longitude, latitude) in decimal degrees.
#' @param n Integer number of points to generate along the path (including
#'   start and end points).
#' @param distances Numeric vector of distances from the starting point in meters.
#'
#' @returns
#' * `rhumb_direct()`: Data frame with columns:
#'   - `lon1`, `lat1`: Starting coordinates
#'   - `azi12`: Azimuth (constant along rhumb line, degrees)
#'   - `s12`: Distance (meters)
#'   - `lon2`, `lat2`: Destination coordinates
#'   - `S12`: Area under rhumb line (square meters)
#'
#' * `rhumb_inverse()`: Data frame with columns:
#'   - `lon1`, `lat1`: Starting coordinates
#'   - `lon2`, `lat2`: Ending coordinates
#'   - `s12`: Distance (meters)
#'   - `azi12`: Azimuth (degrees)
#'   - `S12`: Area under rhumb line (square meters)
#'
#' * `rhumb_path()`: Data frame with columns:
#'   - `lon`, `lat`: Coordinates along the path
#'   - `s`: Distance from start (meters)
#'   - `azi12`: Constant azimuth (degrees)
#'
#' * `rhumb_line()`: Data frame with columns:
#'   - `lon`, `lat`: Coordinates at specified distances
#'   - `azi`: Azimuth (degrees)
#'   - `s`: Distance from start (meters)
#'
#' * `rhumb_distance()`: Numeric vector of distances in meters (pairwise).
#'
#' * `rhumb_distance_matrix()`: Matrix of distances in meters.
#'
#' @details
#' Rhumb lines are paths of constant azimuth (bearing). They are longer than
#' geodesics (up to 50% longer for long distances) but are useful for navigation
#' because they can be followed with a constant compass heading.
#'
#' The azimuth is measured in degrees from north, with positive values
#' clockwise (east) and negative values counter-clockwise (west).
#' The range is -180 to 180 degrees.
#'
#' The area `S12` represents the area under the rhumb line quadrilateral
#' with corners at (lat1, lon1), (0, lon1), (0, lon2), and (lat2, lon2).
#'
#' @seealso [geodesic_direct()] for shortest-path geodesic calculations.
#'
#' @export
#'
#' @examples
#' # Direct problem: Where do you end up starting from London,
#' # heading east on a rhumb line for 1000 km?
#' rhumb_direct(c(-0.1, 51.5), azi = 90, s = 1000000)
#'
#' # Inverse problem: Rhumb distance from London to New York
#' rhumb_inverse(c(-0.1, 51.5), c(-74, 40.7))
#'
#' # Compare to geodesic (rhumb is longer!)
#' geodesic_inverse(c(-0.1, 51.5), c(-74, 40.7))$s12
#' rhumb_inverse(c(-0.1, 51.5), c(-74, 40.7))$s12
#'
#' # Generate a rhumb line path
#' path <- rhumb_path(c(-0.1, 51.5), c(-74, 40.7), n = 10)
#' path
rhumb_direct <- function(x, azi, s) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)

  nn <- max(nrow(x), length(azi), length(s))
  lon1 <- rep_len(x[, 1], nn)
  lat1 <- rep_len(x[, 2], nn)
  azi <- rep_len(azi, nn)
  s <- rep_len(s, nn)

  rhumb_direct_cpp(lon1, lat1, azi, s)
}

#' @rdname rhumb_direct
#' @export
rhumb_inverse <- function(x, y) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  if (is.list(y) && !is.data.frame(y)) y <- do.call(cbind, y[1:2])
  if (length(y) == 2) y <- matrix(y, ncol = 2)

  nn <- max(nrow(x), nrow(y))
  lon1 <- rep_len(x[, 1], nn)
  lat1 <- rep_len(x[, 2], nn)
  lon2 <- rep_len(y[, 1], nn)
  lat2 <- rep_len(y[, 2], nn)

  rhumb_inverse_cpp(lon1, lat1, lon2, lat2)
}

#' @rdname rhumb_direct
#' @export
rhumb_path <- function(x, y, n = 100L) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  if (is.list(y) && !is.data.frame(y)) y <- do.call(cbind, y[1:2])
  if (length(y) == 2) y <- matrix(y, ncol = 2)

  if (nrow(x) != 1 || nrow(y) != 1) {
    stop("rhumb_path requires single start and end points")
  }

  rhumb_path_cpp(x[1, 1], x[1, 2], y[1, 1], y[1, 2], as.integer(n))
}

#' @rdname rhumb_direct
#' @export
rhumb_line <- function(x, azi, distances) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)

  if (nrow(x) != 1) {
    stop("rhumb_line requires a single starting point")
  }
  if (length(azi) != 1) {
    stop("rhumb_line requires a single azimuth")
  }

  rhumb_line_cpp(x[1, 1], x[1, 2], azi, as.double(distances))
}

#' @rdname rhumb_direct
#' @export
rhumb_distance <- function(x, y) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  if (is.list(y) && !is.data.frame(y)) y <- do.call(cbind, y[1:2])
  if (length(y) == 2) y <- matrix(y, ncol = 2)

  nn <- max(nrow(x), nrow(y))
  lon1 <- rep_len(x[, 1], nn)
  lat1 <- rep_len(x[, 2], nn)
  lon2 <- rep_len(y[, 1], nn)
  lat2 <- rep_len(y[, 2], nn)

  rhumb_distance_pairwise_cpp(lon1, lat1, lon2, lat2)
}

#' @rdname rhumb_direct
#' @export
rhumb_distance_matrix <- function(x, y = NULL) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)

  if (is.null(y)) {
    y <- x
  } else {
    if (is.list(y) && !is.data.frame(y)) y <- do.call(cbind, y[1:2])
    if (length(y) == 2) y <- matrix(y, ncol = 2)
  }

  dist_vec <- rhumb_distance_matrix_cpp(x[, 1], x[, 2], y[, 1], y[, 2])
  matrix(dist_vec, nrow = nrow(x), ncol = nrow(y), byrow = TRUE)
}
