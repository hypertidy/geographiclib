test_that("geodesic_direct works with single point", {
  result <- geodesic_direct(c(-0.1, 51.5), azi = 90, s = 1000000)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("lon1", "lat1", "azi1", "s12", "lon2", "lat2",
                         "azi2", "m12", "M12", "M21", "S12"))
  expect_equal(nrow(result), 1)

  # Check types
  expect_type(result$lon2, "double")
  expect_type(result$lat2, "double")
  expect_type(result$azi2, "double")

  # Heading east from London should increase longitude
  expect_true(result$lon2 > result$lon1)
})

test_that("geodesic_direct is vectorized", {
  # Multiple starting points, same azimuth and distance
  pts <- cbind(c(0, 10, 20), c(0, 10, 20))
  result <- geodesic_direct(pts, azi = 90, s = 100000)
  expect_equal(nrow(result), 3)

  # Single point, multiple azimuths
  result <- geodesic_direct(c(0, 0), azi = c(0, 90, 180, 270), s = 100000)
  expect_equal(nrow(result), 4)

  # Single point, multiple distances
  result <- geodesic_direct(c(0, 0), azi = 45, s = c(1000, 10000, 100000))
  expect_equal(nrow(result), 3)
})

test_that("geodesic_direct handles different input formats", {
  result1 <- geodesic_direct(c(0, 45), azi = 90, s = 100000)
  result2 <- geodesic_direct(cbind(0, 45), azi = 90, s = 100000)
  result3 <- geodesic_direct(list(lon = 0, lat = 45), azi = 90, s = 100000)

  expect_equal(result1$lon2, result2$lon2)
  expect_equal(result1$lon2, result3$lon2)
})

test_that("geodesic_inverse works with two points", {
  result <- geodesic_inverse(c(-0.1, 51.5), c(-74, 40.7))

  expect_s3_class(result, "data.frame")
  expect_named(result, c("lon1", "lat1", "lon2", "lat2", "s12",
                         "azi1", "azi2", "m12", "M12", "M21", "S12"))
  expect_equal(nrow(result), 1)

  # London to New York is roughly 5500 km
  expect_true(result$s12 > 5000000 && result$s12 < 6000000)

  # Azimuth from London to NY should be roughly west (250-290 degrees)
  expect_true(result$azi1 > -73 && result$azi1 < -70)

})

test_that("geodesic_inverse is vectorized", {
  x <- cbind(c(0, 10, 20), c(0, 10, 20))
  y <- cbind(c(1, 11, 21), c(1, 11, 21))
  result <- geodesic_inverse(x, y)

  expect_equal(nrow(result), 3)
  expect_true(all(result$s12 > 0))
})

test_that("geodesic round-trip is consistent", {
  # Direct then inverse should return to start
  start <- c(10, 45)
  azi <- 60
  dist <- 500000

  direct <- geodesic_direct(start, azi = azi, s = dist)
  inverse <- geodesic_inverse(start, c(direct$lon2, direct$lat2))

  expect_equal(inverse$s12, dist, tolerance = 1e-6)
  expect_equal(inverse$azi1, azi, tolerance = 1e-6)
})

test_that("geodesic_path generates correct number of points", {
  path <- geodesic_path(c(0, 0), c(10, 10), n = 50)

  expect_s3_class(path, "data.frame")
  expect_named(path, c("lon", "lat", "azi", "s"))
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

test_that("geodesic_path requires single points", {
  expect_error(geodesic_path(cbind(c(0, 1), c(0, 1)), c(10, 10)),
               "single start and end")
})

test_that("geodesic_line works with multiple distances", {
  result <- geodesic_line(c(0, 0), azi = 45, distances = c(0, 100000, 500000, 1000000))

  expect_s3_class(result, "data.frame")
  expect_named(result, c("lon", "lat", "azi", "s"))
  expect_equal(nrow(result), 4)

  # First point should be at origin
  expect_equal(result$lon[1], 0, tolerance = 1e-9)
  expect_equal(result$lat[1], 0, tolerance = 1e-9)
  expect_equal(result$s[1], 0)

  # Distances should match input
  expect_equal(result$s, c(0, 100000, 500000, 1000000))
})

test_that("geodesic_line requires single point and azimuth", {
  expect_error(geodesic_line(cbind(c(0, 1), c(0, 1)), azi = 45, distances = 1000),
               "single starting point")
  expect_error(geodesic_line(c(0, 0), azi = c(45, 90), distances = 1000),
               "single azimuth")
})

test_that("geodesic_distance returns pairwise distances", {
  x <- cbind(c(0, 10, 20), c(0, 10, 20))
  y <- cbind(c(1, 11, 21), c(1, 11, 21))
  result <- geodesic_distance(x, y)

  expect_type(result, "double")
  expect_length(result, 3)
  expect_true(all(result > 0))
})

test_that("geodesic_distance handles recycling", {
  # Single point to multiple points
  result <- geodesic_distance(c(0, 0), cbind(c(1, 2, 3), c(1, 2, 3)))
  expect_length(result, 3)

  # Multiple points to single point
  result <- geodesic_distance(cbind(c(1, 2, 3), c(1, 2, 3)), c(0, 0))
  expect_length(result, 3)
})

test_that("geodesic_distance_matrix returns correct dimensions", {
  x <- cbind(c(0, 10, 20), c(0, 10, 20))
  y <- cbind(c(1, 11), c(1, 11))
  result <- geodesic_distance_matrix(x, y)

  expect_true(is.matrix(result))
  expect_equal(dim(result), c(3, 2))
  expect_true(all(result > 0))
})

test_that("geodesic_distance_matrix with single argument gives symmetric matrix", {
  x <- cbind(c(0, 10, 20), c(0, 10, 20))
  result <- geodesic_distance_matrix(x)

  expect_equal(dim(result), c(3, 3))

  # Diagonal should be zero
  expect_equal(diag(result), c(0, 0, 0), tolerance = 1e-9)

  # Should be symmetric
  expect_equal(result, t(result), tolerance = 1e-9)
})

test_that("geodesic calculations are accurate for known values", {
  # Test against known geodesic: equator crossing
  # 1 degree of longitude at equator is approximately 111.32 km
  result <- geodesic_inverse(c(0, 0), c(1, 0))
  expect_equal(result$s12, 111319.49, tolerance = 1)

  # Azimuth should be exactly 90 degrees (east)
  expect_equal(result$azi1, 90, tolerance = 1e-6)
})

test_that("geodesic handles antipodal points", {
  # Points on opposite sides of Earth
  result <- geodesic_inverse(c(0, 0), c(180, 0))

  # Should be half circumference of Earth (~20,000 km)
  expect_true(result$s12 > 20000000 && result$s12 < 20050000)
})

test_that("geodesic handles polar routes", {
  # Route over North Pole
  result <- geodesic_inverse(c(0, 80), c(180, 80))

  # Should be valid
  expect_true(is.finite(result$s12))
  expect_true(result$s12 > 0)

  # Azimuth from 0 longitude going to 180 over pole should be ~0 (north)
  expect_true(abs(result$azi1) < 1 || abs(result$azi1 - 360) < 1)
})

test_that("geodesic path points lie on geodesic", {
  path <- geodesic_path(c(0, 0), c(45, 45), n = 10)

  # Each segment should have consistent azimuth (approximately)
  for (i in 2:9) {
    inv <- geodesic_inverse(c(path$lon[i], path$lat[i]),
                            c(path$lon[i + 1], path$lat[i + 1]))
    # Forward azimuth should be close to the azimuth at that point
    expect_equal(inv$azi1, path$azi[i], tolerance = 0.1)
  }
})
