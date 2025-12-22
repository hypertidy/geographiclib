test_that("lcc_fwd works with single standard parallel", {
  pts <- cbind(lon = c(-100, -99, -98), lat = c(40, 41, 42))
  result <- lcc_fwd(pts, lon0 = -100, stdlat = 40)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("x", "y", "convergence", "scale", "lon", "lat"))
  expect_equal(nrow(result), 3)
  
  # Check types
  expect_type(result$x, "double")
  expect_type(result$y, "double")
  expect_type(result$convergence, "double")
  expect_type(result$scale, "double")
  
  # Point on central meridian and standard parallel should have x=0
  result_origin <- lcc_fwd(c(-100, 40), lon0 = -100, stdlat = 40)
  expect_equal(result_origin$x, 0, tolerance = 1e-6)
  
  # Scale at standard parallel should be k0 (default 1)
  expect_equal(result_origin$scale, 1, tolerance = 1e-9)
})

test_that("lcc_fwd works with two standard parallels", {
  pts <- cbind(lon = c(-100, -99, -98), lat = c(40, 41, 42))
  result <- lcc_fwd(pts, lon0 = -96, stdlat1 = 33, stdlat2 = 45)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("x", "y", "convergence", "scale", "lon", "lat"))
  expect_equal(nrow(result), 3)
  
  # Scale should be 1 at both standard parallels
  result_sp1 <- lcc_fwd(c(-96, 33), lon0 = -96, stdlat1 = 33, stdlat2 = 45)
  result_sp2 <- lcc_fwd(c(-96, 45), lon0 = -96, stdlat1 = 33, stdlat2 = 45)
  expect_equal(result_sp1$scale, 1, tolerance = 1e-9)
  expect_equal(result_sp2$scale, 1, tolerance = 1e-9)
})

test_that("lcc_fwd accepts different input formats", {
  result1 <- lcc_fwd(c(-100, 40), lon0 = -100, stdlat = 40)
  result2 <- lcc_fwd(cbind(-100, 40), lon0 = -100, stdlat = 40)
  result3 <- lcc_fwd(list(lon = -100, lat = 40), lon0 = -100, stdlat = 40)
  
  expect_equal(result1$x, result2$x)
  expect_equal(result1$x, result3$x)
  expect_equal(result1$y, result2$y)
})

test_that("lcc_fwd requires standard parallel specification", {
  expect_error(lcc_fwd(c(-100, 40), lon0 = -100), 
               "Specify either")
  expect_error(lcc_fwd(c(-100, 40), lon0 = -100, stdlat1 = 33), 
               "Specify either")
})

test_that("lcc_rev works with single standard parallel", {
  # First do forward
  pts <- cbind(lon = c(-100, -99, -98), lat = c(40, 41, 42))
  fwd <- lcc_fwd(pts, lon0 = -100, stdlat = 40)
  
  # Then reverse
  result <- lcc_rev(fwd$x, fwd$y, lon0 = -100, stdlat = 40)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("lon", "lat", "convergence", "scale", "x", "y"))
  expect_equal(nrow(result), 3)
  
  # Should recover original coordinates
  expect_equal(result$lon, pts[, 1], tolerance = 1e-9)
  expect_equal(result$lat, pts[, 2], tolerance = 1e-9)
})

test_that("lcc_rev works with two standard parallels", {
  # First do forward
  pts <- cbind(lon = c(-100, -99, -98), lat = c(40, 41, 42))
  fwd <- lcc_fwd(pts, lon0 = -96, stdlat1 = 33, stdlat2 = 45)
  
  # Then reverse
  result <- lcc_rev(fwd$x, fwd$y, lon0 = -96, stdlat1 = 33, stdlat2 = 45)
  
  # Should recover original coordinates
  expect_equal(result$lon, pts[, 1], tolerance = 1e-9)
  expect_equal(result$lat, pts[, 2], tolerance = 1e-9)
})

test_that("lcc round-trip preserves coordinates", {
  pts <- cbind(
    lon = runif(10, -120, -80),
    lat = runif(10, 30, 50)
  )
  
  # Single standard parallel
  fwd1 <- lcc_fwd(pts, lon0 = -100, stdlat = 40)
  rev1 <- lcc_rev(fwd1$x, fwd1$y, lon0 = -100, stdlat = 40)
  expect_equal(rev1$lon, pts[, 1], tolerance = 1e-9)
  expect_equal(rev1$lat, pts[, 2], tolerance = 1e-9)
  
  # Two standard parallels
  fwd2 <- lcc_fwd(pts, lon0 = -100, stdlat1 = 35, stdlat2 = 45)
  rev2 <- lcc_rev(fwd2$x, fwd2$y, lon0 = -100, stdlat1 = 35, stdlat2 = 45)
  expect_equal(rev2$lon, pts[, 1], tolerance = 1e-9)
  expect_equal(rev2$lat, pts[, 2], tolerance = 1e-9)
})

test_that("lcc convergence is zero on central meridian", {
  pts <- cbind(lon = -100, lat = c(35, 40, 45))
  result <- lcc_fwd(pts, lon0 = -100, stdlat = 40)
  
  expect_equal(result$convergence, c(0, 0, 0), tolerance = 1e-9)
})

test_that("lcc handles points far from central meridian", {
  # Point 30 degrees away from central meridian
  result <- lcc_fwd(c(-130, 40), lon0 = -100, stdlat = 40)
  
  expect_true(is.finite(result$x))
  expect_true(is.finite(result$y))
  expect_true(result$x < 0)  # West of central meridian
  
  # Should still round-trip
  rev <- lcc_rev(result$x, result$y, lon0 = -100, stdlat = 40)
  expect_equal(rev$lon, -130, tolerance = 1e-9)
  expect_equal(rev$lat, 40, tolerance = 1e-9)
})

test_that("lcc scale varies correctly with latitude", {
  # Between standard parallels, scale should be < 1 (secant cone)
  # Outside standard parallels, scale should be > 1
  
  pts <- cbind(lon = -100, lat = c(30, 39, 45, 50))
  result <- lcc_fwd(pts, lon0 = -100, stdlat1 = 35, stdlat2 = 45)
  
  # At lat 30 (below stdlat1=35): scale > 1
  expect_true(result$scale[1] > 1)
  
  # At lat 39 (between 35 and 45): scale < 1
  expect_true(result$scale[2] < 1)
  
  # At lat 45 (at stdlat2): scale = 1
  expect_equal(result$scale[3], 1, tolerance = 1e-9)
  
  # At lat 50 (above stdlat2=45): scale > 1
  expect_true(result$scale[4] > 1)
})

test_that("lcc handles custom scale factors", {
  pt <- c(-100, 40)
  
  # With k0 = 0.9996 (like UTM)
  result <- lcc_fwd(pt, lon0 = -100, stdlat = 40, k0 = 0.9996)
  expect_equal(result$scale, 0.9996, tolerance = 1e-9)
})

test_that("lcc is vectorized", {
  pts <- cbind(
    lon = seq(-110, -90, by = 2),
    lat = seq(35, 45, length.out = 11)
  )
  
  result <- lcc_fwd(pts, lon0 = -100, stdlat = 40)
  expect_equal(nrow(result), 11)
  
  rev <- lcc_rev(result$x, result$y, lon0 = -100, stdlat = 40)
  expect_equal(nrow(rev), 11)
})
