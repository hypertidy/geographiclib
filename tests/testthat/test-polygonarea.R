test_that("polygon_area works with single polygon", {
  # Triangle: London - New York - Rio de Janeiro
  pts <- cbind(
    lon = c(0, -74, -43),
    lat = c(52, 41, -23)
  )
  result <- polygon_area(pts)

  expect_type(result, "list")
  expect_named(result, c("area", "perimeter", "n"))
  expect_equal(result$n, 3)
  expect_true(is.numeric(result$area))
  expect_true(is.numeric(result$perimeter))
  expect_true(result$perimeter > 0)
})

test_that("polygon_area accepts different input formats", {
  pts_matrix <- cbind(c(0, -74, -43), c(52, 41, -23))
  pts_df <- data.frame(lon = c(0, -74, -43), lat = c(52, 41, -23))
  pts_list <- list(lon = c(0, -74, -43), lat = c(52, 41, -23))

  result1 <- polygon_area(pts_matrix)
  result2 <- polygon_area(pts_df)
  result3 <- polygon_area(pts_list)

  expect_equal(result1$area, result2$area)
  expect_equal(result1$area, result3$area)
  expect_equal(result1$perimeter, result2$perimeter)
})

test_that("polygon_area handles multiple polygons with id", {
  pts <- cbind(
    lon = c(0, -74, -43, 100, 110, 105),
    lat = c(52, 41, -23, 10, 10, 20)
  )
  result <- polygon_area(pts, id = c(1, 1, 1, 2, 2, 2))

  expect_s3_class(result, "data.frame")
  expect_named(result, c("id", "area", "perimeter", "n"))
  expect_equal(nrow(result), 2)
  expect_equal(result$id, c(1, 2))
  expect_equal(result$n, c(3, 3))
})

test_that("polygon_area gives correct sign for winding direction", {
  # Counter-clockwise polygon (positive area)
  ccw <- cbind(
    lon = c(0, 1, 1, 0),
    lat = c(0, 0, 1, 1)
  )
  # Clockwise polygon (negative area)
  cw <- cbind(
    lon = c(0, 0, 1, 1),
    lat = c(0, 1, 1, 0)
  )

  result_ccw <- polygon_area(ccw)
  result_cw <- polygon_area(cw)

  # Areas should be opposite signs
  expect_true(sign(result_ccw$area) != sign(result_cw$area))

  # Absolute areas should be equal
  expect_equal(abs(result_ccw$area), abs(result_cw$area), tolerance = 1e-6)
})

test_that("polygon_area computes polyline length", {
  pts <- cbind(
    lon = c(0, 1, 2),
    lat = c(0, 0, 0)
  )

  result <- polygon_area(pts, polyline = TRUE)

  expect_true(result$perimeter > 0)
  # For a polyline, area is not meaningful but should still be returned
  expect_true(is.numeric(result$area))
})

test_that("polygon_area rejects too few points", {
  expect_error(polygon_area(cbind(0, 0)), "at least 3 points")
  expect_error(polygon_area(cbind(c(0, 1), c(0, 1))), "at least 3 points")
})

test_that("polygon_area polyline accepts 2 points", {
  pts <- cbind(c(0, 1), c(0, 0))
  result <- polygon_area(pts, polyline = TRUE)
  expect_equal(result$n, 2)
})


test_that("polygon_area gives reasonable values for known polygon", {
  # Approximate 1 degree x 1 degree square at equator
  # Should be roughly 111km x 111km = ~12,321 km²
  square <- cbind(
    lon = c(0, 1, 1, 0),
    lat = c(0, 0, 1, 1)
  )
  result <- polygon_area(square)

  area_km2 <- abs(result$area) / 1e6
  # Should be approximately 12,321 km² (allowing some tolerance)
  expect_true(area_km2 > 12000 && area_km2 < 12500)

  # Perimeter should be roughly 4 * 111km = 444 km
  perim_km <- result$perimeter / 1000
  expect_true(perim_km > 440 && perim_km < 450)
})

test_that("polygon_area_cumulative returns correct structure", {
  pts <- cbind(
    lon = c(0, -74, -43, 28),
    lat = c(52, 41, -23, -26)
  )
  result <- polygon_area_cumulative(pts)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("lon", "lat", "area", "perimeter"))
  expect_equal(nrow(result), 4)
  expect_equal(result$lon, pts[, 1])
  expect_equal(result$lat, pts[, 2])
})

test_that("polygon_area_cumulative shows accumulating values", {
  pts <- cbind(
    lon = c(0, 1, 1, 0),
    lat = c(0, 0, 1, 1)
  )
  result <- polygon_area_cumulative(pts)

  # Perimeter should generally increase (or stay same) as points added
  # Area magnitude should generally increase
  expect_true(all(diff(abs(result$perimeter)) >= 0))
})

test_that("polygon_area handles large polygons",
          {
            # Hemisphere-scale polygon
            pts <- cbind(
              lon = c(-180, 0, 180, 0),
              lat = c(0, 45, 0, -45)
            )
            result <- polygon_area(pts)

            # Should complete without error and return valid numbers

            expect_true(is.finite(result$area))
            expect_true(is.finite(result$perimeter))
            expect_true(result$perimeter > 0)
          })

test_that("polygon_area works with many polygons", {
  # 100 triangles
  n_polys <- 100
  lon <- runif(n_polys * 3, -180, 180)
  lat <- runif(n_polys * 3, -60, 60)
  id <- rep(1:n_polys, each = 3)

  pts <- cbind(lon, lat)
  result <- polygon_area(pts, id = id)

  expect_equal(nrow(result), n_polys)
  expect_equal(result$id, 1:n_polys)
  expect_true(all(result$n == 3))
  expect_true(all(is.finite(result$area)))
  expect_true(all(result$perimeter > 0))
})
