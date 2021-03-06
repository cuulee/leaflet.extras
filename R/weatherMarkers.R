
# Source https://github.com/mapshakers/leaflet-icon-weather
weatherIconDependency <- function() {
  list(
    htmltools::htmlDependency(
      "leaflet-icon-weather",version = "3.0.0",
      system.file("htmlwidgets/lib/weather-markers", package = "leaflet.extras"),
      script = c("leaflet.weather-markers.min.js", "plugin-weatherMarkers-bindings.js"),
      stylesheet =c("weather-icons.min.css", "weather-icons-wind.min.css",
                    "leaflet.weather-markers.css" )
      )
  )
}

# These are the only colors supported for the marker as per the CSS.
markerColors <- c("red", "darkred", "lightred", "orange", "beige", "green", "darkgreen", "lightgreen", "blue", "darkblue", "lightblue", "purple", "darkpurple", "pink", "cadetblue", "white", "gray", "lightgray", "black")

#' Make weather-icon set
#'
#' @param ... icons created from \code{\link{makeWeatherIcon}()}
#' @export
#' @examples
#'
#' iconSet = weatherIconList(
#'   hurricane = makeWeatherIcon(icon='hurricane'),
#'   tornado = makeWeatherIcon(icon='tornado')
#' )
#'
#' iconSet[c('hurricane', 'tornado')]
#' @rdname weatherMarkers
weatherIconList = function(...) {
  res = structure(
    list(...),
    class = "leaflet_weather_icon_set"
  )
  cls = unlist(lapply(res, inherits, 'leaflet_weather_icon'))
  if (any(!cls))
    stop('Arguments passed to weatherIconList() must be icon objects returned from makeWeatherIcon()')
  res
}

#' @param x icons
#' @param i offset
#' @export
#' @rdname weatherMarkers
`[.leaflet_weather_icon_set` = function(x, i) {
  if (is.factor(i)) {
    i = as.character(i)
  }

  if (!is.character(i) && !is.numeric(i) && !is.integer(i)) {
    stop("Invalid subscript type '", typeof(i), "'")
  }

  structure(.subset(x, i), class = "leaflet_weather_icon_set")
}

weatherIconSetToWeatherIcons = function(x) {
  cols = names(formals(makeWeatherIcon))
  cols = structure(as.list(cols), names = cols)

  # Construct an equivalent output to weatherIcons().
  leaflet::filterNULL(lapply(cols, function(col) {
    # Pluck the `col` member off of each item in weatherIconObjs and put them in an
    # unnamed list (or vector if possible).
    colVals = unname(sapply(x, `[[`, col))

    # If this is the common case where there's lots of values but they're all
    # actually the same exact thing, then just return one value; this will be
    # much cheaper to send to the client, and we'll do recycling on the client
    # side anyway.
    if (length(unique(colVals)) == 1) {
      return(colVals[[1]])
    } else {
      return(colVals)
    }
  }))
}

#' Make Weather Icon
#'
#' @inheritParams weatherIcons
#' @export
#' @rdname weatherMarkers
makeWeatherIcon <- function(
  icon,
  markerColor= 'red',
  iconColor= 'white',
  #iconSize= c(35, 45),
  #iconAnchor=   c(17, 42),
  #popupAnchor= c(1, -32),
  #shadowAnchor= c(10, 12),
  #shadowSize= c(36, 16),
  #className= 'weather-marker',
  #prefix= 'wi',
  extraClasses= NULL
) {

  if(!markerColor %in% markerColors) {
    stop(sprintf("markerColor should be one of %s",paste(markerColors,collapse=', ')))
  }

  icon = leaflet::filterNULL(list(
    icon = icon, markerColor = markerColor,
    iconColor = iconColor, extraClasses = extraClasses
  ))
  structure(icon, class = "leaflet_weather_icon")
}

