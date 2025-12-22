test_that("osgb_fwd works with single point", {
  # Central London (OSGB36 coordinates, not WGS84)
  result <- osgb_fwd(c(-0.127, 51.507))
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("easting", "northing", "convergence", "scale", "lon", "lat"))
  
  # Should be in the TQ grid square (530000, 180000 area)
  expect_true(result$easting > 500000 && result$easting < 550000)
  expect_true(result$northing > 150000 && result$northing < 200000)
})

test_that("osgb_fwd works with multiple points", {
  # OSGB36 coordinates for various UK locations
  pts <- cbind(
    lon = c(-0.127, -3.188, -1.890),
    lat = c(51.507, 55.953, 52.486)
  )
  result <- osgb_fwd(pts)
  
  expect_equal(nrow(result), 3)
})

test_that("osgb round-trip works", {
  pts <- cbind(
    lon = c(-0.127, -3.188, -1.890),
    lat = c(51.507, 55.953, 52.486)
  )
  
  fwd <- osgb_fwd(pts)
  rev <- osgb_rev(fwd$easting, fwd$northing)
  
  expect_equal(rev$lon, pts[, 1], tolerance = 1e-9)
  expect_equal(rev$lat, pts[, 2], tolerance = 1e-9)
})

test_that("osgb_gridref works", {
  gr <- osgb_gridref(c(-0.127, 51.507), precision = 2)
  
  expect_type(gr, "character")
  expect_match(gr, "^[A-Z]{2}[0-9]{4}$")  # Two letters + 4 digits for 1km
})

test_that("osgb_gridref respects precision", {
  london <- c(-0.127, 51.507)
  
  gr0 <- osgb_gridref(london, precision = 0)  # 100km
  gr1 <- osgb_gridref(london, precision = 1)  # 10km
  gr2 <- osgb_gridref(london, precision = 2)  # 1km
  gr3 <- osgb_gridref(london, precision = 3)  # 100m
  gr4 <- osgb_gridref(london, precision = 4)  # 10m
  gr5 <- osgb_gridref(london, precision = 5)  # 1m
  
  expect_equal(nchar(gr0), 2)   # Just letters
  expect_equal(nchar(gr1), 4)   # Letters + 2 digits
  expect_equal(nchar(gr2), 6)   # Letters + 4 digits
  expect_equal(nchar(gr3), 8)   # Letters + 6 digits
  expect_equal(nchar(gr4), 10)  # Letters + 8 digits
  expect_equal(nchar(gr5), 12)  # Letters + 10 digits
})

test_that("osgb_gridref_rev works", {
  result <- osgb_gridref_rev("TQ3080")
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("lon", "lat", "easting", "northing", "precision"))
  
  # Should be in London area (OSGB36)
  expect_true(result$lon > -1 && result$lon < 1)
  expect_true(result$lat > 51 && result$lat < 52)
})

test_that("osgb_gridref_rev detects precision", {
  result1 <- osgb_gridref_rev("TQ")      # 100km
  result2 <- osgb_gridref_rev("TQ30")    # 10km
  result3 <- osgb_gridref_rev("TQ3080")  # 1km
  
  expect_equal(result1$precision, 0)
  expect_equal(result2$precision, 1)
  expect_equal(result3$precision, 2)
})

test_that("osgb_gridref round-trip works", {
  london <- c(-0.127, 51.507)
  
  gr <- osgb_gridref(london, precision = 4)  # 10m precision
  rev <- osgb_gridref_rev(gr)
  
  # Should match within 10m = ~0.0001 degrees
  expect_equal(rev$lon, london[1], tolerance = 0.001)
  expect_equal(rev$lat, london[2], tolerance = 0.001)
})

test_that("osgb_gridref accepts vector of precisions", {
  pts <- cbind(
    lon = c(-0.127, -3.188, -1.890),
    lat = c(51.507, 55.953, 52.486)
  )
  
  gr <- osgb_gridref(pts, precision = c(1, 2, 3))
  
  expect_equal(nchar(gr), c(4, 6, 8))
})

test_that("osgb_gridref rejects invalid precision", {
  expect_error(osgb_gridref(c(-0.1, 51.5), precision = 6), "precision must be")
  expect_error(osgb_gridref(c(-0.1, 51.5), precision = -2), "precision must be")
})
