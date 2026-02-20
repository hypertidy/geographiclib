#' Geodesic calculations on the WGS84 ellipsoid
#'
#' @description
#' Solve geodesic problems on the WGS84 ellipsoid using exact algorithms.
#' These functions provide high-precision solutions for:
#' - Finding destination points given start, azimuth, and distance (direct problem)
#' - Finding distance and azimuths between two points (inverse problem)
#' - Generating points along geodesic paths
#' - Computing distance matrices
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
#' * `geodesic_direct()`: Data frame with columns:
#'   - `lon1`, `lat1`: Starting coordinates
#'   - `azi1`: Starting azimuth (degrees)
#'   - `s12`: Distance (meters)
#'   - `lon2`, `lat2`: Destination coordinates
#'   - `azi2`: Azimuth at destination (degrees)
#'   - `m12`: Reduced length (meters)
#'   - `M12`, `M21`: Geodesic scale factors
#'   - `S12`: Area under geodesic (square meters)
#'
#' * `geodesic_inverse()`: Data frame with columns:
#'   - `lon1`, `lat1`: Starting coordinates
#'   - `lon2`, `lat2`: Ending coordinates
#'   - `s12`: Distance (meters)
#'   - `azi1`: Azimuth at start (degrees)
#'   - `azi2`: Azimuth at end (degrees)
#'   - `m12`: Reduced length (meters)
#'   - `M12`, `M21`: Geodesic scale factors
#'   - `S12`: Area under geodesic (square meters)
#'
#' * `geodesic_path()`: Data frame with columns:
#'   - `lon`, `lat`: Coordinates along the path
#'   - `azi`: Azimuth at each point (degrees)
#'   - `s`: Distance from start (meters)
#'
#' * `geodesic_line()`: Data frame with columns:
#'   - `lon`, `lat`: Coordinates at specified distances
#'   - `azi`: Azimuth at each point (degrees)
#'   - `s`: Distance from start (meters)
#'
#' * `geodesic_distance()`: Numeric vector of distances in meters (pairwise).
#'
#' * `geodesic_distance_matrix()`: Matrix of distances in meters.
#'
#' @details
#' These functions use the exact geodesic algorithms from GeographicLib,
#' which provide full double-precision accuracy for all points on the
#' WGS84 ellipsoid.
#'
#' The **direct problem** finds the destination given a starting point,
#' initial azimuth (bearing), and distance. This is useful for navigation
#' and creating buffers.
#'
#' The **inverse problem** finds the shortest path (geodesic) between two
#' points and returns the distance and azimuths at both endpoints.
#'
#' The azimuth is measured in degrees from north, with positive values
#' clockwise (east) and negative values counter-clockwise (west).
#' The range is -180° to 180° (e.g., 90° = east, -90° = west, 180° or -180° = south).
#' @export
#'
#' @examples
#' # Direct problem: Where do you end up starting from London,
#' # heading east for 1000 km?
#' geodesic_direct(c(-0.1, 51.5), azi = 90, s = 1000000)
#'
#' # Inverse problem: Distance from London to New York
#' geodesic_inverse(c(-0.1, 51.5), c(-74, 40.7))
#'
#' # Generate a great circle path
#' path <- geodesic_path(c(-0.1, 51.5), c(-74, 40.7), n = 100)
#' head(path)
#'
#' # Multiple distances along a bearing
#' geodesic_line(c(-0.1, 51.5), azi = 45, distances = c(100, 500, 1000) * 1000)
geodesic_direct <- function(x, azi, s) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)

  nn <- max(nrow(x), length(azi), length(s))
  lon1 <- rep_len(x[, 1], nn)
  lat1 <- rep_len(x[, 2], nn)
  azi <- rep_len(azi, nn)
  s <- rep_len(s, nn)

  geodesic_direct_cpp(lon1, lat1, azi, s)
}

#' @rdname geodesic_direct
#' @export
geodesic_inverse <- function(x, y) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  if (is.list(y) && !is.data.frame(y)) y <- do.call(cbind, y[1:2])
  if (length(y) == 2) y <- matrix(y, ncol = 2)

  nn <- max(nrow(x), nrow(y))
  lon1 <- rep_len(x[, 1], nn)
  lat1 <- rep_len(x[, 2], nn)
  lon2 <- rep_len(y[, 1], nn)
  lat2 <- rep_len(y[, 2], nn)

  geodesic_inverse_cpp(lon1, lat1, lon2, lat2)
}

#' @rdname geodesic_direct
#' @export
geodesic_path <- function(x, y, n = 100L) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  if (is.list(y) && !is.data.frame(y)) y <- do.call(cbind, y[1:2])
  if (length(y) == 2) y <- matrix(y, ncol = 2)

  if (nrow(x) != 1 || nrow(y) != 1) {
    stop("geodesic_path requires single start and end points")
  }

  geodesic_path_cpp(x[1, 1], x[1, 2], y[1, 1], y[1, 2], as.integer(n))
}

#' @rdname geodesic_direct
#' @export
geodesic_line <- function(x, azi, distances) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)

  if (nrow(x) != 1) {
    stop("geodesic_line requires a single starting point")
  }
  if (length(azi) != 1) {
    stop("geodesic_line requires a single azimuth")
  }

  geodesic_line_cpp(x[1, 1], x[1, 2], azi, as.double(distances))
}

#' @rdname geodesic_direct
#' @export
geodesic_distance <- function(x, y) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  if (is.list(y) && !is.data.frame(y)) y <- do.call(cbind, y[1:2])
  if (length(y) == 2) y <- matrix(y, ncol = 2)

  nn <- max(nrow(x), nrow(y))
  lon1 <- rep_len(x[, 1], nn)
  lat1 <- rep_len(x[, 2], nn)
  lon2 <- rep_len(y[, 1], nn)
  lat2 <- rep_len(y[, 2], nn)

  geodesic_distance_pairwise_cpp(lon1, lat1, lon2, lat2)
}

#' @rdname geodesic_direct
#' @export
geodesic_distance_matrix <- function(x, y = NULL) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)

  if (is.null(y)) {
    y <- x
  } else {
    if (is.list(y) && !is.data.frame(y)) y <- do.call(cbind, y[1:2])
    if (length(y) == 2) y <- matrix(y, ncol = 2)
  }

  dist_vec <- geodesic_distance_matrix_cpp(x[, 1], x[, 2], y[, 1], y[, 2])
  matrix(dist_vec, nrow = nrow(x), ncol = nrow(y), byrow = TRUE)
}
