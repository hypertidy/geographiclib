test_that("geocentric_fwd works with single point", {
  result <- geocentric_fwd(c(0, 0))
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("X", "Y", "Z", "lon", "lat", "h"))
  expect_equal(nrow(result), 1)
  
  # At equator/prime meridian, X should be ~6378km, Y and Z should be 0
  expect_equal(result$X, 6378137, tolerance = 1)
  expect_equal(result$Y, 0, tolerance = 1)
  expect_equal(result$Z, 0, tolerance = 1)
})

test_that("geocentric_fwd works at poles", {
  # North pole
  north <- geocentric_fwd(c(0, 90))
  expect_equal(north$X, 0, tolerance = 1)
  expect_equal(north$Y, 0, tolerance = 1)
  expect_true(north$Z > 6350000)  # Semi-minor axis
  
 # South pole
  south <- geocentric_fwd(c(0, -90))
  expect_equal(south$X, 0, tolerance = 1)
  expect_equal(south$Y, 0, tolerance = 1)
  expect_true(south$Z < -6350000)
})

test_that("geocentric_fwd works with multiple points", {
  pts <- cbind(lon = c(0, 90, 180, -90), lat = c(0, 0, 0, 0))
  result <- geocentric_fwd(pts)
  
  expect_equal(nrow(result), 4)
  
  # At equator, radius should be constant
  r <- sqrt(result$X^2 + result$Y^2 + result$Z^2)
  expect_equal(r, rep(6378137, 4), tolerance = 1)
})

test_that("geocentric_fwd handles height", {
  result_0 <- geocentric_fwd(c(0, 0), h = 0)
  result_1000 <- geocentric_fwd(c(0, 0), h = 1000)
  
  # X should increase by 1000m
  expect_equal(result_1000$X - result_0$X, 1000, tolerance = 0.01)
})

test_that("geocentric_fwd accepts different input formats", {
  result1 <- geocentric_fwd(c(10, 45))
  result2 <- geocentric_fwd(cbind(10, 45))
  result3 <- geocentric_fwd(list(lon = 10, lat = 45))
  
  expect_equal(result1$X, result2$X)
  expect_equal(result1$X, result3$X)
})

test_that("geocentric_rev returns correct structure", {
  result <- geocentric_rev(6378137, 0, 0)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("lon", "lat", "h", "X", "Y", "Z"))
  expect_equal(nrow(result), 1)
})

test_that("geocentric_rev is vectorized", {
  X <- c(6378137, 0, -6378137)
  Y <- c(0, 6378137, 0)
  Z <- c(0, 0, 0)
  result <- geocentric_rev(X, Y, Z)
  
  expect_equal(nrow(result), 3)
  expect_equal(result$lat, c(0, 0, 0), tolerance = 1e-6)
  expect_equal(result$lon, c(0, 90, 180), tolerance = 1e-6)
})

test_that("geocentric round-trip preserves location", {
  pts <- cbind(lon = c(-0.1, 147, -74), lat = c(51.5, -42, 40.7))
  h <- c(100, 500, 0)
  
  fwd <- geocentric_fwd(pts, h = h)
  rev <- geocentric_rev(fwd$X, fwd$Y, fwd$Z)
  
  expect_equal(rev$lon, pts[, 1], tolerance = 1e-9)
  expect_equal(rev$lat, pts[, 2], tolerance = 1e-9)
  expect_equal(rev$h, h, tolerance = 1e-6)
})

test_that("geocentric handles extreme heights", {
  # GPS satellite altitude ~20,000 km
  result <- geocentric_fwd(c(0, 0), h = 20000000)
  
  expect_true(result$X > 26000000)
  
  # Round-trip
  rev <- geocentric_rev(result$X, result$Y, result$Z)
  expect_equal(rev$h, 20000000, tolerance = 1)
})
