test_that("polarstereo_fwd works with single point", {
  result <- polarstereo_fwd(c(0, -85), northp = FALSE)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("x", "y", "convergence", "scale", "lon", "lat", "northp"))
  expect_equal(nrow(result), 1)
})

test_that("polarstereo_fwd works with multiple points", {
  stations <- cbind(
    lon = c(166.67, 77.97, -43.53, 0),
    lat = c(-77.85, -67.60, -60.72, -90)
  )
  result <- polarstereo_fwd(stations, northp = FALSE)
  
  expect_equal(nrow(result), 4)
})

test_that("polarstereo_fwd accepts different input formats", {
  result1 <- polarstereo_fwd(c(0, -85), northp = FALSE)
  result2 <- polarstereo_fwd(cbind(0, -85), northp = FALSE)
  result3 <- polarstereo_fwd(list(lon = 0, lat = -85), northp = FALSE)
  
  expect_equal(result1$x, result2$x)
  expect_equal(result1$x, result3$x)
})

test_that("polarstereo pole is at origin", {
  # South pole
  sp <- polarstereo_fwd(c(0, -90), northp = FALSE)
  expect_equal(sp$x, 0, tolerance = 1e-6)
  expect_equal(sp$y, 0, tolerance = 1e-6)
  
  # North pole
  np <- polarstereo_fwd(c(0, 90), northp = TRUE)
  expect_equal(np$x, 0, tolerance = 1e-6)
  expect_equal(np$y, 0, tolerance = 1e-6)
})

test_that("polarstereo round-trip works", {
  stations <- cbind(
    lon = c(166.67, 77.97, -43.53),
    lat = c(-77.85, -67.60, -60.72)
  )
  
  fwd <- polarstereo_fwd(stations, northp = FALSE)
  rev <- polarstereo_rev(fwd$x, fwd$y, northp = FALSE)
  
  expect_equal(rev$lon, stations[, 1], tolerance = 1e-9)
  expect_equal(rev$lat, stations[, 2], tolerance = 1e-9)
})

test_that("polarstereo handles north polar", {
  arctic <- cbind(lon = c(0, 90, 180, -90), lat = c(85, 85, 85, 85))
  result <- polarstereo_fwd(arctic, northp = TRUE)
  
  expect_equal(nrow(result), 4)
  expect_true(all(result$northp))
  
  # All points at same latitude should be same distance from pole
  distances <- sqrt(result$x^2 + result$y^2)
  expect_equal(distances[1], distances[2], tolerance = 1)
  expect_equal(distances[1], distances[3], tolerance = 1)
  expect_equal(distances[1], distances[4], tolerance = 1)
})

test_that("polarstereo handles south polar", {
  antarctic <- cbind(lon = c(0, 90, 180, -90), lat = c(-85, -85, -85, -85))
  result <- polarstereo_fwd(antarctic, northp = FALSE)
  
  expect_equal(nrow(result), 4)
  expect_true(all(!result$northp))
  
  # All points at same latitude should be same distance from pole
  distances <- sqrt(result$x^2 + result$y^2)
  expect_equal(distances[1], distances[2], tolerance = 1)
})

test_that("polarstereo respects scale factor", {
  pt <- c(0, -80)
  
  result_ups <- polarstereo_fwd(pt, northp = FALSE, k0 = 0.994)
  result_true <- polarstereo_fwd(pt, northp = FALSE, k0 = 1.0)
  
  # k0 = 1 should give larger coordinates than k0 = 0.994
  expect_true(sqrt(result_true$x^2 + result_true$y^2) > 
              sqrt(result_ups$x^2 + result_ups$y^2))
})

test_that("polarstereo NSIDC scale factor works", {
  # NSIDC Sea Ice Polar Stereographic
  stations <- cbind(lon = c(166.67, 77.97), lat = c(-77.85, -67.60))
  result <- polarstereo_fwd(stations, northp = FALSE, k0 = 0.97276901289)
  
  expect_equal(nrow(result), 2)
  expect_true(all(is.finite(result$x)))
})

test_that("polarstereo northp is vectorized", {
  # Mix of north and south points (unusual but supported)
  pts <- cbind(lon = c(0, 0), lat = c(85, -85))
  result <- polarstereo_fwd(pts, northp = c(TRUE, FALSE))
  
  expect_equal(nrow(result), 2)
  expect_equal(result$northp, c(TRUE, FALSE))
})

test_that("polarstereo handles McMurdo Station", {
  mcmurdo <- c(166.67, -77.85)
  result <- polarstereo_fwd(mcmurdo, northp = FALSE)
  
  expect_true(is.finite(result$x))
  expect_true(is.finite(result$y))
  
  # McMurdo should be in the Ross Sea quadrant
  # Positive x (east of prime meridian), negative y (between 90°E and 180°)
  # Actually let's just check it round-trips
  rev <- polarstereo_rev(result$x, result$y, northp = FALSE)
  expect_equal(rev$lon, mcmurdo[1], tolerance = 1e-9)
  expect_equal(rev$lat, mcmurdo[2], tolerance = 1e-9)
})

test_that("polarstereo handles Davis Station", {
  davis <- c(77.97, -68.58)
  result <- polarstereo_fwd(davis, northp = FALSE)
  
  expect_true(is.finite(result$x))
  expect_true(is.finite(result$y))
})

test_that("polarstereo handles Rothera Station", {
  rothera <- c(-68.13, -67.57)
  result <- polarstereo_fwd(rothera, northp = FALSE)
  
  expect_true(is.finite(result$x))
  expect_true(is.finite(result$y))
})

test_that("polarstereo equidistant points from pole have same distance", {
  # Points at 80°S at different longitudes
  lats <- rep(-80, 8)
  lons <- seq(0, 315, by = 45)
  pts <- cbind(lon = lons, lat = lats)
  
  result <- polarstereo_fwd(pts, northp = FALSE)
  distances <- sqrt(result$x^2 + result$y^2)
  
  # All distances should be equal
  expect_equal(max(distances) - min(distances), 0, tolerance = 1)
})
