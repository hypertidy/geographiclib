
#' Lambert Conformal Conic projection
#'
#' @description
#' Convert geographic coordinates (longitude/latitude) to Lambert Conformal
#' Conic (LCC) projected coordinates, or convert projected coordinates back
#' to geographic coordinates.
#'
#' @param x For forward conversion: a two-column matrix or data frame of
#'   coordinates (longitude, latitude) in decimal degrees, or a list with
#'   longitude and latitude components. Can also be a length-2 numeric vector
#'   for a single point.
#'   For reverse conversion: numeric vector of easting values (x coordinates)
#'   in meters.
#' @param y Numeric vector of northing values (y coordinates) in meters for
#'   reverse conversion.
#' @param lon0 Central meridian (longitude of origin) in decimal degrees.
#' @param lat0 Latitude of origin in decimal degrees (used for documentation,
#'   not in the projection calculation itself).
#' @param stdlat Standard parallel in decimal degrees for single standard
#'   parallel (tangent cone) projections.
#' @param stdlat1,stdlat2 First and second standard parallels in decimal degrees
#'   for two standard parallel (secant cone) projections.
#' @param k0 Scale factor at the standard parallel. Default is 1.
#' @param k1 Scale factor at the first standard parallel for two standard
#'   parallel projections. Default is 1.
#'
#' @returns Data frame with columns:
#' * For forward conversion:
#'   - `x`: Easting in meters
#'   - `y`: Northing in meters
#'   - `convergence`: Meridian convergence in degrees
#'   - `scale`: Scale factor at the point
#'   - `lon`: Longitude (echoed from input)
#'   - `lat`: Latitude (echoed from input)
#'
#' * For reverse conversion:
#'   - `lon`: Longitude in decimal degrees
#'   - `lat`: Latitude in decimal degrees
#'   - `convergence`: Meridian convergence in degrees
#'   - `scale`: Scale factor at the point
#'   - `x`: Easting (echoed from input)
#'   - `y`: Northing (echoed from input)
#'
#' @details
#' The Lambert Conformal Conic projection is a conic map projection commonly
#' used for aeronautical charts, state plane coordinate systems, and many
#' national/regional coordinate systems.
#'
#' Two forms are supported:
#' - **Single standard parallel** (tangent cone): The cone is tangent to the
#'   ellipsoid at one latitude. Use `lcc_fwd()` and `lcc_rev()` with `stdlat`.
#' - **Two standard parallels** (secant cone): The cone intersects the ellipsoid
#'   at two latitudes. Use `lcc_fwd()` and `lcc_rev()` with `stdlat1` and
#'   `stdlat2`.
#'
#' The projection is conformal (preserves local angles/shapes) and is best
#' suited for mid-latitude regions with greater east-west extent.
#'
#' All functions use the WGS84 ellipsoid and are fully vectorized on
#' coordinate inputs.
#'
#' @seealso [utmups_fwd()] for UTM/UPS projections which are also conformal.
#'
#' @export
#'
#' @examples
#' # Single standard parallel (e.g., for a state plane zone)
#' pts <- cbind(lon = c(-100, -99, -98), lat = c(40, 41, 42))
#' lcc_fwd(pts, lon0 = -100, stdlat = 40)
#'
#' # Two standard parallels (e.g., for continental US)
#' # CONUS Albers-like setup
#' lcc_fwd(pts, lon0 = -96, stdlat1 = 33, stdlat2 = 45)
#'
#' # Round-trip conversion
#' fwd <- lcc_fwd(pts, lon0 = -100, stdlat = 40)
#' lcc_rev(fwd$x, fwd$y, lon0 = -100, stdlat = 40)
lcc_fwd <- function(x, lon0, lat0 = NULL, stdlat = NULL,
                    stdlat1 = NULL, stdlat2 = NULL,
                    k0 = 1, k1 = 1) {
  if (is.list(x)) x <- do.call(cbind, x[1:2])
  if (length(x) == 2) x <- matrix(x, ncol = 2)

  lon <- x[, 1L, drop = TRUE]
  lat <- x[, 2L, drop = TRUE]

  # Determine which form to use
  if (!is.null(stdlat1) && !is.null(stdlat2)) {
    # Two standard parallels (secant cone)
    if (is.null(lat0)) lat0 <- (stdlat1 + stdlat2) / 2
    lcc_fwd2_cpp(lon, lat, lon0, lat0, stdlat1, stdlat2, k1)
  } else if (!is.null(stdlat)) {
    # Single standard parallel (tangent cone)
    if (is.null(lat0)) lat0 <- stdlat
    lcc_fwd_cpp(lon, lat, lon0, lat0, stdlat, k0)
  } else {
    stop("Specify either 'stdlat' for single standard parallel or both 'stdlat1' and 'stdlat2' for two standard parallels")
  }
}

#' @rdname lcc_fwd
#' @export
lcc_rev <- function(x, y, lon0, lat0 = NULL, stdlat = NULL,
                    stdlat1 = NULL, stdlat2 = NULL,
                    k0 = 1, k1 = 1) {
  # Ensure vectors are same length
  nn <- max(length(x), length(y))
  x <- rep_len(x, nn)
  y <- rep_len(y, nn)

  # Determine which form to use
  if (!is.null(stdlat1) && !is.null(stdlat2)) {
    # Two standard parallels (secant cone)
    if (is.null(lat0)) lat0 <- (stdlat1 + stdlat2) / 2
    lcc_rev2_cpp(x, y, lon0, lat0, stdlat1, stdlat2, k1)
  } else if (!is.null(stdlat)) {
    # Single standard parallel (tangent cone)
    if (is.null(lat0)) lat0 <- stdlat
    lcc_rev_cpp(x, y, lon0, lat0, stdlat, k0)
  } else {
    stop("Specify either 'stdlat' for single standard parallel or both 'stdlat1' and 'stdlat2' for two standard parallels")
  }
}
