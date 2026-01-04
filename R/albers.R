#' Albers Equal Area projection
#'
#' @description
#' Convert geographic coordinates to/from Albers Equal Area conic projection.
#' This is an equal-area projection commonly used for thematic maps of
#' regions with greater east-west extent.
#'
#' @param x For forward conversion: a two-column matrix or data frame of
#'   coordinates (longitude, latitude) in decimal degrees.
#'   For reverse conversion: numeric vector of x (easting) coordinates in meters.
#' @param y Numeric vector of y (northing) coordinates in meters (reverse only).
#' @param lon0 Central meridian in decimal degrees. Can be a vector to specify
#'   different central meridians for each point.
#' @param stdlat Standard parallel for single standard parallel projections
#'   (e.g., Lambert Cylindrical Equal Area when stdlat = 0).
#' @param stdlat1,stdlat2 First and second standard parallels in decimal degrees
#'   for two standard parallel projections.
#' @param k0 Scale factor at the standard parallel(s). Default is 1.
#' @param k1 Scale factor at the first standard parallel for two standard
#'   parallel projections. Default is 1.
#'
#' @returns Data frame with columns:
#' * For forward conversion:
#'   - `x`: Easting in meters
#'   - `y`: Northing in meters
#'   - `convergence`: Grid convergence in degrees
#'   - `scale`: Scale factor at the point
#'   - `lon`, `lat`: Input coordinates (echoed)
#'   - `lon0`: Central meridian (echoed)
#'
#' * For reverse conversion:
#'   - `lon`: Longitude in decimal degrees
#'   - `lat`: Latitude in decimal degrees
#'   - `convergence`: Grid convergence in degrees
#'   - `scale`: Scale factor at the point
#'   - `x`, `y`: Input coordinates (echoed)
#'   - `lon0`: Central meridian (echoed)
#'
#' @details
#' The Albers Equal Area conic projection preserves area, making it ideal for:
#' - Thematic/choropleth maps where area comparison matters
#' - Continental-scale maps (e.g., USGS maps of CONUS)
#' - Statistical mapping and analysis
#'
#' Common configurations:
#' - **CONUS**: stdlat1 = 29.5, stdlat2 = 45.5, lon0 = -96
#' - **Australia**: stdlat1 = -18, stdlat2 = -36, lon0 = 132
#' - **Europe**: stdlat1 = 43, stdlat2 = 62, lon0 = 10
#'
#' Special cases:
#' - When stdlat1 = -stdlat2, the projection becomes Lambert Cylindrical Equal Area
#' - When stdlat1 = stdlat2 = 0, it becomes the cylindrical equal-area projection
#'
#' The `lon0` parameter is vectorized, allowing different central meridians
#' for each point.
#'
#' @seealso [lcc_fwd()] for Lambert Conformal Conic (conformal, not equal-area).
#'
#' @export
#'
#' @examples
#' # CONUS Albers Equal Area
#' pts <- cbind(lon = c(-122, -74, -90), lat = c(37, 41, 30))
#' albers_fwd(pts, lon0 = -96, stdlat1 = 29.5, stdlat2 = 45.5)
#'
#' # Australia
#' aus <- cbind(lon = c(151.2, 115.9, 153.0), lat = c(-33.9, -32.0, -27.5))
#' albers_fwd(aus, lon0 = 132, stdlat1 = -18, stdlat2 = -36)
#'
#' # Antarctic projection
#' ant <- cbind(lon = c(166.67, 77.97, -43.53), lat = c(-77.85, -67.60, -60.72))
#' albers_fwd(ant, lon0 = 0, stdlat1 = -72, stdlat2 = -60)
#'
#' # Round-trip conversion
#' fwd <- albers_fwd(pts, lon0 = -96, stdlat1 = 29.5, stdlat2 = 45.5)
#' albers_rev(fwd$x, fwd$y, lon0 = -96, stdlat1 = 29.5, stdlat2 = 45.5)
#'
#' # Single standard parallel (cylindrical-like)
#' albers_fwd(pts, lon0 = -96, stdlat = 37)
albers_fwd <- function(x, lon0, stdlat = NULL, stdlat1 = NULL, stdlat2 = NULL,
                       k0 = 1, k1 = 1) {
  if (is.list(x) && !is.data.frame(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)
  
  lon <- x[, 1L, drop = TRUE]
  lat <- x[, 2L, drop = TRUE]
  
  nn <- length(lon)
  lon0 <- rep_len(lon0, nn)
  
  if (!is.null(stdlat1) && !is.null(stdlat2)) {
    # Two standard parallels
    albers_fwd_cpp(lon, lat, lon0, stdlat1, stdlat2, k1)
  } else if (!is.null(stdlat)) {
    # Single standard parallel
    albers_fwd_single_cpp(lon, lat, lon0, stdlat, k0)
  } else {
    stop("Specify either 'stdlat' for single standard parallel or both 'stdlat1' and 'stdlat2'")
  }
}

#' @rdname albers_fwd
#' @export
albers_rev <- function(x, y, lon0, stdlat = NULL, stdlat1 = NULL, stdlat2 = NULL,
                       k0 = 1, k1 = 1) {
  nn <- max(length(x), length(y), length(lon0))
  x <- rep_len(x, nn)
  y <- rep_len(y, nn)
  lon0 <- rep_len(lon0, nn)
  
  if (!is.null(stdlat1) && !is.null(stdlat2)) {
    albers_rev_cpp(x, y, lon0, stdlat1, stdlat2, k1)
  } else if (!is.null(stdlat)) {
    albers_rev_single_cpp(x, y, lon0, stdlat, k0)
  } else {
    stop("Specify either 'stdlat' for single standard parallel or both 'stdlat1' and 'stdlat2'")
  }
}
