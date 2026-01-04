test_that("geodesic_nn finds correct nearest neighbors", {
  # Simple dataset
  dataset <- cbind(
    lon = c(0, 10, 20, 30),
    lat = c(0, 0, 0, 0)
  )
  
  # Query at origin - nearest should be first point
 result <- geodesic_nn(dataset, c(0, 0), k = 1)
  expect_equal(result$index[1, 1], 1L)
  expect_equal(result$distance[1, 1], 0, tolerance = 1e-6)
  
  # Query at (5, 0) - nearest should be either point 1 or 2
  result <- geodesic_nn(dataset, c(5, 0), k = 2)
  expect_true(all(result$index[, 1] %in% c(1L, 2L)))
})

test_that("geodesic_nn returns correct dimensions", {
  dataset <- cbind(
    lon = c(0, 10, 20, 30, 40),
    lat = c(0, 10, 20, 30, 40)
  )
  
  queries <- cbind(
    lon = c(5, 15, 25),
    lat = c(5, 15, 25)
  )
  
  result <- geodesic_nn(dataset, queries, k = 3)
  
  # Should be k x n_queries
  expect_equal(dim(result$index), c(3, 3))
  expect_equal(dim(result$distance), c(3, 3))
})

test_that("geodesic_nn handles k larger than dataset", {
  dataset <- cbind(lon = c(0, 10), lat = c(0, 10))
  query <- c(5, 5)
  
  # k=5 but only 2 points - should return 2
  result <- geodesic_nn(dataset, query, k = 5)
  expect_equal(nrow(result$index), 2)
})

test_that("geodesic_nn distances are geodesic", {
  # Two points on equator
  dataset <- cbind(lon = 10, lat = 0)
  query <- c(0, 0)
  
  result <- geodesic_nn(dataset, query, k = 1)
  
  # Compare with geodesic_inverse
  expected <- geodesic_inverse(query, dataset)
  expect_equal(result$distance[1, 1], expected$s12, tolerance = 1)
})

test_that("geodesic_nn_radius finds all points within radius", {
  # Points at known distances from origin
  dataset <- cbind(
    lon = c(0, 1, 2, 3),
    lat = c(0, 0, 0, 0)
  )
  query <- c(0, 0)
  
  # 1 degree at equator is ~111 km
  result <- geodesic_nn_radius(dataset, query, radius = 250000)  # 250 km
  
  # Should include points at 0 and 1 degree (0 and ~111 km)
  expect_true(1 %in% result[[1]]$index)
  expect_true(2 %in% result[[1]]$index)
  # Point at 2 degrees (~222 km) should also be included
  expect_true(3 %in% result[[1]]$index)
  # Point at 3 degrees (~333 km) should be excluded
  expect_false(4 %in% result[[1]]$index)
})

test_that("geodesic_nn_radius returns empty for zero radius at non-dataset point", {
  dataset <- cbind(lon = c(0, 10), lat = c(0, 10))
  query <- c(5, 5)
  
  result <- geodesic_nn_radius(dataset, query, radius = 0)
  expect_equal(nrow(result[[1]]), 0)
})

test_that("geodesic_nn_radius returns list of correct length", {
  dataset <- cbind(lon = c(0, 10, 20), lat = c(0, 10, 20))
  queries <- cbind(lon = c(0, 10), lat = c(0, 10))
  
  result <- geodesic_nn_radius(dataset, queries, radius = 1e6)
  expect_length(result, 2)
})

test_that("geodesic_nn handles NA in query", {
  dataset <- cbind(lon = c(0, 10), lat = c(0, 10))
  queries <- cbind(lon = c(0, NA), lat = c(0, 5))
  
  result <- geodesic_nn(dataset, queries, k = 1)
  expect_false(is.na(result$index[1, 1]))
  expect_true(is.na(result$index[1, 2]))
})

test_that("geodesic_nn_radius handles NA in query", {
  dataset <- cbind(lon = c(0, 10), lat = c(0, 10))
  queries <- cbind(lon = c(0, NA), lat = c(0, 5))
  
  result <- geodesic_nn_radius(dataset, queries, radius = 1e6)
  expect_gt(nrow(result[[1]]), 0)
  expect_equal(nrow(result[[2]]), 0)
})

test_that("geodesic_nn works with single point dataset", {
  dataset <- c(151.21, -33.87)
  query <- c(144.96, -37.81)
  
  result <- geodesic_nn(dataset, query, k = 1)
  expect_equal(result$index[1, 1], 1L)
  expect_gt(result$distance[1, 1], 0)
})

test_that("geodesic_nn errors on invalid k", {
  dataset <- cbind(lon = c(0, 10), lat = c(0, 10))
  expect_error(geodesic_nn(dataset, c(0, 0), k = 0))
  expect_error(geodesic_nn(dataset, c(0, 0), k = -1))
})

test_that("geodesic_nn_radius errors on invalid radius", {
  dataset <- cbind(lon = c(0, 10), lat = c(0, 10))
  expect_error(geodesic_nn_radius(dataset, c(0, 0), radius = -1))
  expect_error(geodesic_nn_radius(dataset, c(0, 0), radius = c(100, 200)))
})

test_that("geodesic_nn self-search returns identity first", {
  dataset <- cbind(
    lon = c(151.21, 144.96, 153.03),
    lat = c(-33.87, -37.81, -27.47)
  )
  
  # Search dataset against itself
  result <- geodesic_nn(dataset, dataset, k = 1)
  
  # First neighbor of each point should be itself
  expect_equal(result$index[1, ], 1:3)
  # Distance to self should be 0
  expect_equal(as.vector(result$distance), c(0, 0, 0), tolerance = 1e-6)
})

test_that("geodesic_nn returns sorted by distance", {
  dataset <- cbind(
    lon = c(0, 5, 10, 15, 20),
    lat = c(0, 0, 0, 0, 0)
  )
  query <- c(0, 0)
  
  result <- geodesic_nn(dataset, query, k = 5)
  
  # Distances should be in ascending order
  dists <- result$distance[, 1]
  expect_equal(dists, sort(dists))
})
