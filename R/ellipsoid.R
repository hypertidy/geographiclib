#' WGS84 Ellipsoid parameters and calculations
#'
#' @description
#' Access WGS84 ellipsoid parameters and perform ellipsoid-related calculations
#' including auxiliary latitudes, radii of curvature, and meridian distances.
#'
#' @param lat Numeric vector of geographic (geodetic) latitudes in decimal degrees.
#' @param type Character string specifying the type of auxiliary latitude for
#'   inverse conversion. One of: "parametric", "geocentric", "rectifying",
#'   "authalic", "conformal", "isometric".
#'
#' @returns
#' * `ellipsoid_params()`: Named list with WGS84 parameters:
#'   - `a`: Equatorial radius (semi-major axis) in meters
#'   - `f`: Flattening
#'   - `b`: Polar radius (semi-minor axis) in meters
#'   - `e2`: First eccentricity squared
#'   - `ep2`: Second eccentricity squared
#'   - `n`: Third flattening
#'   - `area`: Surface area in square meters
#'   - `volume`: Volume in cubic meters
#'
#' * `ellipsoid_circle()`: Data frame with columns:
#'   - `lat`: Input latitude
#'   - `radius`: Radius of the circle of latitude in meters
#'   - `quarter_meridian`: Distance from equator to pole along a meridian
#'   - `meridian_distance`: Distance from equator to the given latitude
#'
#' * `ellipsoid_latitudes()`: Data frame with auxiliary latitudes:
#'   - `lat`: Input geographic latitude
#'   - `parametric`: Parametric (reduced) latitude
#'   - `geocentric`: Geocentric latitude
#'   - `rectifying`: Rectifying latitude
#'   - `authalic`: Authalic latitude
#'   - `conformal`: Conformal latitude
#'   - `isometric`: Isometric latitude
#'
#' * `ellipsoid_latitudes_inv()`: Data frame with:
#'   - `input`: Input auxiliary latitude
#'   - `geographic`: Corresponding geographic latitude
#'
#' * `ellipsoid_curvature()`: Data frame with radii of curvature:
#'   - `lat`: Input latitude
#'   - `meridional`: Meridional radius of curvature (M)
#'   - `transverse`: Transverse radius of curvature (N)
#'
#' @details
#' The WGS84 ellipsoid is the reference surface used by GPS and most modern
#' mapping systems. It is defined by:
#' - Equatorial radius: 6,378,137 m
#' - Flattening: 1/298.257223563
#'
#' **Auxiliary latitudes** are different ways of measuring latitude that are
#' useful in various map projections:
#' - **Parametric**: Used in ellipsoid parameterization
#' - **Geocentric**: Angle from center of ellipsoid
#' - **Rectifying**: Preserves distances along meridians
#' - **Authalic**: Preserves areas
#' - **Conformal**: Preserves angles/shapes
#' - **Isometric**: Used in Mercator projection
#'
#' @export
#'
#' @examples
#' # WGS84 parameters
#' ellipsoid_params()
#'
#' # Radius at different latitudes
#' ellipsoid_circle(c(0, 30, 45, 60, 90))
#'
#' # Compare auxiliary latitudes
#' ellipsoid_latitudes(c(0, 30, 45, 60, 90))
#'
#' # Radii of curvature
#' ellipsoid_curvature(c(0, 45, 90))
ellipsoid_params <- function() {
  ellipsoid_params_cpp()
}

#' @rdname ellipsoid_params
#' @export
ellipsoid_circle <- function(lat) {
  ellipsoid_circle_cpp(as.double(lat))
}

#' @rdname ellipsoid_params
#' @export
ellipsoid_latitudes <- function(lat) {
  ellipsoid_latitudes_cpp(as.double(lat))
}

#' @rdname ellipsoid_params
#' @export
ellipsoid_latitudes_inv <- function(lat, type) {
  valid_types <- c("parametric", "geocentric", "rectifying", 
                   "authalic", "conformal", "isometric")
  if (!type %in% valid_types) {
    stop("type must be one of: ", paste(valid_types, collapse = ", "))
  }
  ellipsoid_latitudes_inv_cpp(as.double(lat), type)
}

#' @rdname ellipsoid_params
#' @export
ellipsoid_curvature <- function(lat) {
  ellipsoid_curvature_cpp(as.double(lat))
}
