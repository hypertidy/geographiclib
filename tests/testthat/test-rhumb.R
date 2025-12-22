test_that("rhumb_direct works with single point", {
  result <- rhumb_direct(c(-0.1, 51.5), azi = 90, s = 1000000)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("lon1", "lat1", "azi12", "s12", "lon2", "lat2", "S12"))
  expect_equal(nrow(result), 1)
  
  # Check types
  expect_type(result$lon2, "double")
  expect_type(result$lat2, "double")
  expect_type(result$S12, "double")
  
  # Heading east from London should increase longitude
  expect_true(result$lon2 > result$lon1)
  
  # Latitude should be constant on east-west rhumb line
  expect_equal(result$lat2, result$lat1, tolerance = 1e-9)
})

test_that("rhumb_direct is vectorized", {
  # Multiple starting points, same azimuth and distance
  pts <- cbind(c(0, 10, 20), c(0, 10, 20))
  result <- rhumb_direct(pts, azi = 90, s = 100000)
  expect_equal(nrow(result), 3)
  
  # Single point, multiple azimuths
  result <- rhumb_direct(c(0, 0), azi = c(0, 90, 180, -90), s = 100000)
  expect_equal(nrow(result), 4)
  
  # Single point, multiple distances
  result <- rhumb_direct(c(0, 0), azi = 45, s = c(1000, 10000, 100000))
  expect_equal(nrow(result), 3)
})

test_that("rhumb_direct handles different input formats", {
  result1 <- rhumb_direct(c(0, 45), azi = 90, s = 100000)
  result2 <- rhumb_direct(cbind(0, 45), azi = 90, s = 100000)
  result3 <- rhumb_direct(list(lon = 0, lat = 45), azi = 90, s = 100000)
  
  expect_equal(result1$lon2, result2$lon2)
  expect_equal(result1$lon2, result3$lon2)
})

test_that("rhumb_inverse works with two points", {
  result <- rhumb_inverse(c(-0.1, 51.5), c(-74, 40.7))
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("lon1", "lat1", "lon2", "lat2", "s12", "azi12", "S12"))
  expect_equal(nrow(result), 1)
  
  # Rhumb distance from London to New York should be longer than geodesic
  # Geodesic is about 5570 km, rhumb should be longer
  expect_true(result$s12 > 5500000)
  
  # Azimuth should be roughly west-southwest
  expect_true(result$azi12 < 0)  # Negative = westward
})

test_that("rhumb_inverse is vectorized", {
  x <- cbind(c(0, 10, 20), c(0, 10, 20))
  y <- cbind(c(1, 11, 21), c(1, 11, 21))
  result <- rhumb_inverse(x, y)
  
  expect_equal(nrow(result), 3)
  expect_true(all(result$s12 > 0))
})

test_that("rhumb is longer than geodesic", {
  # This is a key property of rhumb lines
  london <- c(-0.1, 51.5)
  new_york <- c(-74, 40.7)
  
  rhumb_dist <- rhumb_inverse(london, new_york)$s12
  geodesic_dist <- geodesic_inverse(london, new_york)$s12
  
  expect_true(rhumb_dist > geodesic_dist)
})

test_that("rhumb round-trip is consistent", {
  # Direct then inverse should return to start
  start <- c(10, 45)
  azi <- 60
  dist <- 500000
  
  direct <- rhumb_direct(start, azi = azi, s = dist)
  inverse <- rhumb_inverse(start, c(direct$lon2, direct$lat2))
  
  expect_equal(inverse$s12, dist, tolerance = 1e-6)
  expect_equal(inverse$azi12, azi, tolerance = 1e-6)
})

test_that("rhumb_path generates correct number of points", {
  path <- rhumb_path(c(0, 0), c(10, 10), n = 50)
  
  expect_s3_class(path, "data.frame")
  expect_true("lon" %in% names(path))
  expect_true("lat" %in% names(path))
  expect_true("s" %in% names(path))
  expect_equal(nrow(path), 50)
  
  # First point should be start
  expect_equal(path$lon[1], 0, tolerance = 1e-9)
  expect_equal(path$lat[1], 0, tolerance = 1e-9)
  
  # Last point should be end
  expect_equal(path$lon[50], 10, tolerance = 1e-9)
  expect_equal(path$lat[50], 10, tolerance = 1e-9)
  
  # Distance should increase monotonically
  expect_true(all(diff(path$s) >= 0))
})

test_that("rhumb_path requires single points", {
  expect_error(rhumb_path(cbind(c(0, 1), c(0, 1)), c(10, 10)), 
               "single start and end")
})

