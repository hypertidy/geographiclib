test_that("mgrs_fwd works with single point", {
  code <- mgrs_fwd(cbind(147.325, -42.881))
  expect_type(code, "character")
  expect_length(code, 1)
  expect_match(code, "^[0-9]{2}[A-Z]{3}[0-9]+$")
})

test_that("mgrs_fwd works with multiple points", {
  x <- cbind(lon = c(147, 148, -100), lat = c(-42, -42, -42))
  codes <- mgrs_fwd(x)
  expect_type(codes, "character")
  expect_length(codes, 3)
  expect_true(all(grepl("^[0-9A-Z]+$", codes)))
})

test_that("mgrs_fwd handles different precision levels", {
  x <- cbind(147.325, -42.881)

  # Test each precision level
  for (prec in 0:5) {
    code <- mgrs_fwd(x, precision = prec)
    expect_type(code, "character")

    # MGRS string length varies by precision
    # Format: 2-digit zone + 3 letters + (2*precision) digits
    expected_length <- 5 + (2 * prec)
    expect_equal(nchar(code), expected_length)
  }
})

test_that("mgrs_fwd accepts vector of precisions", {
  x <- cbind(lon = c(147, 148, -100, 0, 10),
             lat = c(-42, -42, -42, 0, 10))
  codes <- mgrs_fwd(x, precision = c(0, 1, 2, 3, 5))

  expect_length(codes, 5)
  expect_equal(nchar(codes[1]), 5)   # precision 0
  expect_equal(nchar(codes[2]), 7)   # precision 1
  expect_equal(nchar(codes[3]), 9)   # precision 2
  expect_equal(nchar(codes[4]), 11)  # precision 3
  expect_equal(nchar(codes[5]), 15)  # precision 5
})

test_that("mgrs_fwd rejects invalid precision", {
  x <- cbind(147, -42)
  expect_error(mgrs_fwd(x, precision = 6), "precision values out of bounds")
  expect_error(mgrs_fwd(x, precision = -1), "precision values out of bounds")
})

test_that("mgrs_fwd accepts different input formats", {
  # Matrix
  code1 <- mgrs_fwd(cbind(147, -42))

  # Vector
  code2 <- mgrs_fwd(c(147, -42))

  # List
  code3 <- mgrs_fwd(list(lon = 147, lat = -42))

  expect_equal(code1, code2)
  expect_equal(code1, code3)
})

test_that("mgrs_rev returns data frame with correct structure", {
  code <- "55GEP0000050223"
  result <- mgrs_rev(code)

  expect_s3_class(result, "data.frame")
  expect_named(result, c('lon', 'lat', 'x', 'y', 'zone', 'northp', 'precision', 'convergence', 'scale', 'grid_zone', 'square_100km', 'crs'))
  expect_equal(nrow(result), 1)

  # Check column types
  expect_type(result$lon, "double")
  expect_type(result$lat, "double")
  expect_type(result$x, "double")
  expect_type(result$y, "double")
  expect_type(result$zone, "integer")
  expect_type(result$northp, "logical")
  expect_type(result$crs, "character")
})

test_that("mgrs_rev is vectorized", {
  codes <- c("55GEP0000050223", "55GEP8281849740", "14GMU1718149740")
  result <- mgrs_rev(codes)

  expect_equal(nrow(result), 3)
  expect_equal(result$zone, c(55, 55, 14))
  expect_equal(result$northp, c(FALSE, FALSE, FALSE))
})

test_that("mgrs_rev CRS codes are correct for standard UTM zones", {
  # Test northern and southern hemisphere
  codes <- c("55GEP0000050223", "33TWM0000050223")  # South and North examples
  result <- mgrs_rev(codes)

  # Southern hemisphere (zone 55)
  expect_match(result$crs[1], "^EPSG:327[0-9]{2}$")
  expect_equal(result$crs[1], "EPSG:32755")

  # Northern hemisphere (zone 33)
  expect_match(result$crs[2], "^EPSG:326[0-9]{2}$")
})

