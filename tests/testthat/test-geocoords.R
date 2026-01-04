test_that("geocoords_parse works with MGRS", {
  result <- geocoords_parse("33TWN0500049000")

  expect_s3_class(result, "data.frame")
  expect_true(result$lat > 40 && result$lat < 50)
  expect_true(result$lon > 10 && result$lon < 20)
})

test_that("geocoords_to_mgrs works", {
  pts <- cbind(lon = c(147, -74), lat = c(-42, 40))
  result <- geocoords_to_mgrs(pts)

  expect_type(result, "character")
  expect_length(result, 2)
})

test_that("geocoords_to_utm works", {
  pts <- cbind(lon = c(147, -74), lat = c(-42, 40))
  result <- geocoords_to_utm(pts)

  expect_type(result, "character")
  expect_length(result, 2)
})

test_that("geocoords round-trip works", {
  original <- cbind(lon = 147.32, lat = -42.88)
  mgrs <- geocoords_to_mgrs(original, precision = 5)
  parsed <- geocoords_parse(mgrs)

  expect_equal(parsed[["lon"]][1L], original[1, 1], tolerance = 0.0001, ignore_attr = TRUE)
  expect_equal(parsed$lat, original[1, 2], tolerance = 0.0001, ignore_attr = TRUE)
})
