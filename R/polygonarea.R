#' Compute geodesic polygon area and perimeter
#'
#' @description
#' Compute the area and perimeter of a polygon on the WGS84 ellipsoid using
#' geodesic calculations. This gives accurate results for polygons of any size,
#' including those spanning large portions of the globe.
#'
#' @param x A two-column matrix or data frame of coordinates (longitude, latitude)
#'   in decimal degrees defining polygon vertices, or a list with longitude and
#'   latitude components.
#' @param id Optional integer vector identifying separate polygons. Points with
#'   the same id are treated as vertices of the same polygon. If NULL (default),
#'   all points are treated as a single polygon.
#' @param polyline Logical. If FALSE (default), compute area and perimeter of a

#'   closed polygon. If TRUE, compute only the length of a polyline (area will
#'   be meaningless).
#'
#' @returns
#' * For a single polygon (id = NULL): A list with components:
#'   - `area`: Signed area in square meters. Positive for counter-clockwise
#'     polygons, negative for clockwise.
#'   - `perimeter`: Perimeter in meters.
#'   - `n`: Number of vertices.
#'
#' * For multiple polygons (id specified): A data frame with columns:
#'   - `id`: Polygon identifier
#'   - `area`: Signed area in square meters
#'   - `perimeter`: Perimeter in meters
#'   - `n`: Number of vertices
#'
#' @details
#' The polygon area is computed using the geodesic method which accounts for

#' the ellipsoidal shape of the Earth. This is more accurate than spherical
#' approximations, especially for large polygons.
#'
#' The area is signed: counter-clockwise polygons have positive area, clockwise
#' polygons have negative area. The absolute value gives the actual area.
#'
#' For very large polygons (more than half the Earth's surface), the sign
#' convention may seem counterintuitive - the "inside" is the smaller region.
#'
#' The computation uses the WGS84 ellipsoid (the same as GPS).
#'
#' @export
#'
#' @examples
#' # Triangle: London - New York - Rio de Janeiro
#' pts <- cbind(
#'   lon = c(0, -74, -43),
#'   lat = c(52, 41, -23)
#' )
#' polygon_area(pts)
#'
#' # Multiple polygons using id
#' pts <- cbind(
#'   lon = c(0, -74, -43, 100, 110, 105),
#'   lat = c(52, 41, -23, 10, 10, 20)
#' )
#' polygon_area(pts, id = c(1, 1, 1, 2, 2, 2))
#'
#' # Polyline length (not a closed polygon)
#' polygon_area(pts[1:3, ], polyline = TRUE)
#'
#' # Area of Australia (approximate boundary)
#' australia <- cbind(
#'   lon = c(113, 153, 153, 142, 129, 113),
#'   lat = c(-26, -26, -10, -10, -15, -26)
#' )
#' result <- polygon_area(australia)
#' # Area in square kilometers
#' abs(result$area) / 1e6
polygon_area <- function(x, id = NULL, polyline = FALSE) {
  if (is.list(x) && !is.data.frame(x)) {
    x <- do.call(cbind, x[1:2])
  }
  if (is.vector(x) && length(x) == 2) {
    stop("polygon_area requires at least 3 points")
  }

  lon <- x[, 1L, drop = TRUE]
  lat <- x[, 2L, drop = TRUE]

  if (length(lon) < 3 && !polyline) {
    stop("polygon_area requires at least 3 points for a polygon")
  }
  if (length(lon) < 2 && polyline) {
    stop("polygon_area requires at least 2 points for a polyline")
  }

  if (is.null(id)) {
    polygonarea_single_cpp(lon, lat, polyline)
  } else {
    id <- as.integer(rep_len(id, length(lon)))
    polygonarea_cpp(lon, lat, id, polyline)
  }
}

#' Compute cumulative polygon area and perimeter
#'
#' @description
#' Compute the area and perimeter of a polygon at each vertex, showing how
#' the measurements accumulate as vertices are added.
#'
#' @inheritParams polygon_area
#'
#' @returns A data frame with columns:
#'   - `lon`: Longitude of vertex
#'   - `lat`: Latitude of vertex
#'   - `area`: Cumulative area in square meters up to this vertex
#'   - `perimeter`: Cumulative perimeter in meters up to this vertex
#'
#' @details
#' This function is useful for understanding how polygon area accumulates
#' and for debugging polygon vertex order issues.
#'
#' @export
#'
#' @examples
#' # Watch area accumulate as vertices are added
#' pts <- cbind(
#'   lon = c(0, -74, -43, 28),
#'   lat = c(52, 41, -23, -26)
#' )
#' polygon_area_cumulative(pts)
polygon_area_cumulative <- function(x, polyline = FALSE) {
  if (is.list(x) && !is.data.frame(x)) {
    x <- do.call(cbind, x[1:2])
  }

  lon <- x[, 1L, drop = TRUE]
  lat <- x[, 2L, drop = TRUE]

  polygonarea_cumulative_cpp(lon, lat, polyline)
}
