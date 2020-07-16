#capetown map

library(raster)
library(leaflet)
library(leaflet.extras)
library(leaflet.extras2)
library(osmdata)
library(ggmap)

cape_old = raster::stack("capetown_modified.tif")


