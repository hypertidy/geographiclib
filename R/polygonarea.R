
#' Polygon area (not useful yet)
#'

#' @returns numeric area
#' @export
#'
#' @examples
#' (code <- mgrs_fwd(c(147.325, -42.881)))
#' mgrs_rev(code)
polygon_area <- function() {
  polygonarea_cpp()
}
