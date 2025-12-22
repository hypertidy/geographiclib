test_that("gars_fwd works with single point", {
  code <- gars_fwd(c(-74, 40.7))
  
  expect_type(code, "character")
  expect_length(code, 1)
  expect_equal(nchar(code), 7)  # Default precision 2 = 7 characters
})

test_that("gars_fwd works with different precisions", {
  pt <- c(-74, 40.7)
  
  code0 <- gars_fwd(pt, precision = 0)
  code1 <- gars_fwd(pt, precision = 1)
  code2 <- gars_fwd(pt, precision = 2)
  
  expect_equal(nchar(code0), 5)  # 30-minute
  expect_equal(nchar(code1), 6)  # 15-minute
  expect_equal(nchar(code2), 7)  # 5-minute
  
  # Higher precision codes should start with lower precision code
  expect_equal(substr(code1, 1, 5), code0)
  expect_equal(substr(code2, 1, 6), code1)
})

test_that("gars_fwd works with multiple points", {
  pts <- cbind(lon = c(-74, 139.7, 0), lat = c(40.7, 35.7, 51.5))
  codes <- gars_fwd(pts)
  
  expect_length(codes, 3)
  expect_true(all(nchar(codes) == 7))
})

test_that("gars_fwd accepts different input formats", {
  code1 <- gars_fwd(c(-74, 40.7))
  code2 <- gars_fwd(cbind(-74, 40.7))
  code3 <- gars_fwd(list(lon = -74, lat = 40.7))
  
  expect_equal(code1, code2)
  expect_equal(code1, code3)
})

test_that("gars_fwd rejects invalid precision", {
  expect_error(gars_fwd(c(0, 0), precision = -1), "precision must be")
  expect_error(gars_fwd(c(0, 0), precision = 3), "precision must be")
})

test_that("gars_rev returns correct structure", {
  result <- gars_rev("213LR29")
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("lon", "lat", "precision", "lat_resolution", "lon_resolution"))
  expect_equal(nrow(result), 1)
  
  expect_type(result$lon, "double")
  expect_type(result$lat, "double")
  expect_type(result$precision, "integer")
})

test_that("gars_rev is vectorized", {
  codes <- c("213LR29", "498MH18", "361NS47")
  result <- gars_rev(codes)
  
  expect_equal(nrow(result), 3)
})

test_that("gars_rev detects precision from code length", {
  code0 <- "213LR"     # 5 chars = precision 0
  code1 <- "213LR2"    # 6 chars = precision 1
  code2 <- "213LR29"   # 7 chars = precision 2
  
  result0 <- gars_rev(code0)
  result1 <- gars_rev(code1)
  result2 <- gars_rev(code2)
  
  expect_equal(result0$precision, 0)
  expect_equal(result1$precision, 1)
  expect_equal(result2$precision, 2)
})

test_that("gars_rev resolution matches precision", {
  result0 <- gars_rev("213LR")
  result1 <- gars_rev("213LR2")
  result2 <- gars_rev("213LR29")
  
  # Precision 0: 30 minutes = 0.5 degrees
  expect_equal(result0$lat_resolution, 0.5)
  
  # Precision 1: 15 minutes = 0.25 degrees
  expect_equal(result1$lat_resolution, 0.25)
  
  # Precision 2: 5 minutes = 5/60 degrees
  expect_equal(result2$lat_resolution, 5/60)
})

test_that("gars round-trip preserves location within resolution", {
  pts <- cbind(lon = c(-74, 139.7, 0), lat = c(40.7, 35.7, 51.5))
  
  codes <- gars_fwd(pts, precision = 2)
  result <- gars_rev(codes)
  
  # Should be within 5-minute resolution
  expect_equal(result$lon, pts[, 1], tolerance = 5/60)
  expect_equal(result$lat, pts[, 2], tolerance = 5/60)
})

test_that("gars works at extreme latitudes", {
  # Near poles (but within GARS coverage: -90 to 90)
  high_lat <- gars_fwd(c(0, 89))
  low_lat <- gars_fwd(c(0, -89))
  
  expect_type(high_lat, "character")
  expect_type(low_lat, "character")
})

test_that("gars works at date line", {
  # Near 180 degrees
  east <- gars_fwd(c(179.9, 0))
  west <- gars_fwd(c(-179.9, 0))
  
  expect_type(east, "character")
  expect_type(west, "character")
})

test_that("gars codes have correct format", {
  code <- gars_fwd(c(0, 0), precision = 2)
  
  # GARS format: 3 digits + 2 letters + digit + digit
  expect_match(code, "^[0-9]{3}[A-Z]{2}[1-4][1-9]$")
})
