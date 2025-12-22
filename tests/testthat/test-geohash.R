test_that("geohash_fwd works with single point", {
  gh <- geohash_fwd(c(147.325, -42.881))

  expect_type(gh, "character")
  expect_length(gh, 1)

  expect_equal(nchar(gh), 12)  # Default length
  expect_match(gh, "^[0-9a-z]+$")  # Base32 characters
})

test_that("geohash_fwd works with multiple points", {
  pts <- cbind(lon = c(147, -74, 0), lat = c(-42, 40.7, 51.5))
  gh <- geohash_fwd(pts)

  expect_type(gh, "character")
  expect_length(gh, 3)
  expect_true(all(nchar(gh) == 12))
})

test_that("geohash_fwd handles different lengths", {
  pt <- c(147.325, -42.881)

  for (len in 1:18) {
    gh <- geohash_fwd(pt, len = len)
    expect_equal(nchar(gh), len)
  }
})

test_that("geohash_fwd accepts vector of lengths", {
  pts <- cbind(lon = c(147, -74, 0), lat = c(-42, 40.7, 51.5))
  gh <- geohash_fwd(pts, len = c(4, 8, 12))

  expect_equal(nchar(gh), c(4, 8, 12))
})

test_that("geohash_fwd rejects invalid lengths", {
  expect_error(geohash_fwd(c(0, 0), len = 0), "between 1 and 18")
  expect_error(geohash_fwd(c(0, 0), len = 19), "between 1 and 18")
})

test_that("geohash_fwd accepts different input formats", {
  gh1 <- geohash_fwd(c(147, -42))
  gh2 <- geohash_fwd(cbind(147, -42))
  gh3 <- geohash_fwd(list(lon = 147, lat = -42))

  expect_equal(gh1, gh2)
  expect_equal(gh1, gh3)
})

test_that("geohash_rev returns correct structure", {
  gh <- "r3dp5de7n9qs"
  result <- geohash_rev(gh)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("lon", "lat", "len", "lat_resolution", "lon_resolution"))
  expect_equal(nrow(result), 1)

  expect_type(result$lon, "double")
  expect_type(result$lat, "double")
  expect_type(result$len, "integer")
  expect_type(result$lat_resolution, "double")
  expect_type(result$lon_resolution, "double")
})

test_that("geohash_rev is vectorized", {
  gh <- c("r3dp5de7n9qs", "dr5regw3pg6s", "gcpvj0duq4s0")
  result <- geohash_rev(gh)

  expect_equal(nrow(result), 3)
  expect_equal(result$len, c(12, 12, 12))
})

test_that("geohash round-trip preserves location", {
  pts <- cbind(lon = c(147.325, -74.006, 0.1275),
               lat = c(-42.881, 40.7128, 51.5074))

  gh <- geohash_fwd(pts, len = 12)
  result <- geohash_rev(gh)

  # With length 12, precision is ~19mm, so tolerance is very small
  expect_equal(result$lon, pts[, 1], tolerance = 1e-6)
  expect_equal(result$lat, pts[, 2], tolerance = 1e-6)
})

test_that("geohash truncation preserves containment", {
  pt <- c(147.325, -42.881)
  gh_full <- geohash_fwd(pt, len = 12)

  for (len in 1:11) {
    gh_truncated <- substr(gh_full, 1, len)
    result <- geohash_rev(gh_truncated)

    # Original point should be within the resolution of truncated geohash
    expect_true(abs(pt[1] - result$lon) <= result$lon_resolution)
    expect_true(abs(pt[2] - result$lat) <= result$lat_resolution)
  }
})

test_that("geohash_resolution returns correct structure", {
  result <- geohash_resolution(1:12)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("len", "lat_resolution", "lon_resolution"))
  expect_equal(nrow(result), 12)

  # Resolution should decrease as length increases
  expect_true(all(diff(result$lat_resolution) < 0))
  expect_true(all(diff(result$lon_resolution) < 0))
})

test_that("geohash_resolution rejects invalid lengths", {
  expect_error(geohash_resolution(0), "between 1 and 18")
  expect_error(geohash_resolution(19), "between 1 and 18")
})

test_that("geohash_length returns valid lengths", {
  # ~1 km precision
  len <- geohash_length(resolution = 1/111)
  expect_true(len >= 1 && len <= 18)

  # Higher precision should require longer geohash
  len_low <- geohash_length(resolution = 1)
  len_high <- geohash_length(resolution = 0.0001)
  expect_true(len_high > len_low)
})
  
test_that("geohash_length works with separate lat/lon resolution", {
  len <- geohash_length(lat_resolution = 0.01, lon_resolution = 0.01)
  expect_true(len >= 1 && len <= 18)
})

test_that("geohash_length requires correct arguments", {
  expect_error(geohash_length(), "Specify either")
  expect_error(geohash_length(lat_resolution = 0.01), "Specify either")
})

test_that("geohash handles edge cases", {
  # Equator and prime meridian
  gh <- geohash_fwd(c(0, 0))
  expect_type(gh, "character")
  result <- geohash_rev(gh)
  expect_equal(result$lon, 0, tolerance = 1e-6)
  expect_equal(result$lat, 0, tolerance = 1e-6)

  # Date line
  gh <- geohash_fwd(c(180, 0))
  expect_type(gh, "character")

  gh <- geohash_fwd(c(-180, 0))
  expect_type(gh, "character")

  # Poles
  gh_north <- geohash_fwd(c(0, 90))
  gh_south <- geohash_fwd(c(0, -90))
  expect_type(gh_north, "character")
  expect_type(gh_south, "character")
})

test_that("geohash neighbors share prefixes", {
  # Two nearby points should share geohash prefixes
  pt1 <- c(147.325, -42.881)
  pt2 <- c(147.326, -42.882)

  gh1 <- geohash_fwd(pt1, len = 12)
  gh2 <- geohash_fwd(pt2, len = 12)

  # Should share at least first few characters
  expect_equal(substr(gh1, 1, 6), substr(gh2, 1, 6))
})
