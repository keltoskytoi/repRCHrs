# The 'merge' function from the Raster package is a little slow.
# For large projects a faster option is to work with gdal commands in R.

library(gdalUtils)
library(rgdal)
library(raster)

# wd and paths

wd <- ("E:/Lidar_Arch/basic_R_scr/merge_tif_folder")
setwd(wd)

raster_in <- paste0(wd, ("/raster_input"))
raster_out <- paste0(wd, ("/raster_output"))


# shorts and vars.

merged_raster <- ("merge_try")



# Build list of all raster files you want to join (in your current working directory).

raster_files <-  list.files(raster_in,
                            pattern = glob2rx("*.tif"),
                            full.names = TRUE)

all_my_rasts <- c(raster_files)


# Make a template raster file to build onto. Think of this a big blank canvas to add tiles to.

e <- extent(-131, -124, 49, 53)
template <- raster(e)
projection(template) <- '+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0'
writeRaster(template, file=paste0(raster_out, "/", merged_raster, ".tif"), format="GTiff")


# Merge all raster tiles into one big raster.

mosaic_rasters(gdalfile=all_my_rasts,dst_dataset=paste0(raster_out, "/", merged_raster, ".tif"),of="GTiff")
gdalinfo(merged_raster)