test_that("rhumb_line works with multiple distances", {
  result <- rhumb_line(c(0, 0), azi = 45, distances = c(0, 100000, 500000, 1000000))
  
  expect_s3_class(result, "data.frame")
  expect_true("lon" %in% names(result))
  expect_true("lat" %in% names(result))
  expect_true("s" %in% names(result))
  expect_equal(nrow(result), 4)
  
  # First point should be at origin
  expect_equal(result$lon[1], 0, tolerance = 1e-9)
  expect_equal(result$lat[1], 0, tolerance = 1e-9)
  expect_equal(result$s[1], 0)
  
  # Distances should match input
  expect_equal(result$s, c(0, 100000, 500000, 1000000))
})

test_that("rhumb_line requires single point and azimuth", {
  expect_error(rhumb_line(cbind(c(0, 1), c(0, 1)), azi = 45, distances = 1000),
               "single starting point")
  expect_error(rhumb_line(c(0, 0), azi = c(45, 90), distances = 1000),
               "single azimuth")
})

test_that("rhumb_distance returns pairwise distances", {
  x <- cbind(c(0, 10, 20), c(0, 10, 20))
  y <- cbind(c(1, 11, 21), c(1, 11, 21))
  result <- rhumb_distance(x, y)
  
  expect_type(result, "double")
  expect_length(result, 3)
  expect_true(all(result > 0))
})

test_that("rhumb_distance handles recycling", {
  # Single point to multiple points
  result <- rhumb_distance(c(0, 0), cbind(c(1, 2, 3), c(1, 2, 3)))
  expect_length(result, 3)
  
  # Multiple points to single point
  result <- rhumb_distance(cbind(c(1, 2, 3), c(1, 2, 3)), c(0, 0))
  expect_length(result, 3)
})

test_that("rhumb_distance_matrix returns correct dimensions", {
  x <- cbind(c(0, 10, 20), c(0, 10, 20))
  y <- cbind(c(1, 11), c(1, 11))
  result <- rhumb_distance_matrix(x, y)
  
  expect_true(is.matrix(result))
  expect_equal(dim(result), c(3, 2))
  expect_true(all(result > 0))
})

test_that("rhumb_distance_matrix with single argument gives symmetric matrix", {
  x <- cbind(c(0, 10, 20), c(0, 10, 20))
  result <- rhumb_distance_matrix(x)
  
  expect_equal(dim(result), c(3, 3))
  
  # Diagonal should be zero
  expect_equal(diag(result), c(0, 0, 0), tolerance = 1e-9)
  
  # Should be symmetric
  expect_equal(result, t(result), tolerance = 1e-9)
})

test_that("rhumb east-west maintains constant latitude", {
  # Key property: east-west rhumb lines stay at constant latitude
  result <- rhumb_direct(c(0, 45), azi = 90, s = 1000000)
  expect_equal(result$lat2, 45, tolerance = 1e-9)
  
  result <- rhumb_direct(c(0, 45), azi = -90, s = 1000000)
  expect_equal(result$lat2, 45, tolerance = 1e-9)
})

test_that("rhumb north-south maintains constant longitude", {
  # Key property: north-south rhumb lines stay at constant longitude
  result <- rhumb_direct(c(10, 0), azi = 0, s = 1000000)
  expect_equal(result$lon2, 10, tolerance = 1e-9)
  
  result <- rhumb_direct(c(10, 0), azi = 180, s = 1000000)
  expect_equal(result$lon2, 10, tolerance = 1e-9)
})

test_that("rhumb calculations are accurate for known values", {
  # 1 degree of longitude at equator going east
  result <- rhumb_inverse(c(0, 0), c(1, 0))
  expect_equal(result$s12, 111319.49, tolerance = 1)
  
  # Azimuth should be exactly 90 degrees (east)
  expect_equal(result$azi12, 90, tolerance = 1e-6)
})

test_that("rhumb handles near-polar latitudes", {
  # High latitude points
  result <- rhumb_inverse(c(0, 85), c(45, 85))
  
  # Should be valid
  expect_true(is.finite(result$s12))
  expect_true(result$s12 > 0)
})

test_that("rhumb azimuth range is -180 to 180", {
  # Test various directions
  result <- rhumb_direct(c(0, 0), azi = c(0, 90, 180, -90, -180), s = 100000)
  
  # All azimuths should be in valid range
  expect_true(all(result$azi12 >= -180 & result$azi12 <= 180))
})
