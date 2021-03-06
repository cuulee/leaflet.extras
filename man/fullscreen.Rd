% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fullscreen.R
\name{addFullscreenControl}
\alias{addFullscreenControl}
\title{Add fullscreen control}
\usage{
addFullscreenControl(map, position = "topleft")
}
\arguments{
\item{map}{The leaflet map}

\item{position}{position of control: 'topleft', 'topright', 'bottomleft', or 'bottomright'}
}
\description{
Add a fullscreen control button
}
\examples{
\dontrun{
leaflet() \%>\% addTiles() \%>\%
  addFullscreenControl()
}
}

