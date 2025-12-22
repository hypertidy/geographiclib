test_that("localcartesian_fwd works with single point", {
  result <- localcartesian_fwd(c(-0.1, 51.5), lon0 = -0.1, lat0 = 51.5)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("x", "y", "z", "lon", "lat", "h"))
  
  # Origin should map to (0, 0, 0)
  expect_equal(result$x, 0, tolerance = 1e-9)
  expect_equal(result$y, 0, tolerance = 1e-9)
  expect_equal(result$z, 0, tolerance = 1e-9)
})

test_that("localcartesian_fwd works with multiple points", {
  pts <- cbind(lon = c(-0.1, -0.2, 0.0), lat = c(51.5, 51.6, 51.4))
  result <- localcartesian_fwd(pts, lon0 = -0.1, lat0 = 51.5)
  
  expect_equal(nrow(result), 3)
})

test_that("localcartesian directions are correct", {
  # Point east of origin
  east <- localcartesian_fwd(c(0.1, 51.5), lon0 = 0, lat0 = 51.5)
  expect_true(east$x > 0)
  expect_true(abs(east$y) < abs(east$x))
  
  # Point north of origin
  north <- localcartesian_fwd(c(0, 51.6), lon0 = 0, lat0 = 51.5)
  expect_true(north$y > 0)
  expect_true(abs(north$x) < abs(north$y))
})

test_that("localcartesian_fwd handles height", {
  # Point at 1000m altitude
  result <- localcartesian_fwd(c(-0.1, 51.5), lon0 = -0.1, lat0 = 51.5, h = 1000)
  
  expect_equal(result$x, 0, tolerance = 1e-9)
  expect_equal(result$y, 0, tolerance = 1e-9)
  expect_equal(result$z, 1000, tolerance = 0.1)
})

test_that("localcartesian round-trip works", {
  pts <- cbind(lon = c(-0.1, -0.2, 0.1), lat = c(51.5, 51.6, 51.4))
  
  fwd <- localcartesian_fwd(pts, lon0 = 0, lat0 = 51.5)
  rev <- localcartesian_rev(fwd$x, fwd$y, fwd$z, lon0 = 0, lat0 = 51.5)
  
  expect_equal(rev$lon, pts[, 1], tolerance = 1e-9)
  expect_equal(rev$lat, pts[, 2], tolerance = 1e-9)
})

test_that("localcartesian_rev returns correct structure", {
  result <- localcartesian_rev(1000, 2000, 100, lon0 = 0, lat0 = 51.5)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("lon", "lat", "h", "x", "y", "z"))
})
