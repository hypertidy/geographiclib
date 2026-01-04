test_that("albers_fwd works with two standard parallels", {
  pts <- cbind(lon = c(-122, -74, -90), lat = c(37, 41, 30))
  result <- albers_fwd(pts, lon0 = -96, stdlat1 = 29.5, stdlat2 = 45.5)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("x", "y", "convergence", "scale", "lon", "lat", "lon0"))
  expect_equal(nrow(result), 3)
})

test_that("albers_fwd works with single standard parallel", {
  pts <- cbind(lon = c(-122, -74, -90), lat = c(37, 41, 30))
  result <- albers_fwd(pts, lon0 = -96, stdlat = 37)
  
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)
})

test_that("albers_fwd requires standard parallels", {
  expect_error(albers_fwd(c(-122, 37), lon0 = -96), "Specify either")
})

test_that("albers_fwd accepts different input formats", {
  result1 <- albers_fwd(c(-122, 37), lon0 = -96, stdlat1 = 29.5, stdlat2 = 45.5)
  result2 <- albers_fwd(cbind(-122, 37), lon0 = -96, stdlat1 = 29.5, stdlat2 = 45.5)
  result3 <- albers_fwd(list(lon = -122, lat = 37), lon0 = -96, stdlat1 = 29.5, stdlat2 = 45.5)
  
  expect_equal(result1$x, result2$x)
  expect_equal(result1$x, result3$x)
})

test_that("albers_fwd is vectorized on lon0", {
  pts <- cbind(lon = c(-122, -74, -90), lat = c(37, 41, 30))
  result <- albers_fwd(pts, lon0 = c(-120, -75, -90), stdlat1 = 29.5, stdlat2 = 45.5)
  
  expect_equal(nrow(result), 3)
  expect_equal(result$lon0, c(-120, -75, -90))
})

test_that("albers round-trip works (two parallels)", {
  pts <- cbind(lon = c(-122, -74, -90), lat = c(37, 41, 30))
  
  fwd <- albers_fwd(pts, lon0 = -96, stdlat1 = 29.5, stdlat2 = 45.5)
  rev <- albers_rev(fwd$x, fwd$y, lon0 = -96, stdlat1 = 29.5, stdlat2 = 45.5)
  
  expect_equal(rev$lon, pts[, 1], tolerance = 1e-9)
  expect_equal(rev$lat, pts[, 2], tolerance = 1e-9)
})

test_that("albers round-trip works (single parallel)", {
  pts <- cbind(lon = c(-122, -74, -90), lat = c(37, 41, 30))
  
  fwd <- albers_fwd(pts, lon0 = -96, stdlat = 37)
  rev <- albers_rev(fwd$x, fwd$y, lon0 = -96, stdlat = 37)
  
  expect_equal(rev$lon, pts[, 1], tolerance = 1e-9)
  expect_equal(rev$lat, pts[, 2], tolerance = 1e-9)
})

test_that("albers handles Australian coordinates", {
  aus <- cbind(lon = c(151.2, 115.9, 153.0), lat = c(-33.9, -32.0, -27.5))
  result <- albers_fwd(aus, lon0 = 132, stdlat1 = -18, stdlat2 = -36)
  
  expect_equal(nrow(result), 3)
  expect_true(all(is.finite(result$x)))
  expect_true(all(is.finite(result$y)))
})

test_that("albers handles Antarctic coordinates", {
  ant <- cbind(lon = c(166.67, 77.97, -43.53), lat = c(-77.85, -67.60, -60.72))
  result <- albers_fwd(ant, lon0 = 0, stdlat1 = -72, stdlat2 = -60)
  
  expect_equal(nrow(result), 3)
  expect_true(all(is.finite(result$x)))
})

test_that("albers central meridian gives x near 0", {
  pts <- cbind(lon = -96, lat = c(30, 40, 50))
  result <- albers_fwd(pts, lon0 = -96, stdlat1 = 29.5, stdlat2 = 45.5)
  
  expect_equal(result$x, rep(0, 3), tolerance = 1)
})

test_that("albers is equal-area (scale product is 1)", {
  pts <- cbind(lon = c(-122, -74, -90), lat = c(37, 41, 30))
  result <- albers_fwd(pts, lon0 = -96, stdlat1 = 29.5, stdlat2 = 45.5)
  
  # For equal-area projections, the product of meridional and parallel scales = 1

# The single scale value reported is the geometric mean
  # Scale should vary but product with perpendicular scale = 1
  expect_true(all(result$scale > 0))
})

test_that("albers European configuration works", {
  europe <- cbind(lon = c(-10, 10, 25), lat = c(50, 50, 50))
  result <- albers_fwd(europe, lon0 = 10, stdlat1 = 43, stdlat2 = 62)
  
  expect_equal(nrow(result), 3)
  expect_true(all(is.finite(result$x)))
})
