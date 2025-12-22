test_that("geodesic_direct_fast works", {
  result <- geodesic_direct_fast(c(-0.1, 51.5), azi = 90, s = 1000000)
  
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_true(result$lon2 > result$lon1)  # Moved east
})

test_that("geodesic_inverse_fast works", {
  result <- geodesic_inverse_fast(c(-0.1, 51.5), c(-74, 40.7))
  
  expect_s3_class(result, "data.frame")
  expect_true(result$s12 > 5000000 && result$s12 < 6000000)  # ~5500 km
})

test_that("geodesic_fast matches geodesic_exact closely", {
  x <- c(-0.1, 51.5)
  y <- c(-74, 40.7)
  
  exact <- geodesic_inverse(x, y)
  fast <- geodesic_inverse_fast(x, y)
  
  # Should match to at least 1 mm
  expect_equal(exact$s12, fast$s12, tolerance = 0.001)
  expect_equal(exact$azi1, fast$azi1, tolerance = 1e-9)
})

test_that("geodesic_path_fast works", {
  path <- geodesic_path_fast(c(0, 0), c(10, 10), n = 10)
  
  expect_equal(nrow(path), 10)
  expect_equal(path$lon[1], 0, tolerance = 1e-9)
  expect_equal(path$lon[10], 10, tolerance = 1e-9)
})

test_that("geodesic_distance_fast works", {
  dist <- geodesic_distance_fast(c(0, 0), c(1, 0))
  
  expect_equal(dist, 111319.49, tolerance = 1)
})

test_that("geodesic_distance_matrix_fast works", {
  x <- cbind(c(0, 10), c(0, 10))
  result <- geodesic_distance_matrix_fast(x)
  
  expect_equal(dim(result), c(2, 2))
  expect_equal(diag(result), c(0, 0))
  expect_equal(result, t(result), tolerance = 1e-9)
})
