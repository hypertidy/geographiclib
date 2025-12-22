test_that("ellipsoid_params returns WGS84 values", {
  params <- ellipsoid_params()
  
  expect_type(params, "list")
  expect_named(params, c("a", "f", "b", "e2", "ep2", "n", "area", "volume"))
  
  # WGS84 equatorial radius
  expect_equal(params$a, 6378137, tolerance = 1)
  
  # WGS84 flattening
  expect_equal(params$f, 1/298.257223563, tolerance = 1e-12)
  
  # Semi-minor axis should be less than semi-major
  expect_true(params$b < params$a)
  
  # Area and volume should be positive
  expect_true(params$area > 0)
  expect_true(params$volume > 0)
})

test_that("ellipsoid_circle works correctly", {
  result <- ellipsoid_circle(c(0, 45, 90))
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("lat", "radius", "quarter_meridian", "meridian_distance"))
  expect_equal(nrow(result), 3)
  
  # Radius at equator should equal semi-major axis
  expect_equal(result$radius[1], 6378137, tolerance = 1)
  
  # Radius at pole should be 0
  expect_equal(result$radius[3], 0, tolerance = 1)
  
  # Meridian distance should increase with latitude
  expect_true(all(diff(result$meridian_distance) > 0))
  
  # At pole, meridian_distance should equal quarter_meridian
  expect_equal(result$meridian_distance[3], result$quarter_meridian[3], tolerance = 1)
})

test_that("ellipsoid_latitudes returns all types", {
  result <- ellipsoid_latitudes(c(0, 45, 90))
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("lat", "parametric", "geocentric", "rectifying",
                         "authalic", "conformal", "isometric"))
  expect_equal(nrow(result), 3)
  
  # At equator, all latitudes should be 0
  expect_equal(result$parametric[1], 0, tolerance = 1e-9)
  expect_equal(result$geocentric[1], 0, tolerance = 1e-9)
  expect_equal(result$rectifying[1], 0, tolerance = 1e-9)
  
  # At pole, most latitudes should be 90
  expect_equal(result$parametric[3], 90, tolerance = 1e-9)
  expect_equal(result$geocentric[3], 90, tolerance = 1e-9)
  expect_equal(result$rectifying[3], 90, tolerance = 1e-9)
})

test_that("ellipsoid_latitudes auxiliary latitudes differ from geographic", {
  result <- ellipsoid_latitudes(45)
  
  # At mid-latitudes, auxiliary latitudes should differ slightly from geographic
  # Due to Earth's flattening
  expect_false(result$parametric == 45)
  expect_false(result$geocentric == 45)
  
  # Geocentric latitude should be less than geographic (Earth is flattened)
  expect_true(result$geocentric < 45)
})

test_that("ellipsoid_latitudes_inv inverts correctly", {
  # Forward
  fwd <- ellipsoid_latitudes(c(0, 30, 60, 90))
  
  # Inverse parametric
  inv_param <- ellipsoid_latitudes_inv(fwd$parametric, "parametric")
  expect_equal(inv_param$geographic, c(0, 30, 60, 90), tolerance = 1e-9)
  
  # Inverse geocentric
  inv_geo <- ellipsoid_latitudes_inv(fwd$geocentric, "geocentric")
  expect_equal(inv_geo$geographic, c(0, 30, 60, 90), tolerance = 1e-9)
  
  # Inverse rectifying
  inv_rect <- ellipsoid_latitudes_inv(fwd$rectifying, "rectifying")
  expect_equal(inv_rect$geographic, c(0, 30, 60, 90), tolerance = 1e-9)
})

test_that("ellipsoid_latitudes_inv rejects invalid types", {
  expect_error(ellipsoid_latitudes_inv(45, "invalid"), "type must be one of")
})

test_that("ellipsoid_curvature returns correct structure", {
  result <- ellipsoid_curvature(c(0, 45, 90))
  
  expect_s3_class(result, "data.frame")
  expect_named(result, c("lat", "meridional", "transverse"))
  expect_equal(nrow(result), 3)
  
  # All radii should be positive
  expect_true(all(result$meridional > 0))
  expect_true(all(result$transverse > 0))
})

test_that("ellipsoid_curvature varies with latitude", {
  result <- ellipsoid_curvature(c(0, 45, 90))
  
  # Meridional radius increases from equator to pole
  expect_true(result$meridional[3] > result$meridional[1])
  
  # At equator, transverse radius equals semi-major axis
  expect_equal(result$transverse[1], 6378137, tolerance = 1)
  
  # At pole, meridional and transverse should be equal
  expect_equal(result$meridional[3], result$transverse[3], tolerance = 1)
})

test_that("ellipsoid functions are vectorized", {
  lats <- seq(0, 90, by = 10)
  
  circle <- ellipsoid_circle(lats)
  expect_equal(nrow(circle), length(lats))
  
  latitudes <- ellipsoid_latitudes(lats)
  expect_equal(nrow(latitudes), length(lats))
  
  curvature <- ellipsoid_curvature(lats)
  expect_equal(nrow(curvature), length(lats))
})
