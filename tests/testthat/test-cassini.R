test_that("cassini_fwd works with single point", {
  result <- cassini_fwd(c(-100, 40), lon0 = -100, lat0 = 40)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("x", "y", "azi", "rk", "lon", "lat"))
  
  # Origin should map to (0, 0)
  expect_equal(result$x, 0, tolerance = 1e-9)
  expect_equal(result$y, 0, tolerance = 1e-9)
})

test_that("cassini_fwd works with multiple points", {
  pts <- cbind(lon = c(-100, -99, -101), lat = c(40, 41, 39))
  result <- cassini_fwd(pts, lon0 = -100, lat0 = 40)
  
  expect_equal(nrow(result), 3)
})

test_that("cassini central meridian property", {
  # Points along central meridian should have x = 0
  pts <- cbind(lon = c(-100, -100, -100), lat = c(38, 40, 42))
  result <- cassini_fwd(pts, lon0 = -100, lat0 = 40)
  
  expect_equal(result$x, c(0, 0, 0), tolerance = 1e-6)
})

test_that("cassini round-trip works", {
  pts <- cbind(lon = c(-100, -99, -101), lat = c(40, 41, 39))
  
  fwd <- cassini_fwd(pts, lon0 = -100, lat0 = 40)
  rev <- cassini_rev(fwd$x, fwd$y, lon0 = -100, lat0 = 40)
  
  expect_equal(rev$lon, pts[, 1], tolerance = 1e-9)
  expect_equal(rev$lat, pts[, 2], tolerance = 1e-9)
})

test_that("cassini_rev returns correct structure", {
  result <- cassini_rev(10000, 20000, lon0 = -100, lat0 = 40)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("lon", "lat", "azi", "rk", "x", "y"))
})
