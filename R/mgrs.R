
#' MGRS (not useful yet, we only take length-1 input)
#'
#' @param x in forward mode a lon,lat coordinate
#' @param code in reverse mode an MGRS code string
#'
#' @returns lon,lat,x,y,zone,northp vector in reverse mode, MGRS code in forward mode
#' @export
#'
#' @examples
#' (code <- mgrs_fwd(c(147.325, -42.881)))
#' mgrs_rev(code)
mgrs_fwd <- function(x) {
  mgrs_fwd_cpp(x)
}


#' @name mgrs_fwd
#' @export
mgrs_rev <- function(code) {
  mgrs_rev_cpp(code)
}
