#egypt

library(raster)
library(rayshader)

egypt = raster::stack("egypt_modified.tif")

cropped_egypt = raster::crop(egypt,raster::extent(c(27.6,35.4,23.4,32.1)))

#Convert to RGB array
egypt_array = as.array(cropped_egypt)

#Load elevation data, sourced from GEBCO
raster1 = raster::raster("gebco_egypt.tif")

#Reproject and crop elevation data to historical map coordinate system
reprojected_egypt = raster::projectRaster(raster1, crs=raster::crs(egypt))
cropped_reprojected_egypt = raster::crop(reprojected_egypt,extent(cropped_egypt))

#Reduce the size of the elevation data, for speed
small_egypt_matrix = resize_matrix(as.matrix(cropped_reprojected_egypt), scale = 0.8)

#Remove bathymetry data
water_egypt = small_egypt_matrix
water_egypt[is.na(water_egypt)] = 0
water_egypt[water_egypt < 0]=0
water_egypt = t(water_egypt)

#Compute shadows
ambient_layer = ambient_shade(water_egypt, zscale = 10, multicore = TRUE, maxsearch = 200)
ray_layer = ray_shade(water_egypt, zscale = 20, multicore = TRUE)

#Plot in 3D
# (egypt_array/255) %>%
#   add_shadow(ray_layer,0.3) %>%
#   add_shadow(ambient_layer,0) %>%
#   plot_3d(water_india,zscale=130)
# 
# #Render snapshot with depth of field
# render_depth(focus=0.982,focallength = 4000)

#Plot in 2D
(egypt_array/255) %>%
  add_shadow(ray_layer,0.3) %>%
  add_shadow(ambient_layer,0) %>%
  plot_map()
