#india_test

library(raster)
library(rayshader)

testindia = raster::stack("1870_southern-india_modified.tif")

india_bb = raster::extent(c(68,92,1,20))
cropped_india = raster::crop(testindia, india_bb)

#Convert to RGB array
india_array = as.array(cropped_india)

#Load elevation data, sourced from GEBCO
raster1 = raster::raster("gebco_2020_n28_s5.w59_e93.tif")

#Reproject and crop elevation data to historical map coordinate system
reprojected_india = raster::projectRaster(raster1, crs=raster::crs(cropped_india))
cropped_reprojected_india = raster::crop(reprojected_india,india_bb)

#Reduce the size of the elevation data, for speed
small_india_matrix = resize_matrix(as.matrix(cropped_reprojected_india), scale = 0.2)

#Remove bathymetry data
water_india = small_india_matrix
water_india[is.na(water_india)] = 0
water_india[water_india < 0]=0
water_india = t(water_india)

#Compute shadows
ambient_layer = ambient_shade(water_india, zscale = 10, multicore = TRUE, maxsearch = 200)
ray_layer = ray_shade(water_india, zscale = 20, multicore = TRUE)

#Plot in 3D
(india_array/255) %>%
  add_shadow(ray_layer,0.3) %>%
  add_shadow(ambient_layer,0) %>%
  plot_3d(water_india,zscale=130)

#Render snapshot with depth of field
render_depth(focus=0.982,focallength = 4000)

#Plot in 2D
(india_array/255) %>%
  add_shadow(ray_layer,0.3) %>%
  add_shadow(ambient_layer,0) %>%
  plot_map()
