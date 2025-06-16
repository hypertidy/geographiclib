
#' MGRS conversion
#'
#' Forward mode is vectorized on `x` by rows and `precision`.
#'
#' Currently cannnot handle missing values.
#' @param x in forward mode a matrix of lon,lat coordinates
#' @param precision in forward mode integer between 0 and 5 (default is 5, full precision)
#' @param code in reverse mode an MGRS code string
#'
#' @returns lon,lat,x,y,zone,northp vector in reverse mode, MGRS code in forward mode
#' @export
#'
#' @examples
#' (code <- mgrs_fwd(cbind(147.325, -42.881)))
#' mgrs_rev(code)

#' x <- cbind(long = c(-63.22, 34.02, 49.45, 45.67, 47.4, -66.3, -65.72, 42.31, 8.94, 102.55),
#'            lat = c(17.62, -1.9, 37.47, 39.84, 33.15, 17.98, -21.44, 41.65, 50.08, 24.36))
#' codes <- mgrs_fwd(x, precision = rep(c(0, 5), each = 5))
mgrs_fwd <- function(x, precision = 5L) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  precision <- as.integer(rep(precision, length.out = dim(x)[1L]))
  if (any(precision > 5 | precision < 0)) stop("precision values out of bounds, must be 0,1,2,3,4, or 5")
  mgrs_fwd_cpp(x[,1L, drop = TRUE], x[,2L, drop = TRUE], precision)
}


#' @name mgrs_fwd
#' @export
mgrs_rev <- function(code) {
  mgrs_rev_cpp(code)
}
