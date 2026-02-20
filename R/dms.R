#' Convert between degrees and DMS (degrees, minutes, seconds) representation
#'
#' @description
#' Parse strings representing degrees, minutes, and seconds and return the
#' angle in degrees. Format an angle in degrees as degrees, minutes, and
#' seconds strings.
#'
#' @param x Character vector of DMS strings to parse, or numeric vector of
#'   angles in degrees to encode.
#' @param dmsa,dmsb Character vectors of DMS strings for latitude/longitude
#'   parsing.
#' @param d,m,s Numeric vectors of degrees, minutes, and seconds.
#' @param prec Integer precision for output strings. For `dms_encode()` this
#'   is the number of digits after the decimal point for the trailing
#'   component. For automatic encoding, prec < 2 gives degrees, prec 2-3
#'   gives minutes, prec >= 4 gives seconds.
#' @param component Character indicating the trailing unit: `"degree"`,
#'   `"minute"`, or `"second"`.
#' @param indicator Character indicating formatting: `"none"` (signed result),
#'   `"latitude"` (trailing N/S), `"longitude"` (trailing E/W),
#'   `"azimuth"` (0-360, no sign), or `"number"` (plain number).
#' @param sep Character to use as DMS separator instead of d, ', ".
#'   Use `":"` for colon-separated output.
#' @param longfirst Logical; if TRUE, assume longitude is given before
#'   latitude when no hemisphere designators are present.
#'
#' @returns
#' * `dms_decode()`: Data frame with columns `angle` (degrees) and `indicator`
#'   (0=NONE, 1=LATITUDE, 2=LONGITUDE)
#' * `dms_decode_latlon()`: Data frame with columns `lat` and `lon` (degrees)
#' * `dms_decode_angle()`: Numeric vector of angles in degrees
#' * `dms_decode_azimuth()`: Numeric vector of azimuths in degrees (range
#'   -180 to 180)
#' * `dms_encode()`: Character vector of DMS strings
#' * `dms_split()`: Data frame with columns `d`, `m`, and optionally `s`
#' * `dms_combine()`: Numeric vector of angles in degrees
#'
#' @details
#' ## Input Formats
#'
#' The `dms_decode()` function accepts various input formats:
#' - Degrees, minutes, seconds: `"40d26'47\"N"`, `"40°26'47\"N"`
#' - Degrees and minutes: `"40d26.783'N"`, `"40:26.783N"`
#' - Decimal degrees: `"40.446N"`, `"-40.446"`
#' - Colon-separated: `"40:26:47"`, `"-74:0:21.5"`
#'
#' Hemisphere designators (N, S, E, W) can appear at the beginning or end.
#' Many Unicode symbols are supported for degrees (\enc{°}{deg}, \enc{º}{o}, \enc{˚}{ring above}),
#' minutes (', \enc{′}{prime}), and seconds (", \enc{″}{double prime}).
#'
#' ## Precision and Components
#'
#' For `dms_encode()`, the `prec` parameter controls decimal places in the

#' trailing component:
#' - `prec = 0`: whole degrees/minutes/seconds
#' - `prec = 1`: one decimal place
#' - `prec = 2`: two decimal places, etc.
#'
#' For automatic component selection:
#' - `prec < 2`: output in degrees
#' - `prec = 2, 3`: output in degrees and minutes
#' - `prec >= 4`: output in degrees, minutes, and seconds
#'
#' @seealso [geocoords_parse()] for parsing complete coordinate strings
#'
#' @export
#' @examples
#' # Parse DMS strings
#' dms_decode("40d26'47\"N")
#' dms_decode(c("40:26:47", "-74:0:21.5", "51d30'N"))
#'
#' # Parse latitude/longitude pairs
#' dms_decode_latlon("40d26'47\"N", "74d0'21.5\"W")
#'
#' # Parse angles (no hemisphere designator)
#' dms_decode_angle(c("45:30:0", "123d45'6\""))
#'
#' # Parse azimuths (E/W allowed)
#' dms_decode_azimuth(c("45:30:0", "90W", "45E"))
#'
#' # Encode to DMS strings
#' dms_encode(40.446, indicator = "latitude")
#' dms_encode(-74.006, indicator = "longitude")
#' dms_encode(c(40.446, -74.006), prec = 2)
#'
#' # With colon separator
#' dms_encode(40.446, sep = ":")
#'
#' # Split angle into components
#' dms_split(40.446)
#' dms_split(c(40.446, -74.006), seconds = TRUE)
#'
#' # Combine components to decimal degrees
#' dms_combine(40, 26, 47)
#' dms_combine(d = c(40, -74), m = c(26, 0), s = c(47, 21.5))
dms_decode <- function(x) {
  dms_decode_cpp(as.character(x))
}

#' @rdname dms_decode
#' @export
dms_decode_latlon <- function(dmsa, dmsb, longfirst = FALSE) {
  dmsa <- as.character(dmsa)
  dmsb <- as.character(dmsb)
  n <- max(length(dmsa), length(dmsb))
  dmsa <- rep_len(dmsa, n)
  dmsb <- rep_len(dmsb, n)
  longfirst <- rep_len(as.logical(longfirst), n)
  dms_decode_latlon_cpp(dmsa, dmsb, longfirst)
}

#' @rdname dms_decode
#' @export
dms_decode_angle <- function(x) {
  dms_decode_angle_cpp(as.character(x))
}

#' @rdname dms_decode
#' @export
dms_decode_azimuth <- function(x) {
  dms_decode_azimuth_cpp(as.character(x))
}

#' @rdname dms_decode
#' @export
dms_encode <- function(x, prec = 5L, component = NULL, indicator = "none",
                       sep = "") {
  x <- as.numeric(x)
  n <- length(x)
  prec <- as.integer(rep_len(prec, n))
  sep <- as.character(rep_len(sep, n))

  # Map indicator string to integer
  ind_map <- c(none = 0L, latitude = 1L, longitude = 2L, azimuth = 3L, number = 4L)
  indicator <- tolower(as.character(indicator))
  indicator <- rep_len(indicator, n)
  ind_int <- ind_map[indicator]
  if (any(is.na(ind_int))) {
    stop("indicator must be one of: 'none', 'latitude', 'longitude', 'azimuth', 'number'")
  }

  if (is.null(component)) {
    # Use automatic component selection based on precision
    dms_encode_auto_cpp(x, prec, ind_int, sep)
  } else {
    # Map component string to integer
    comp_map <- c(degree = 0L, minute = 1L, second = 2L)
    component <- tolower(as.character(component))
    component <- rep_len(component, n)
    comp_int <- comp_map[component]
    if (any(is.na(comp_int))) {
      stop("component must be one of: 'degree', 'minute', 'second'")
    }
    dms_encode_cpp(x, comp_int, prec, ind_int, sep)
  }
}

#' @rdname dms_decode
#' @param seconds Logical; if TRUE, split into degrees, minutes, and seconds.
#'   If FALSE (default), split into degrees and minutes only.
#' @export
dms_split <- function(x, seconds = FALSE) {
  x <- as.numeric(x)
  if (seconds) {
    dms_split_dms_cpp(x)
  } else {
    dms_split_dm_cpp(x)
  }
}

#' @rdname dms_decode
#' @export
dms_combine <- function(d, m = 0, s = 0) {
  n <- max(length(d), length(m), length(s))
  d <- rep_len(as.numeric(d), n)
  m <- rep_len(as.numeric(m), n)
  s <- rep_len(as.numeric(s), n)
  dms_combine_cpp(d, m, s)
}
