test_that("tm_fwd works with single point", {
  result <- tm_fwd(c(147, -42), lon0 = 147, k0 = 0.9996)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("x", "y", "convergence", "scale", "lon", "lat", "lon0"))
  expect_equal(nrow(result), 1)
  # On central meridian, x should be ~0
  expect_equal(result$x, 0, tolerance = 1)
})

test_that("tm_fwd works with multiple points", {
  pts <- cbind(lon = c(147, 148, 149), lat = c(-42, -43, -44))
  result <- tm_fwd(pts, lon0 = 147, k0 = 0.9996)
  
  expect_equal(nrow(result), 3)
})

test_that("tm_fwd accepts different input formats", {
  result1 <- tm_fwd(c(147, -42), lon0 = 147)
  result2 <- tm_fwd(cbind(147, -42), lon0 = 147)
  result3 <- tm_fwd(list(lon = 147, lat = -42), lon0 = 147)
  
  expect_equal(result1$x, result2$x)
  expect_equal(result1$x, result3$x)
})

test_that("tm_fwd is vectorized on lon0", {
  pts <- cbind(lon = c(147, 148, 149), lat = c(-42, -42, -42))
  result <- tm_fwd(pts, lon0 = c(147, 148, 149), k0 = 0.9996)
  
  expect_equal(nrow(result), 3)
  expect_equal(result$lon0, c(147, 148, 149))
  
  # Each point on its own central meridian should have x ≈ 0
  expect_equal(result$x, c(0, 0, 0), tolerance = 1)
})

test_that("tm round-trip works", {
  pts <- cbind(lon = c(147, 148, 149), lat = c(-42, -43, -44))
  
  fwd <- tm_fwd(pts, lon0 = 147, k0 = 0.9996)
  rev <- tm_rev(fwd$x, fwd$y, lon0 = 147, k0 = 0.9996)
  
  expect_equal(rev$lon, pts[, 1], tolerance = 1e-9)
  expect_equal(rev$lat, pts[, 2], tolerance = 1e-9)
})

test_that("tm scale factor affects coordinates", {
  pts <- cbind(lon = 148, lat = -42)
  
  result_utm <- tm_fwd(pts, lon0 = 147, k0 = 0.9996)
  result_one <- tm_fwd(pts, lon0 = 147, k0 = 1.0)
  
  # k0 = 1.0 should give larger coordinates
  expect_true(abs(result_one$x) > abs(result_utm$x))
  expect_true(abs(result_one$y) > abs(result_utm$y))
})

test_that("tm_exact_fwd works", {
  result <- tm_exact_fwd(c(147, -42), lon0 = 147, k0 = 0.9996)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("x", "y", "convergence", "scale", "lon", "lat", "lon0"))
  
  # On central meridian, x should be ~0
  expect_equal(result$x, 0, tolerance = 1)
})

test_that("tm_exact round-trip works", {
  pts <- cbind(lon = c(147, 148, 149), lat = c(-42, -43, -44))
  
  fwd <- tm_exact_fwd(pts, lon0 = 147, k0 = 0.9996)
  rev <- tm_exact_rev(fwd$x, fwd$y, lon0 = 147, k0 = 0.9996)
  
  expect_equal(rev$lon, pts[, 1], tolerance = 1e-9)
  expect_equal(rev$lat, pts[, 2], tolerance = 1e-9)
})

test_that("tm and tm_exact give similar results", {
  pts <- cbind(lon = c(147, 148, 149), lat = c(-42, -43, -44))
  
  result_fast <- tm_fwd(pts, lon0 = 147, k0 = 0.9996)
  result_exact <- tm_exact_fwd(pts, lon0 = 147, k0 = 0.9996)
  
  # Should be very close (within nanometers)
  expect_equal(result_fast$x, result_exact$x, tolerance = 1e-6)
  expect_equal(result_fast$y, result_exact$y, tolerance = 1e-6)
})

test_that("tm handles Antarctic coordinates", {
  # McMurdo Station
  mcmurdo <- c(166.67, -77.85)
  result <- tm_fwd(mcmurdo, lon0 = 165, k0 = 0.9996)
  
  expect_true(is.finite(result$x))
  expect_true(is.finite(result$y))
})

test_that("tm handles equatorial coordinates", {
  pts <- cbind(lon = c(0, 1, 2), lat = c(0, 0, 0))
  result <- tm_fwd(pts, lon0 = 0, k0 = 0.9996)
  
  expect_equal(nrow(result), 3)
  expect_true(all(is.finite(result$x)))
  expect_true(all(is.finite(result$y)))
})

test_that("tm central meridian gives x = 0", {
  lats <- c(-60, -30, 0, 30, 60)
  pts <- cbind(lon = 147, lat = lats)
  
  result <- tm_fwd(pts, lon0 = 147, k0 = 0.9996)
  
  expect_equal(result$x, rep(0, 5), tolerance = 1e-6)
})

test_that("tm_exact is vectorized on lon0", {
  pts <- cbind(lon = c(147, 148, 149), lat = c(-42, -42, -42))
  result <- tm_exact_fwd(pts, lon0 = c(147, 148, 149), k0 = 0.9996)
  
  expect_equal(nrow(result), 3)
  expect_equal(result$lon0, c(147, 148, 149))
  
  # Each point on its own central meridian should have x ≈ 0
  expect_equal(result$x, c(0, 0, 0), tolerance = 1)
})
