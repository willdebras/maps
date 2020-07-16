#india_test

library(raster)
library(rayshader)

japan = raster::stack("japan_islands_modified.tif")

japan_ext = raster::extent(c(125,155,29,49))
cropped_japan = raster::crop(japan, japan_ext)

#Convert to RGB array
japan_array = as.array(cropped_japan)

#Load elevation data, sourced from GEBCO
raster1 = raster::raster("gebco_2020_japan.tif")

#Reproject and crop elevation data to historical map coordinate system
reprojected_japan = raster::projectRaster(raster1, crs=raster::crs(cropped_japan))
cropped_reprojected_japan = raster::crop(reprojected_japan,japan_ext)

#Reduce the size of the elevation data, for speed
small_japan_matrix = resize_matrix(as.matrix(cropped_reprojected_japan), scale = 0.2)

#Remove bathymetry data
water_japan = small_japan_matrix
water_japan[is.na(water_japan)] = 0
water_japan[water_japan < 0]=0
water_japan = t(water_japan)

#Compute shadows
ambient_layer = ambient_shade(water_japan, zscale = 10, multicore = TRUE, maxsearch = 200)
ray_layer = ray_shade(water_japan, zscale =30, multicore = TRUE)

#Plot in 3D
(japan_array/255) %>%
  add_shadow(ray_layer,0.3) %>%
  add_shadow(ambient_layer,0) %>%
  plot_3d(water_japan,zscale=130)

#Render snapshot with depth of field
render_depth(focus=0.982,focallength = 4000)

#Plot in 2D
(japan_array/255) %>%
  add_shadow(ray_layer,0.3) %>%
  add_shadow(ambient_layer,0) %>%
  plot_map()
