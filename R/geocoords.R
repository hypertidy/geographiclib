#' Parse Geographic Coordinate Strings
#'
#' Parse coordinate strings in various formats (MGRS, UTM/UPS, DMS, decimal)
#' and return latitude/longitude.
#'
#' @param x Character vector of coordinate strings to parse
#'
#' @return Data frame with columns:
#' * `lat` - Latitude in degrees
#' * `lon` - Longitude in degrees
#' * `zone` - UTM/UPS zone number
#' * `northp` - Logical, TRUE if in northern hemisphere
#' * `easting` - UTM/UPS easting in meters
#' * `northing` - UTM/UPS northing in meters
#'
#' @details
#' Accepts coordinates in multiple formats:
#' * MGRS: `"33TWN0500049000"`
#' * UTM/UPS: `"33N 505000 4900000"`
#' * DMS: `"40d26'47\"N 74d0'21\"W"`
#' * Decimal: `"40.446 -74.006"`
#'
#' @examples
#' # Parse MGRS
#' geocoords_parse("33TWN0500049000")
#'
#' # Parse UTM
#' geocoords_parse("33N 505000 4900000")
#'
#' # Parse DMS
#' geocoords_parse("40d26'47\"N 74d0'21\"W")
#'
#' # Parse decimal
#' geocoords_parse("40.446 -74.006")
#'
#' # Vectorized
#' geocoords_parse(c("33TWN0500049000", "40.446 -74.006"))
#'
#' @seealso [mgrs_fwd()], [mgrs_rev()], [utmups_fwd()], [utmups_rev()], [dms_decode()]
#'
#' @export
geocoords_parse <- function(x) {
  geocoords_parse_cpp(x)
}
