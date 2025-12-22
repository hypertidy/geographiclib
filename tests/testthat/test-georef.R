test_that("georef_fwd works with single point", {
  code <- georef_fwd(c(-0.1, 51.5))
  
  expect_type(code, "character")
  expect_length(code, 1)
})

test_that("georef_fwd works with different precisions", {
  pt <- c(-0.1, 51.5)
  
  code_neg1 <- georef_fwd(pt, precision = -1)
  code_0 <- georef_fwd(pt, precision = 0)
  # Note: precision 1 is disallowed by GeographicLib, becomes 2
  code_2 <- georef_fwd(pt, precision = 2)
  code_3 <- georef_fwd(pt, precision = 3)
  
  expect_equal(nchar(code_neg1), 2)   # 15-degree tiles
  expect_equal(nchar(code_0), 4)      # 1-degree
  expect_equal(nchar(code_2), 8)      # 0.01-minute
  expect_equal(nchar(code_3), 10)     # 0.001-minute
})

test_that("georef_fwd higher precision extends lower precision", {
  pt <- c(-0.1, 51.5)
  
  code_0 <- georef_fwd(pt, precision = 0)
  code_2 <- georef_fwd(pt, precision = 2)
  
  # Higher precision codes should start with lower precision prefix
  expect_equal(substr(code_2, 1, 4), code_0)
})

test_that("georef_fwd works with multiple points", {
  pts <- cbind(lon = c(-74, 139.7, 0), lat = c(40.7, 35.7, 51.5))
  codes <- georef_fwd(pts)
  
  expect_length(codes, 3)
})

test_that("georef_fwd accepts different input formats", {
  code1 <- georef_fwd(c(-74, 40.7))
  code2 <- georef_fwd(cbind(-74, 40.7))
  code3 <- georef_fwd(list(lon = -74, lat = 40.7))
  
  expect_equal(code1, code2)
  expect_equal(code1, code3)
})

test_that("georef_fwd rejects invalid precision", {
  expect_error(georef_fwd(c(0, 0), precision = -2), "precision must be")
  expect_error(georef_fwd(c(0, 0), precision = 12), "precision must be")
})

test_that("georef_rev returns correct structure", {
  result <- georef_rev("GJPJ3217")
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("lon", "lat", "precision", "lat_resolution", "lon_resolution"))
  expect_equal(nrow(result), 1)
  
  expect_type(result$lon, "double")
  expect_type(result$lat, "double")
  expect_type(result$precision, "integer")
})

test_that("georef_rev is vectorized", {
  codes <- c("GJPJ3217", "SKNA2342", "GJPJ")
  result <- georef_rev(codes)
  
  expect_equal(nrow(result), 3)
})

test_that("georef_rev detects precision from code", {
  code_2char <- georef_fwd(c(0, 45), precision = -1)
  code_4char <- georef_fwd(c(0, 45), precision = 0)
  code_8char <- georef_fwd(c(0, 45), precision = 2)
  
  result_2 <- georef_rev(code_2char)
  result_4 <- georef_rev(code_4char)
  result_8 <- georef_rev(code_8char)
  
  expect_equal(result_2$precision, -1)
  expect_equal(result_4$precision, 0)
  expect_equal(result_8$precision, 2)
})

test_that("georef round-trip preserves location within resolution", {
  pts <- cbind(lon = c(-74, 139.7, 0), lat = c(40.7, 35.7, 51.5))
  
  codes <- georef_fwd(pts, precision = 2)
  result <- georef_rev(codes)
  
  # Precision 2 = 0.01 minute = 0.01/60 degrees ~ 0.00017
  expect_equal(result$lon, pts[, 1], tolerance = 0.01)
  expect_equal(result$lat, pts[, 2], tolerance = 0.01)
})

test_that("georef works at extreme latitudes", {
  high_lat <- georef_fwd(c(0, 89))
  low_lat <- georef_fwd(c(0, -89))
  
  expect_type(high_lat, "character")
  expect_type(low_lat, "character")
})

test_that("georef works at date line", {
  east <- georef_fwd(c(179.9, 0))
  west <- georef_fwd(c(-179.9, 0))
  
  expect_type(east, "character")
  expect_type(west, "character")
})

test_that("georef codes have correct format", {
  # Precision 0: 4 letters
  code0 <- georef_fwd(c(0, 45), precision = 0)
  expect_match(code0, "^[A-Z]{4}$")
  
  # Precision 2: 4 letters + 4 digits
  code2 <- georef_fwd(c(0, 45), precision = 2)
  expect_match(code2, "^[A-Z]{4}[0-9]{4}$")
  
  # Precision 3: 4 letters + 6 digits
  code3 <- georef_fwd(c(0, 45), precision = 3)
  expect_match(code3, "^[A-Z]{4}[0-9]{6}$")
})

test_that("georef_fwd accepts vector of precisions", {
  pts <- cbind(lon = c(-74, 139.7, 0), lat = c(40.7, 35.7, 51.5))
  codes <- georef_fwd(pts, precision = c(0, 2, 3))
  
  expect_equal(nchar(codes), c(4, 8, 10))
})
