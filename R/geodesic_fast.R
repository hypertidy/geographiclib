#' Fast geodesic calculations (series approximation)
#'
#' @description
#' These functions provide the same geodesic calculations as `geodesic_direct()`,
#' `geodesic_inverse()`, etc., but use a series approximation that is slightly
#' faster at the cost of reduced precision (accurate to ~15 nanometers vs
#' full double precision for the exact versions).
#'
#' For most applications, the difference is negligible and these faster
#' versions are recommended.
#'
#' @inheritParams geodesic_direct
#'
#' @returns Same as the corresponding exact geodesic functions.
#'
#' @seealso [geodesic_direct()], [geodesic_inverse()] for exact versions
#'
#' @export
#'
#' @examples
#' # Fast inverse: London to New York
#' geodesic_inverse_fast(c(-0.1, 51.5), c(-74, 40.7))
#'
#' # Compare to exact version
#' geodesic_inverse(c(-0.1, 51.5), c(-74, 40.7))$s12
#' geodesic_inverse_fast(c(-0.1, 51.5), c(-74, 40.7))$s12
geodesic_direct_fast <- function(x, azi, s) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)

  nn <- max(nrow(x), length(azi), length(s))
  lon1 <- rep_len(x[, 1], nn)
  lat1 <- rep_len(x[, 2], nn)
  azi <- rep_len(azi, nn)
  s <- rep_len(s, nn)

  geodesic_direct_fast_cpp(lon1, lat1, azi, s)
}

#' @rdname geodesic_direct_fast
#' @export
geodesic_inverse_fast <- function(x, y) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  if (is.list(y) && !is.data.frame(y)) y <- do.call(cbind, y[1:2])
  if (length(y) == 2) y <- matrix(y, ncol = 2)

  nn <- max(nrow(x), nrow(y))
  lon1 <- rep_len(x[, 1], nn)
  lat1 <- rep_len(x[, 2], nn)
  lon2 <- rep_len(y[, 1], nn)
  lat2 <- rep_len(y[, 2], nn)

  geodesic_inverse_fast_cpp(lon1, lat1, lon2, lat2)
}

#' @rdname geodesic_direct_fast
#' @export
geodesic_path_fast <- function(x, y, n = 100L) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  if (is.list(y) && !is.data.frame(y)) y <- do.call(cbind, y[1:2])
  if (length(y) == 2) y <- matrix(y, ncol = 2)

  if (nrow(x) != 1 || nrow(y) != 1) {
    stop("geodesic_path_fast requires single start and end points")
  }

  geodesic_path_fast_cpp(x[1, 1], x[1, 2], y[1, 1], y[1, 2], as.integer(n))
}

#' @rdname geodesic_direct_fast
#' @export
geodesic_distance_fast <- function(x, y) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  if (is.list(y) && !is.data.frame(y)) y <- do.call(cbind, y[1:2])
  if (length(y) == 2) y <- matrix(y, ncol = 2)

  nn <- max(nrow(x), nrow(y))
  lon1 <- rep_len(x[, 1], nn)
  lat1 <- rep_len(x[, 2], nn)
  lon2 <- rep_len(y[, 1], nn)
  lat2 <- rep_len(y[, 2], nn)

  geodesic_distance_fast_cpp(lon1, lat1, lon2, lat2)
}

#' @rdname geodesic_direct_fast
#' @export
geodesic_distance_matrix_fast <- function(x, y = NULL) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)

  if (is.null(y)) {
    y <- x
  } else {
    if (is.list(y) && !is.data.frame(y)) y <- do.call(cbind, y[1:2])
    if (length(y) == 2) y <- matrix(y, ncol = 2)
  }

  dist_vec <- geodesic_distance_matrix_fast_cpp(x[, 1], x[, 2], y[, 1], y[, 2])
  matrix(dist_vec, nrow = nrow(x), ncol = nrow(y), byrow = TRUE)
}
