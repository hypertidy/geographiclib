test_that("azeq_fwd works with single point", {
  result <- azeq_fwd(c(-74, 40.7), lon0 = -0.1, lat0 = 51.5)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("x", "y", "azi", "scale", "lon", "lat"))
  expect_equal(nrow(result), 1)
})

test_that("azeq_fwd center point maps to origin", {
  result <- azeq_fwd(c(-0.1, 51.5), lon0 = -0.1, lat0 = 51.5)
  
  expect_equal(result$x, 0, tolerance = 1e-6)
  expect_equal(result$y, 0, tolerance = 1e-6)
})

test_that("azeq_fwd distance equals geodesic distance", {
  # NYC
  result <- azeq_fwd(c(-74, 40.7), lon0 = -0.1, lat0 = 51.5)
  proj_dist <- sqrt(result$x^2 + result$y^2)
  
  # Compare with geodesic distance
  geod_dist <- geodesic_inverse(c(-0.1, 51.5), c(-74, 40.7))$s12
  
  expect_equal(proj_dist, geod_dist, tolerance = 1)
})

test_that("azeq_fwd works with multiple points", {
  pts <- cbind(lon = c(-74, 139.7, 151.2), lat = c(40.7, 35.7, -33.9))
  result <- azeq_fwd(pts, lon0 = -0.1, lat0 = 51.5)
  
  expect_equal(nrow(result), 3)
})

test_that("azeq_fwd accepts different input formats", {
  result1 <- azeq_fwd(c(-74, 40.7), lon0 = 0, lat0 = 0)
  result2 <- azeq_fwd(cbind(-74, 40.7), lon0 = 0, lat0 = 0)
  result3 <- azeq_fwd(list(lon = -74, lat = 40.7), lon0 = 0, lat0 = 0)
  
  expect_equal(result1$x, result2$x)
  expect_equal(result1$x, result3$x)
})

test_that("azeq_rev returns correct structure", {
  result <- azeq_rev(1000000, 500000, lon0 = -0.1, lat0 = 51.5)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("lon", "lat", "azi", "scale", "x", "y"))
  expect_equal(nrow(result), 1)
})

test_that("azeq_rev origin maps to center", {
  result <- azeq_rev(0, 0, lon0 = -0.1, lat0 = 51.5)
  
  expect_equal(result$lon, -0.1, tolerance = 1e-9)
  expect_equal(result$lat, 51.5, tolerance = 1e-9)
})

test_that("azeq_rev is vectorized", {
  x <- c(100000, 200000, 300000)
  y <- c(50000, 100000, 150000)
  result <- azeq_rev(x, y, lon0 = 0, lat0 = 0)
  
  expect_equal(nrow(result), 3)
})

test_that("azeq round-trip preserves location", {
  pts <- cbind(lon = c(-74, 139.7, 151.2, 0), 
               lat = c(40.7, 35.7, -33.9, 0))
  
  fwd <- azeq_fwd(pts, lon0 = -0.1, lat0 = 51.5)
  rev <- azeq_rev(fwd$x, fwd$y, lon0 = -0.1, lat0 = 51.5)
  
  expect_equal(rev$lon, pts[, 1], tolerance = 1e-9)
  expect_equal(rev$lat, pts[, 2], tolerance = 1e-9)
})

test_that("azeq azimuth is correct", {
  # Point due east (azimuth ~90)
  result <- azeq_fwd(c(10, 0), lon0 = 0, lat0 = 0)
  expect_equal(result$azi, 90, tolerance = 1)
  
  # Point due north (azimuth ~0)
  result <- azeq_fwd(c(0, 10), lon0 = 0, lat0 = 0)
  expect_equal(result$azi, 0, tolerance = 1)
})

test_that("azeq scale is 1 at center", {
  # Scale should be 1 at the center point
  # Test a point very close to center
  result <- azeq_fwd(c(-0.1001, 51.5001), lon0 = -0.1, lat0 = 51.5)
  expect_equal(result$scale, 1, tolerance = 0.01)
})

test_that("azeq works with polar center", {
  # North pole centered
  pts <- cbind(lon = c(0, 90, 180, -90), lat = c(80, 80, 80, 80))
  result <- azeq_fwd(pts, lon0 = 0, lat0 = 90)
  
  expect_equal(nrow(result), 4)
  
  # All points at same latitude should be same distance from center
  distances <- sqrt(result$x^2 + result$y^2)
  expect_equal(distances, rep(distances[1], 4), tolerance = 1)
})

test_that("azeq handles antipodal points", {
  # Antipodal to center
  result <- azeq_fwd(c(179.9, -51.5), lon0 = -0.1, lat0 = 51.5)
  
  # Should still return valid coordinates
  expect_true(is.finite(result$x))
  expect_true(is.finite(result$y))
  
  # Distance should be approximately half circumference
  dist <- sqrt(result$x^2 + result$y^2)
  expect_true(dist > 19000000 && dist < 21000000)
})
