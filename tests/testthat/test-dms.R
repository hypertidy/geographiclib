test_that("dms_decode parses DMS strings", {
  # Basic DMS with hemisphere
  result <- dms_decode("40d26'47\"N")
  expect_s3_class(result, "data.frame")
  expect_equal(result$angle, 40 + 26/60 + 47/3600, tolerance = 1e-6)
  expect_equal(result$indicator, 1L)  # LATITUDE

  # Longitude
  result <- dms_decode("74d0'21.5\"W")
  expect_equal(result$angle, -(74 + 0/60 + 21.5/3600), tolerance = 1e-6)
  expect_equal(result$indicator, 2L)  # LONGITUDE
})

test_that("dms_decode handles various formats", {
  # Colon-separated
  result <- dms_decode("40:26:47")
  expect_equal(result$angle, 40 + 26/60 + 47/3600, tolerance = 1e-6)
  expect_equal(result$indicator, 0L)  # NONE

  # Negative values
  result <- dms_decode("-74:0:21.5")
  expect_equal(result$angle, -(74 + 0/60 + 21.5/3600), tolerance = 1e-6)

  # Degrees and minutes only
  result <- dms_decode("40d26.783'")
  expect_equal(result$angle, 40 + 26.783/60, tolerance = 1e-6)

  # Decimal degrees with hemisphere
  result <- dms_decode("40.446S")
  expect_equal(result$angle, -40.446, tolerance = 1e-6)
  expect_equal(result$indicator, 1L)  # LATITUDE
})

test_that("dms_decode is vectorized", {
  inputs <- c("40d26'47\"N", "-74d0'21.5\"", "51d30'N")
  result <- dms_decode(inputs)

  expect_equal(nrow(result), 3)
  expect_equal(result$indicator, c(1L, 0L, 1L))
})

test_that("dms_decode_latlon parses coordinate pairs", {
  result <- dms_decode_latlon("40d26'47\"N", "74d0'21.5\"W")

  expect_s3_class(result, "data.frame")
  expect_equal(result$lat, 40 + 26/60 + 47/3600, tolerance = 1e-6)
  expect_equal(result$lon, -(74 + 0/60 + 21.5/3600), tolerance = 1e-6)
})

test_that("dms_decode_latlon handles longfirst", {
  # Default: lat first

  result1 <- dms_decode_latlon("40.5", "-74.0")
  expect_equal(result1$lat, 40.5, tolerance = 1e-6)
  expect_equal(result1$lon, -74.0, tolerance = 1e-6)

  # longfirst = TRUE
  result2 <- dms_decode_latlon("-74.0", "40.5", longfirst = TRUE)
  expect_equal(result2$lat, 40.5, tolerance = 1e-6)
  expect_equal(result2$lon, -74.0, tolerance = 1e-6)
})

test_that("dms_decode_latlon is vectorized", {
  result <- dms_decode_latlon(
    c("40d26'47\"N", "51d30'0\"N"),
    c("74d0'21.5\"W", "0d7'0\"W")
  )

  expect_equal(nrow(result), 2)
  expect_equal(result$lat[2], 51.5, tolerance = 1e-4)
})

test_that("dms_decode_angle works without hemisphere", {
  result <- dms_decode_angle(c("45:30:0", "123d45'6\""))

  expect_length(result, 2)

  expect_equal(result[1], 45.5, tolerance = 1e-6)
  expect_equal(result[2], 123 + 45/60 + 6/3600, tolerance = 1e-6)
})

test_that("dms_decode_azimuth works with E/W", {
  result <- dms_decode_azimuth(c("45:30:0", "90W", "45E"))

  expect_length(result, 3)
  expect_equal(result[1], 45.5, tolerance = 1e-6)
  expect_equal(result[2], -90, tolerance = 1e-6)
  expect_equal(result[3], 45, tolerance = 1e-6)
})