test_that("mgrs_rev handles polar regions correctly", {
  # North pole region
  north_codes <- mgrs_fwd(cbind(c(147, 148, -100), 88))
  result_north <- mgrs_rev(north_codes)

  expect_equal(result_north$zone, c(0, 0, 0))
  expect_equal(result_north$northp, c(TRUE, TRUE, TRUE))
  expect_equal(result_north$crs, c("EPSG:32661", "EPSG:32661", "EPSG:32661"))

  # South pole region
  south_codes <- mgrs_fwd(cbind(c(147, 148, -100), -88))
  result_south <- mgrs_rev(south_codes)

  expect_equal(result_south$zone, c(0, 0, 0))
  expect_equal(result_south$northp, c(FALSE, FALSE, FALSE))
  expect_equal(result_south$crs, c("EPSG:32761", "EPSG:32761", "EPSG:32761"))
})

test_that("mgrs round-trip conversion preserves location", {
  # Original coordinates
  x <- cbind(lon = c(147, 148, -100, 0, 45),
             lat = c(-42, -42, -42, 0, 60))

  # Forward then reverse
  codes <- mgrs_fwd(x, precision = 5)
  result <- mgrs_rev(codes)

  # Check coordinates match (within precision tolerance ~1m)
  expect_equal(result$lon, x[, 1], tolerance = 0.00001)
  expect_equal(result$lat, x[, 2], tolerance = 0.00001)
})

test_that("mgrs precision affects round-trip accuracy", {
  original <- cbind(147.325, -42.881)

  # Low precision should give less accurate results
  code_low <- mgrs_fwd(original, precision = 1)  # 10 km precision
  result_low <- mgrs_rev(code_low)

  # High precision should be more accurate
  code_high <- mgrs_fwd(original, precision = 5)  # 1 m precision
  result_high <- mgrs_rev(code_high)

  # Calculate differences
  diff_low <- sqrt((result_low$lon - original[1])^2 + (result_low$lat - original[2])^2)
  diff_high <- sqrt((result_high$lon - original[1])^2 + (result_high$lat - original[2])^2)

  expect_true(diff_high < diff_low)
  expect_true(diff_high < 0.0001)  # High precision very accurate
})

test_that("mgrs works across different UTM zones", {
  # Sample points from various zones
  x <- cbind(lon = c(-120, -60, 0, 60, 120, 180),
             lat = c(45, 45, 45, 45, 45, 45))

  codes <- mgrs_fwd(x)
  result <- mgrs_rev(codes)

  # Should have different zones
  expect_true(length(unique(result$zone)) > 1)

  # All should be northern hemisphere
  expect_true(all(result$northp))

  # All CRS codes should be EPSG:326XX
  expect_true(all(grepl("^EPSG:326[0-9]{2}$", result$crs)))
})

test_that("mgrs handles equator crossing", {
  # Points just north and south of equator
  x <- cbind(lon = c(30, 30), lat = c(1, -1))

  codes <- mgrs_fwd(x)
  result <- mgrs_rev(codes)

  # Should be same zone but different hemispheres
  expect_equal(result$zone[1], result$zone[2])
  expect_equal(result$northp, c(TRUE, FALSE))

  # Different CRS codes (326 vs 327)
  expect_match(result$crs[1], "^EPSG:326")
  expect_match(result$crs[2], "^EPSG:327")
})

test_that("mgrs_rev includes all expected fields", {
  code <- "55GEN2654152348"
  result <- mgrs_rev(code)

  expect_named(result, c("lon", "lat", "x", "y", "zone", "northp",
                         "precision", "convergence", "scale",
                         "grid_zone", "square_100km", "crs"))

  # Check new field types
  expect_type(result$convergence, "double")
  expect_type(result$scale, "double")
  expect_type(result$grid_zone, "character")
  expect_type(result$square_100km, "character")

  # Check values make sense
  expect_true(abs(result$convergence) < 180)  # Convergence in degrees
  expect_true(result$scale > 0.9 && result$scale < 1.1)  # Scale near 1.0
  expect_match(result$grid_zone, "^[0-9]{2}[A-Z]$")  # e.g., "55G"
  expect_match(result$square_100km, "^[A-Z]{2}$")  # e.g., "EN"
})
