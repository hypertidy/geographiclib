test_that("utmups_fwd works with single point", {
  result <- utmups_fwd(c(147.325, -42.881))
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("x", "y", "zone", "northp", "convergence", "scale", "lon", "lat", "crs"))
  expect_equal(nrow(result), 1)
  
  # Check column types
  expect_type(result$x, "double")
  expect_type(result$y, "double")
  expect_type(result$zone, "integer")
  expect_type(result$northp, "logical")
  expect_type(result$convergence, "double")
  expect_type(result$scale, "double")
  expect_type(result$lon, "double")
  expect_type(result$lat, "double")
  expect_type(result$crs, "character")
  
  # Check reasonable values
  expect_true(result$zone >= 0 && result$zone <= 60)
  expect_equal(result$northp, FALSE)  # Southern hemisphere
  expect_true(abs(result$convergence) < 180)
  expect_true(result$scale > 0.9 && result$scale < 1.1)
})

test_that("utmups_fwd works with multiple points", {
  pts <- cbind(lon = c(147, 148, -100), lat = c(-42, -42, -42))
  result <- utmups_fwd(pts)
  
  expect_equal(nrow(result), 3)
  expect_true(all(result$northp == FALSE))
  expect_true(length(unique(result$zone)) > 1)  # Different zones
})

test_that("utmups_fwd accepts different input formats", {
  # Matrix
  result1 <- utmups_fwd(cbind(147, -42))
  
  # Vector
  result2 <- utmups_fwd(c(147, -42))
  
  # List
  result3 <- utmups_fwd(list(lon = 147, lat = -42))
  
  expect_equal(result1$x, result2$x)
  expect_equal(result1$x, result3$x)
  expect_equal(result1$y, result2$y)
  expect_equal(result1$y, result3$y)
})

test_that("utmups_fwd CRS codes are correct", {
  # Southern hemisphere
  result_south <- utmups_fwd(c(147, -42))
  expect_match(result_south$crs, "^EPSG:327[0-9]{2}$")
  expect_equal(result_south$crs, "EPSG:32755")
  
  # Northern hemisphere
  result_north <- utmups_fwd(c(147, 42))
  expect_match(result_north$crs, "^EPSG:326[0-9]{2}$")
  expect_equal(result_north$crs, "EPSG:32655")
})

test_that("utmups_fwd handles polar regions", {
  # North pole
  result_north <- utmups_fwd(cbind(c(147, 148, -100), 88))
  expect_equal(result_north$zone, c(0, 0, 0))
  expect_equal(result_north$northp, c(TRUE, TRUE, TRUE))
  expect_equal(result_north$crs, c("EPSG:32661", "EPSG:32661", "EPSG:32661"))
  
  # South pole
  result_south <- utmups_fwd(cbind(c(147, 148, -100), -88))
  expect_equal(result_south$zone, c(0, 0, 0))
  expect_equal(result_south$northp, c(FALSE, FALSE, FALSE))
  expect_equal(result_south$crs, c("EPSG:32761", "EPSG:32761", "EPSG:32761"))
})

test_that("utmups_rev returns data frame with correct structure", {
  fwd <- utmups_fwd(c(147, -42))
  result <- utmups_rev(fwd$x, fwd$y, fwd$zone, fwd$northp)
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("lon", "lat", "x", "y", "zone", "northp", "convergence", "scale", "crs"))
  expect_equal(nrow(result), 1)
  
  # Check column types
  expect_type(result$lon, "double")
  expect_type(result$lat, "double")
  expect_type(result$x, "double")
  expect_type(result$y, "double")
  expect_type(result$zone, "integer")
  expect_type(result$northp, "logical")
  expect_type(result$convergence, "double")
  expect_type(result$scale, "double")
  expect_type(result$crs, "character")
})

test_that("utmups_rev is vectorized", {
  pts <- cbind(c(147, 148, -100), c(-42, -43, -42))
  fwd <- utmups_fwd(pts)
  result <- utmups_rev(fwd$x, fwd$y, fwd$zone, fwd$northp)
  
  expect_equal(nrow(result), 3)
  expect_equal(result$zone, fwd$zone)
  expect_equal(result$northp, fwd$northp)
})

test_that("utmups_rev handles recycling", {
  # Single zone/northp for multiple coordinates
  result <- utmups_rev(c(500000, 600000), c(5000000, 5100000), 55, FALSE)
  expect_equal(nrow(result), 2)
  expect_equal(result$zone, c(55, 55))
  expect_equal(result$northp, c(FALSE, FALSE))
})

test_that("utmups round-trip conversion preserves location", {
  pts <- cbind(lon = c(147, 148, -100, 0, 45),
               lat = c(-42, -42, -42, 0, 60))
  
  fwd <- utmups_fwd(pts)
  rev <- utmups_rev(fwd$x, fwd$y, fwd$zone, fwd$northp)
  
  # Check coordinates match (within numerical precision)
  expect_equal(rev$lon, pts[, 1], tolerance = 1e-9)
  expect_equal(rev$lat, pts[, 2], tolerance = 1e-9)
})

test_that("utmups works across different zones", {
  # Sample points from various zones
  pts <- cbind(lon = c(-120, -60, 0, 60, 120, 180),
               lat = c(45, 45, 45, 45, 45, 45))
  
  result <- utmups_fwd(pts)
  
  # Should have different zones
  expect_true(length(unique(result$zone)) > 1)
  
  # All should be northern hemisphere
  expect_true(all(result$northp))
  
  # All CRS codes should be EPSG:326XX
  expect_true(all(grepl("^EPSG:326[0-9]{2}$", result$crs)))
})

test_that("utmups handles equator crossing", {
  pts <- cbind(lon = c(30, 30), lat = c(1, -1))
  result <- utmups_fwd(pts)
  
  # Should be same zone but different hemispheres
  expect_equal(result$zone[1], result$zone[2])
  expect_equal(result$northp, c(TRUE, FALSE))
  
  # Different CRS codes (326 vs 327)
  expect_match(result$crs[1], "^EPSG:326")
  expect_match(result$crs[2], "^EPSG:327")
})

test_that("utmups convergence and scale are reasonable", {
  pts <- cbind(lon = c(0, 45, 90, 135, 180),
               lat = c(0, 30, 60, -30, -60))
  result <- utmups_fwd(pts)
  
  # Convergence should be between -180 and 180
  expect_true(all(abs(result$convergence) <= 180))
  
  # Scale should be close to 1.0 (within 10%)
  expect_true(all(result$scale > 0.9 & result$scale < 1.1))
})

test_that("utmups polar regions use correct projections", {
  # High latitude points
  north <- utmups_fwd(cbind(c(0, 45, 90), 85))
  south <- utmups_fwd(cbind(c(0, 45, 90), -85))
  
  # Should all use UPS
  expect_equal(north$zone, c(0, 0, 0))
  expect_equal(south$zone, c(0, 0, 0))
  
  # Different EPSG codes for north/south
  expect_true(all(north$crs == "EPSG:32661"))
  expect_true(all(south$crs == "EPSG:32761"))
})

test_that("utmups handles zone boundaries", {
  # Points near zone boundaries (6° zones)
  pts <- cbind(lon = c(-3.1, -2.9, 2.9, 3.1),  # Around 0° (zones 30/31)
               lat = c(45, 45, 45, 45))
  result <- utmups_fwd(pts)
  
  # Should have zone transitions
  expect_true(result$zone[1] != result$zone[4])
})