test_that("dms_encode produces valid DMS strings", {
  # Latitude
  result <- dms_encode(40.446, indicator = "latitude")
  expect_type(result, "character")
  expect_match(result, "N$")

  # Longitude (negative = West)
  result <- dms_encode(-74.006, indicator = "longitude")
  expect_match(result, "W$")

  # No indicator
  result <- dms_encode(-40.446, indicator = "none")
  expect_match(result, "^-")
})

test_that("dms_encode with different precisions", {
  # Low precision (degrees only, no 'd' suffix with prec=0)
  result <- dms_encode(40.446, prec = 0)
  expect_match(result, "^40")

  # Medium precision (minutes)
  result <- dms_encode(40.446, prec = 2)
  expect_match(result, "'")

  # High precision (seconds)
  result <- dms_encode(40.446, prec = 5)
  expect_match(result, "\"")
})

test_that("dms_encode with separator", {
  result <- dms_encode(40.446, prec = 5, sep = ":")
  expect_match(result, ":")
  expect_false(grepl("d", result))
  expect_false(grepl("'", result))
})

test_that("dms_encode with explicit component", {
  # Force output in minutes
  result <- dms_encode(40.5, component = "minute", prec = 2)
  expect_match(result, "'$")
})

test_that("dms_encode is vectorized", {
  result <- dms_encode(c(40.446, -74.006, 51.5), prec = 3)
  expect_length(result, 3)
})

test_that("dms_split works", {
  # Split into d, m
  result <- dms_split(40.5)
  expect_s3_class(result, "data.frame")
  expect_equal(result$d, 40)
  expect_equal(result$m, 30, tolerance = 1e-6)

  # Split into d, m, s
  result <- dms_split(40 + 26/60 + 47/3600, seconds = TRUE)
  expect_equal(result$d, 40)
  expect_equal(result$m, 26, tolerance = 1e-6)
  expect_equal(result$s, 47, tolerance = 1e-4)
})

test_that("dms_split handles negative angles", {
  result <- dms_split(-40.5, seconds = TRUE)
  expect_equal(result$d, -40)
  # Minutes should be negative too for proper reconstruction
})

test_that("dms_split is vectorized", {
  result <- dms_split(c(40.5, 74.25), seconds = TRUE)
  expect_equal(nrow(result), 2)
})

test_that("dms_combine works", {
  # Basic combination
  result <- dms_combine(40, 26, 47)
  expect_equal(result, 40 + 26/60 + 47/3600, tolerance = 1e-6)

  # Defaults for m, s
  expect_equal(dms_combine(40), 40)
  expect_equal(dms_combine(40, 30), 40.5)
})

test_that("dms_combine is vectorized", {
  result <- dms_combine(
    d = c(40, 74),
    m = c(26, 0),
    s = c(47, 21.5)
  )
  expect_length(result, 2)
})

test_that("dms round-trip works", {
  original <- c(40.446195, -74.006328, 51.507351)

  # Encode and decode
  encoded <- dms_encode(original, prec = 6)
  decoded <- dms_decode(encoded)

  expect_equal(decoded$angle, original, tolerance = 1e-5)
})

test_that("dms_split and dms_combine are inverses",
{
  original <- c(40.446195, -74.006328)

  split <- dms_split(original, seconds = TRUE)
  combined <- dms_combine(split$d, split$m, split$s)

  expect_equal(combined, original, tolerance = 1e-9)
})

test_that("dms handles NA values", {
  # decode with invalid input returns NA
  result <- dms_decode("invalid")
  expect_true(is.na(result$angle))
  expect_true(is.na(result$indicator))

  # split with NA
  result <- dms_split(NA_real_)
  expect_true(is.na(result$d))
  expect_true(is.na(result$m))

  # combine with NA
  result <- dms_combine(NA_real_, 30, 0)
  expect_true(is.na(result))
})

test_that("dms_encode indicator validation", {
  expect_error(dms_encode(40, indicator = "invalid"))
})

test_that("dms_encode component validation", {
  expect_error(dms_encode(40, component = "invalid"))
})
