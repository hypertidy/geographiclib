test_that("azeq_fwd works with single point", {
  result <- azeq_fwd(c(-74, 40.7), lon0 = 151.2, lat0 = -33.9)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("x", "y", "azi", "scale", "lon", "lat", "lon0", "lat0"))
  expect_equal(nrow(result), 1)
  
  expect_type(result$x, "double")
  expect_type(result$y, "double")
})

test_that("azeq_fwd works with multiple points", {
  pts <- cbind(lon = c(-74, 139.7, 0), lat = c(40.7, 35.7, 51.5))
  result <- azeq_fwd(pts, lon0 = 151.2, lat0 = -33.9)
  
  expect_equal(nrow(result), 3)
})

test_that("azeq_fwd accepts different input formats", {
  result1 <- azeq_fwd(c(-74, 40.7), lon0 = 0, lat0 = 0)
  result2 <- azeq_fwd(cbind(-74, 40.7), lon0 = 0, lat0 = 0)
  result3 <- azeq_fwd(list(lon = -74, lat = 40.7), lon0 = 0, lat0 = 0)
  
  expect_equal(result1$x, result2$x)
  expect_equal(result1$x, result3$x)
})

test_that("azeq_fwd preserves distance from center", {
  # Check that sqrt(x^2 + y^2) equals geodesic distance
  pt <- c(-74, 40.7)
  center <- c(151.2, -33.9)
  
  azeq <- azeq_fwd(pt, lon0 = center[1], lat0 = center[2])
  azeq_dist <- sqrt(azeq$x^2 + azeq$y^2)
  
  geod <- geodesic_inverse(center, pt)
  
  expect_equal(azeq_dist, geod$s12, tolerance = 1)
})

test_that("azeq round-trip works", {
  pts <- cbind(lon = c(-74, 139.7, 0), lat = c(40.7, 35.7, 51.5))
  
  fwd <- azeq_fwd(pts, lon0 = 0, lat0 = 0)
  rev <- azeq_rev(fwd$x, fwd$y, lon0 = 0, lat0 = 0)
  
  expect_equal(rev$lon, pts[, 1], tolerance = 1e-9)
  expect_equal(rev$lat, pts[, 2], tolerance = 1e-9)
})

test_that("azeq center at point gives zero coordinates", {
  result <- azeq_fwd(c(151.2, -33.9), lon0 = 151.2, lat0 = -33.9)
  
  expect_equal(result$x, 0, tolerance = 1e-9)
  expect_equal(result$y, 0, tolerance = 1e-9)
})

test_that("azeq_fwd is vectorized on center", {
  # Different center for each point
  pts <- cbind(lon = c(-74, -74, -74), lat = c(40.7, 40.7, 40.7))
  centers_lon <- c(151.2, 139.7, -0.1)
  centers_lat <- c(-33.9, 35.7, 51.5)
  
  result <- azeq_fwd(pts, lon0 = centers_lon, lat0 = centers_lat)
  
  expect_equal(nrow(result), 3)
  expect_equal(result$lon0, centers_lon)
  expect_equal(result$lat0, centers_lat)
  
  # Distances should all be different (NYC from Sydney, Tokyo, London)
  distances <- sqrt(result$x^2 + result$y^2)
  expect_true(length(unique(round(distances))) == 3)
})

test_that("azeq_rev is vectorized on center", {
  # Create test data with different centers
  pts <- cbind(lon = c(-74, 139.7, 0), lat = c(40.7, 35.7, 51.5))
  centers_lon <- c(151.2, 151.2, 151.2)
  centers_lat <- c(-33.9, -33.9, -33.9)
  
  fwd <- azeq_fwd(pts, lon0 = centers_lon, lat0 = centers_lat)
  
  # Use different centers for reverse (same as forward)
  rev <- azeq_rev(fwd$x, fwd$y, lon0 = fwd$lon0, lat0 = fwd$lat0)
  
  expect_equal(rev$lon, pts[, 1], tolerance = 1e-9)
  expect_equal(rev$lat, pts[, 2], tolerance = 1e-9)
})

test_that("azeq center recycling works", {
  # Single center, multiple points
  pts <- cbind(lon = c(-74, 139.7, 0), lat = c(40.7, 35.7, 51.5))
  result <- azeq_fwd(pts, lon0 = 151.2, lat0 = -33.9)
  
  expect_equal(nrow(result), 3)
  expect_equal(result$lon0, rep(151.2, 3))
  expect_equal(result$lat0, rep(-33.9, 3))
})

test_that("azeq handles polar center", {
  # Center at South Pole
  pts <- cbind(lon = c(0, 90, 180), lat = c(-60, -60, -60))
  result <- azeq_fwd(pts, lon0 = 0, lat0 = -90)
  
  expect_equal(nrow(result), 3)
  # All points at same latitude from pole should have same distance
  distances <- sqrt(result$x^2 + result$y^2)
  expect_equal(distances[1], distances[2], tolerance = 1)
  expect_equal(distances[1], distances[3], tolerance = 1)
})

test_that("azeq handles Antarctic coordinates", {
  # McMurdo Station
  mcmurdo <- c(166.67, -77.85)
  result <- azeq_fwd(mcmurdo, lon0 = 0, lat0 = -90)
  
  expect_true(is.finite(result$x))
  expect_true(is.finite(result$y))
})
