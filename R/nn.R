#' Nearest Neighbor Search Using Geodesic Distance
#'
#' Find nearest neighbors on the WGS84 ellipsoid using geodesic distance.
#' These functions build an efficient vantage-point tree index for fast
#' repeated queries.
#'
#' @param dataset A matrix or vector of coordinates (lon, lat) for the dataset
#'   points. For a matrix, each row is a point. For a vector, it should be
#'   `c(lon, lat)` for a single point.
#' @param query A matrix or vector of coordinates (lon, lat) for the query
#'   points. Same format as `dataset`.
#' @param k Integer. The number of nearest neighbors to find.
#' @param radius Numeric. The search radius in meters.
#'
#' @return
#' For `geodesic_nn()`: A list with two matrices:
#' * `index`: Integer matrix (k x n_queries) of 1-based indices into `dataset`
#' * `distance`: Numeric matrix (k x n_queries) of geodesic distances in meters
#'
#' For `geodesic_nn_radius()`: A list of data frames, one per query point,
#' each containing:
#' * `index`: Integer vector of 1-based indices into `dataset`
#' * `distance`: Numeric vector of geodesic distances in meters
#'
#' @details
#' These functions use the GeographicLib NearestNeighbor class, which implements
#' a vantage-point tree optimized for geodesic distance calculations on the
#' WGS84 ellipsoid.
#'
#' The vantage-point tree provides O(log n) search complexity after O(n log n)
#' construction time. For repeated queries against the same dataset, this is
#' much more efficient than computing all pairwise distances.
#'
#' Distances are computed using the exact geodesic inverse formula, not
#' approximations like Haversine or Vincenty.
#'
#' @examples
#' # Create a dataset of cities
#' cities <- cbind(
#'   lon = c(151.21, 144.96, 153.03, 115.86, 138.60),
#'   lat = c(-33.87, -37.81, -27.47, -31.95, -34.93)
#' )
#' rownames(cities) <- c("Sydney", "Melbourne", "Brisbane", "Perth", "Adelaide")
#'
#' # Find 2 nearest neighbors for each city (including itself)
#' result <- geodesic_nn(cities, cities, k = 2)
#' result$index
#' result$distance
#'
#' # Query points not in the dataset
#' queries <- cbind(
#'   lon = c(149.13, 147.32),
#'   lat = c(-35.28, -42.88)
#' )
#' rownames(queries) <- c("Canberra", "Hobart")
#'
#' geodesic_nn(cities, queries, k = 3)
#'
#' # Find all cities within 1000 km
#' geodesic_nn_radius(cities, queries, radius = 1e6)
#'
#' @name geodesic_nn
#' @export
geodesic_nn <- function(dataset, query, k = 1L) {
  # Handle coordinate input
  if (is.list(dataset) && !is.data.frame(dataset)) dataset <- do.call(cbind, dataset[1:2])
  if (length(dataset) == 2) dataset <- matrix(dataset, ncol = 2)
  if (is.list(query) && !is.data.frame(query)) query <- do.call(cbind, query[1:2])
  if (length(query) == 2) query <- matrix(query, ncol = 2)
  
  k <- as.integer(k)
  
  if (k < 1) {
    stop("k must be at least 1")
  }
  
  nn_search_cpp(
    dataset[, 2], dataset[, 1],  # lat, lon
    query[, 2], query[, 1],
    k
  )
}

#' @rdname geodesic_nn
#' @export
geodesic_nn_radius <- function(dataset, query, radius) {
  # Handle coordinate input
  if (is.list(dataset) && !is.data.frame(dataset)) dataset <- do.call(cbind, dataset[1:2])
  if (length(dataset) == 2) dataset <- matrix(dataset, ncol = 2)
  if (is.list(query) && !is.data.frame(query)) query <- do.call(cbind, query[1:2])
  if (length(query) == 2) query <- matrix(query, ncol = 2)
  
  radius <- as.numeric(radius)
  
  if (length(radius) != 1 || radius < 0) {
    stop("radius must be a single non-negative number")
  }
  
  nn_search_radius_cpp(
    dataset[, 2], dataset[, 1],  # lat, lon
    query[, 2], query[, 1],
    radius
  )
}
