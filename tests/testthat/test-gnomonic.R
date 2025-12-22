test_that("gnomonic_fwd works with single point", {
  result <- gnomonic_fwd(c(-0.1, 51.5), lon0 = -0.1, lat0 = 51.5)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("x", "y", "azi", "rk", "lon", "lat"))
  
  # Center should map to (0, 0)
  expect_equal(result$x, 0, tolerance = 1e-9)
  expect_equal(result$y, 0, tolerance = 1e-9)
})

test_that("gnomonic_fwd works with multiple points", {
  cities <- cbind(
    lon = c(-74, 139.7, 2.3),
    lat = c(40.7, 35.7, 48.9)
  )
  result <- gnomonic_fwd(cities, lon0 = -0.1, lat0 = 51.5)
  
  expect_equal(nrow(result), 3)
})

test_that("gnomonic geodesics appear as straight lines", {
  # Generate geodesic path
  path <- geodesic_path(c(-0.1, 51.5), c(-74, 40.7), n = 20)
  
  # Project to gnomonic centered at midpoint
  projected <- gnomonic_fwd(cbind(path$lon, path$lat), lon0 = -37, lat0 = 46)
  
  # Fit a line and check R^2
  fit <- lm(projected$y ~ projected$x)
  r_squared <- summary(fit)$r.squared
  
  # Should be nearly perfect linear fit

  expect_true(r_squared > 0.999)
})

test_that("gnomonic round-trip works", {
  pts <- cbind(lon = c(-10, 0, 10), lat = c(50, 52, 54))
  
  fwd <- gnomonic_fwd(pts, lon0 = 0, lat0 = 52)
  rev <- gnomonic_rev(fwd$x, fwd$y, lon0 = 0, lat0 = 52)
  
  expect_equal(rev$lon, pts[, 1], tolerance = 1e-9)
  expect_equal(rev$lat, pts[, 2], tolerance = 1e-9)
})

test_that("gnomonic_rev returns correct structure", {
  result <- gnomonic_rev(100000, 200000, lon0 = 0, lat0 = 51.5)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("lon", "lat", "azi", "rk", "x", "y"))
})

test_that("gnomonic handles different center points", {
  # Same point projected from different centers
  pt <- c(10, 50)
  
  result1 <- gnomonic_fwd(pt, lon0 = 0, lat0 = 50)
  result2 <- gnomonic_fwd(pt, lon0 = 10, lat0 = 50)
  
  # From center 2, the point is at origin
  expect_equal(result2$x, 0, tolerance = 1e-9)
  expect_equal(result2$y, 0, tolerance = 1e-9)
  
  # From center 1, it's not
  expect_true(result1$x != 0)
})