#' Create a list of weather icon data see
#' \url{https://github.com/mapshakers/leaflet-icon-weather}
#'
#' An icon can be represented as a list of the form \code{list(icon, markerColor,
#' ...)}. This function is vectorized over its arguments to create a list of
#' icon data. Shorter argument values will be re-cycled. \code{NULL} values for
#' these arguments will be ignored.
#' @param icon the weather icon name w/o the 'wi-' prefix. For a full list see \url{https://erikflowers.github.io/weather-icons/}
#' @param markerColor color of the marker
#' @param iconColor color of the weather icon
#' @param extraClasses Character vector of extra classes.
#' @export
#' @rdname weatherMarkers
weatherIcons <- function(
  icon,
  markerColor= 'red',
  iconColor= 'white',
  #iconSize= c(35, 45),
  #iconAnchor=   c(17, 42),
  #popupAnchor= c(1, -32),
  #shadowAnchor= c(10, 12),
  #shadowSize= c(36, 16),
  #className= 'weather-marker',
  #prefix= 'wi',
  extraClasses= NULL
) {

  if(!any(markerColor %in% markerColors)) {
    stop(sprintf("markerColor should be one of %s",paste(markerColors,collapse=', ')))
  }

  leaflet::filterNULL(list(
    icon = icon, markerColor = markerColor,
    iconColor = iconColor, extraClasses = extraClasses
  ))
}

#' Add Weather Markers
#' @param map the map to add weather Markers to.
#' @param lng a numeric vector of longitudes, or a one-sided formula of the form
#'   \code{~x} where \code{x} is a variable in \code{data}; by default (if not
#'   explicitly provided), it will be automatically inferred from \code{data} by
#'   looking for a column named \code{lng}, \code{long}, or \code{longitude}
#'   (case-insensitively)
#' @param lat a vector of latitudes or a formula (similar to the \code{lng}
#'   argument; the names \code{lat} and \code{latitude} are used when guessing
#'   the latitude column from \code{data})
#' @param popup a character vector of the HTML content for the popups (you are
#'   recommended to escape the text using \code{\link[htmltools]{htmlEscape}()}
#'   for security reasons)
#' @param popupOptions options for popup
#' @param layerId the layer id
#' @param group the name of the group the newly created layers should belong to
#'   (for \code{\link{clearGroup}} and \code{\link{addLayersControl}} purposes).
#'   Human-friendly group names are permitted--they need not be short,
#'   identifier-style names. Any number of layers and even different types of
#'   layers (e.g. markers and polygons) can share the same group name.
#' @param data the data object from which the argument values are derived; by
#'   default, it is the \code{data} object provided to \code{leaflet()}
#'   initially, but can be overridden
#' @param label a character vector of the HTML content for the labels
#' @param labelOptions A Vector of \code{\link{labelOptions}} to provide label
#' options for each label. Default \code{NULL}
#' @param clusterOptions if not \code{NULL}, markers will be clustered using
#'   \href{https://github.com/Leaflet/Leaflet.markercluster}{Leaflet.markercluster};
#'    you can use \code{\link{markerClusterOptions}()} to specify marker cluster
#'   options
#' @param clusterId the id for the marker cluster layer
#' @param options a list of extra options for tile layers, popups, paths
#'   (circles, rectangles, polygons, ...), or other map elements
#' @rdname weatherMarkers
#' @export
addWeatherMarkers = function(
  map, lng = NULL, lat = NULL, layerId = NULL, group = NULL,
  icon = NULL,
  popup = NULL,
  popupOptions = NULL,
  label = NULL,
  labelOptions = NULL,
  options = leaflet::markerOptions(),
  clusterOptions = NULL,
  clusterId = NULL,
  data = leaflet::getMapData(map)
) {
  map$dependencies <- c(map$dependencies,
                        weatherIconDependency())

  if (!is.null(icon)) {
    # If formulas are present, they must be evaluated first so we can pack the
    # resulting values
    icon = leaflet::evalFormula(list(icon), data)[[1]]

    if (inherits(icon, "leaflet_weather_icon_set")) {
      icon = weatherIconSetToWeatherIcons(icon)
    }
    icon = leaflet::filterNULL(icon)
  }

  if (!is.null(clusterOptions))
    map$dependencies = c(map$dependencies, leaflet::leafletDependencies$markerCluster())

  pts = leaflet::derivePoints(
    data, lng, lat, missing(lng), missing(lat), "addWeatherMarkers")
  leaflet::invokeMethod(
    map, data, 'addWeatherMarkers', pts$lat, pts$lng, icon, layerId,
    group, options, popup, popupOptions,
    clusterOptions, clusterId, leaflet::safeLabel(label, data), labelOptions
  ) %>% leaflet::expandLimits(pts$lat, pts$lng)
}
