test_that("geocoords_parse works with MGRS", {
  result <- geocoords_parse("33TWN0500049000")
  expect_equal(nrow(result), 1)
  expect_true(!is.na(result$lat))
  expect_true(!is.na(result$lon))
})

test_that("geocoords_parse works with UTM", {
  result <- geocoords_parse("33N 505000 4900000")
  expect_equal(nrow(result), 1)
  expect_true(!is.na(result$lat))
})

test_that("geocoords_parse works with DMS", {
  result <- geocoords_parse("40d26'47\"N 74d0'21\"W")
  expect_equal(nrow(result), 1)
  expect_equal(result$lat, 40.446, tolerance = 0.01)
  expect_equal(result$lon, -74.006, tolerance = 0.01)
})

test_that("geocoords_parse works with decimal", {
  result <- geocoords_parse("40.446 -74.006")
  expect_equal(nrow(result), 1)
  expect_equal(result$lat, 40.446, tolerance = 0.001)
  expect_equal(result$lon, -74.006, tolerance = 0.001)
})

test_that("geocoords_parse is vectorized", {
  result <- geocoords_parse(c("33TWN0500049000", "40.446 -74.006"))
  expect_equal(nrow(result), 2)
})

test_that("geocoords_parse handles NA", {
  result <- geocoords_parse(c("33TWN0500049000", NA_character_))
  expect_equal(nrow(result), 2)
  expect_true(!is.na(result$lat[1]))
  expect_true(is.na(result$lat[2]))
})

test_that("geocoords_parse handles invalid input", {
  result <- geocoords_parse("not a coordinate")
  expect_true(is.na(result$lat))
})
