test_that("geodesic_intersect finds intersection of two geodesics", {
  # Two geodesics crossing near origin
  # Geodesic X: starts at (0, 0), azimuth 45 degrees (NE)
  # Geodesic Y: starts at (1, 0), azimuth 315 degrees (NW)
  result <- geodesic_intersect(c(0, 0), 45, c(1, 0), 315)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("x", "y", "coincidence", "lat", "lon"))
  expect_equal(nrow(result), 1)

  # Both displacements should be positive (intersection ahead on both geodesics)
  expect_gt(result$x, 0)
  expect_gt(result$y, 0)

  # Coincidence should be 0 (normal intersection)
  expect_equal(result$coincidence, 0)

  # Intersection should be roughly between the two starting points
  expect_gt(result$lon, 0)
  expect_lt(result$lon, 1)
  expect_gt(result$lat, 0)
})

test_that("geodesic_intersect handles parallel geodesics",
 {
  # Two parallel geodesics (same azimuth)
  result <- geodesic_intersect(c(0, 0), 90, c(0, 1), 90)

  # For parallel non-coincident geodesics, the result depends on 
  # how GeographicLib handles this case
  expect_s3_class(result, "data.frame")
})

test_that("geodesic_intersect is vectorized", {
  # Multiple intersection problems
  result <- geodesic_intersect(
    cbind(c(0, 0, 0), c(0, 0, 0)),
    c(30, 45, 60),
    cbind(c(1, 1, 1), c(0, 0, 0)),
    c(330, 315, 300)
  )

  expect_equal(nrow(result), 3)
  expect_true(all(result$x > 0))
  expect_true(all(result$y > 0))
})

test_that("geodesic_intersect handles NA inputs", {
  result <- geodesic_intersect(c(NA, 0), 45, c(1, 0), 315)

  expect_true(is.na(result$x))
  expect_true(is.na(result$y))
  expect_true(is.na(result$lat))
  expect_true(is.na(result$lon))
})

test_that("geodesic_intersect_segment finds segment intersection", {
  # Two crossing segments
  # Segment X: from (0, -1) to (0, 1) - roughly N-S line at lon 0
  # Segment Y: from (-1, 0) to (1, 0) - roughly W-E line at lat 0
  result <- geodesic_intersect_segment(
    c(0, -1), c(0, 1),
    c(-1, 0), c(1, 0)
  )

  expect_s3_class(result, "data.frame")
  expect_named(result, c("x", "y", "segmode", "coincidence", "lat", "lon"))

  # segmode = 0 means intersection within both segments
  expect_equal(result$segmode, 0)

  # Intersection should be near origin
  expect_lt(abs(result$lat), 1)
  expect_lt(abs(result$lon), 1)
})

test_that("geodesic_intersect_segment detects non-intersecting segments", {
  # Two segments that don't intersect
  # Segment X: from (0, 0) to (0, 1)
  # Segment Y: from (10, 0) to (10, 1)
  result <- geodesic_intersect_segment(
    c(0, 0), c(0, 1),
    c(10, 0), c(10, 1)
  )

  # segmode != 0 means intersection outside segments
  expect_false(result$segmode == 0)
})

test_that("geodesic_intersect_segment is vectorized", {
  # Multiple segment intersection problems
  result <- geodesic_intersect_segment(
    cbind(c(0, 0), c(-1, -1)),
    cbind(c(0, 0), c(1, 1)),
    cbind(c(-1, -1), c(0, 0)),
    cbind(c(1, 1), c(0, 0))
  )

  expect_equal(nrow(result), 2)
})

test_that("geodesic_intersect_next finds next intersection", {
  # Two geodesics crossing at origin
  result <- geodesic_intersect_next(c(0, 0), 45, 315)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("x", "y", "coincidence", "lat", "lon"))

  # The "next" intersection should be some distance away
  # (not at the starting point)
  expect_true(abs(result$x) > 1000 || abs(result$y) > 1000)
})

test_that("geodesic_intersect_next is vectorized", {
  result <- geodesic_intersect_next(
    cbind(c(0, 0), c(0, 0)),
    c(45, 30),
    c(315, 330)
  )

  expect_equal(nrow(result), 2)
})

test_that("geodesic_intersect_all finds multiple intersections", {
  # Two geodesics with multiple intersections within search radius
  result <- geodesic_intersect_all(c(0, 0), 45, c(1, 0), 315, maxdist = 1e7)

  expect_s3_class(result, "data.frame")
  # Should find at least the closest intersection
  expect_gte(nrow(result), 1)
})

test_that("geodesic_intersect_all returns list for multiple inputs", {
  result <- geodesic_intersect_all(
    cbind(c(0, 0), c(0, 0)),
    c(45, 30),
    cbind(c(1, 1), c(0, 0)),
    c(315, 330),
    maxdist = 1e6
  )

  expect_type(result, "list")
  expect_length(result, 2)
  expect_s3_class(result[[1]], "data.frame")
  expect_s3_class(result[[2]], "data.frame")
})

test_that("geodesic_intersect_all respects maxdist", {
  # Small search radius
  result_small <- geodesic_intersect_all(c(0, 0), 45, c(1, 0), 315, maxdist = 1e5)
  # Large search radius
  result_large <- geodesic_intersect_all(c(0, 0), 45, c(1, 0), 315, maxdist = 1e8)

  # Larger radius should find at least as many intersections
  expect_gte(nrow(result_large), nrow(result_small))
})

test_that("geodesic_intersect accepts different input formats", {
  # Vector input
  r1 <- geodesic_intersect(c(0, 0), 45, c(1, 0), 315)

  # Matrix input
  r2 <- geodesic_intersect(matrix(c(0, 0), ncol = 2), 45,
                            matrix(c(1, 0), ncol = 2), 315)

  # List input
  r3 <- geodesic_intersect(list(lon = 0, lat = 0), 45,
                            list(lon = 1, lat = 0), 315)

  expect_equal(r1$lat, r2$lat, tolerance = 1e-10)
  expect_equal(r1$lat, r3$lat, tolerance = 1e-10)
  expect_equal(r1$lon, r2$lon, tolerance = 1e-10)
  expect_equal(r1$lon, r3$lon, tolerance = 1e-10)
})

test_that("geodesic_intersect handles antipodal intersection", {
  # Two geodesics from same point with different azimuths
  # They will intersect at the antipode
  result <- geodesic_intersect(c(0, 0), 0, c(0, 0), 90)

  expect_s3_class(result, "data.frame")
  # At origin, both displacements should be 0
  expect_lt(abs(result$x), 1)
  expect_lt(abs(result$y), 1)
})

test_that("geodesic_intersect_segment handles NA inputs", {
  result <- geodesic_intersect_segment(
    c(NA, 0), c(0, 1),
    c(-1, 0), c(1, 0)
  )

  expect_true(is.na(result$x))
  expect_true(is.na(result$segmode))
})

test_that("geodesic_intersect_next handles NA inputs", {
  result <- geodesic_intersect_next(c(NA, 0), 45, 315)

  expect_true(is.na(result$x))
  expect_true(is.na(result$y))
})

test_that("intersection lat/lon is consistent with displacement", {
  # Verify that the returned lat/lon matches moving along geodesic X by x meters
  result <- geodesic_intersect(c(0, 0), 45, c(1, 0), 315)

  # Use geodesic_direct to verify
  check <- geodesic_direct_fast(c(0, 0), 45, result$x)

  expect_equal(result$lat, check$lat2, tolerance = 1e-8)
  expect_equal(result$lon, check$lon2, tolerance = 1e-8)
})
