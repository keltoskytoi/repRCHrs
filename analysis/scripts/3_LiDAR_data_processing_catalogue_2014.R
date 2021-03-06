####################################SHORTCUTS###################################
#Because the the Lidar data from 2014 is appr. 8 BG and that from 2018 appr.
#150 GBs, it had to be moved outside of the project.
lsLIDAR14 <- list.files(("E:/REPO/LiDAR_14"),
                        pattern = glob2rx("*.laz"),
                        full.names = TRUE)

##########################APPLICATION TO THE WHOLE DATASET#########################
################################BUILD A LAZ CATALOG###############################
#we have multiple LAZ files, so it is best to write them in a catalog

LIDAR_2014_catalog <-  lidR::readLAScatalog(lsLIDAR14, select = "xyzirnc", filter ="keep_class 2")
#set the projection of the lidR catalog
sp::proj4string(LIDAR_2014_catalog) <- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"

#summary of the catalog
summary(LIDAR_2014_catalog)
#class       : LAScatalog (v1.3 format 1)
#extent      : 477996.1, 488000, 5616000, 5634000 (xmin, xmax, ymin, ymax)
#coord. ref. : +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
#area        : 180 km²
#points      : 2.1billion points
#density     : 11.7 points/m²
#num. files  : 180
#proc. opt.  : buffer: 30 | chunk: 0
#input opt.  : select: xyzirnc | filter: keep_class 2
#output opt. : in memory | w2w guaranteed | merging enabled
#drivers     :
#- Raster : format = GTiff  NAflag = -999999
#- LAS : no parameter
#- Spatial : overwrite = FALSE
#- SimpleFeature : quiet = TRUE
#- DataFrame : no parameter

lidR::las_check(LIDAR_2014_catalog)
#Checking headers consistency
#- Checking file version consistency... ✓
#- Checking scale consistency...
#⚠ Inconsistent scale factors
#- Checking offset consistency...
#⚠ Inconsistent offsets
#- Checking point type consistency... ✓
#- Checking VLR consistency... ✓
#- Checking CRS consistency... ✓
#Checking the headers
#- Checking scale factor validity... ✓
#- Checking Point Data Format ID validity... ✓
#Checking preprocessing already done
#- Checking negative outliers... ✓
#- Checking normalization... no
#Checking the geometry
#- Checking overlapping tiles... ✓
#- Checking point indexation... no

plot(LIDAR_2014_catalog)
plot(LIDAR_2014_catalog, mapview = TRUE, map.type = "Esri.WorldImagery")
#check outliers:
spplot(LIDAR_2014_catalog, "Min.Z")


#set variables for the lidR catalog####

#paralellize the work
future::plan(multisession, workers = 2L)
#set the number of threads lidR should use
lidR::set_lidr_threads(4)

#chunk size in which lidR should process: in meters!
#lidR::opt_chunk_size(LIDAR_2014_catalog) # the 1000x1000 m chunks are perfect!
lidR::opt_chunk_buffer(LIDAR_2014_catalog) <- 50# default: 30
plot(LIDAR_2014_catalog, chunk= TRUE)
opt_output_files(LIDAR_2014_catalog) <- paste0(path_analysis_data_DTM201, "/{*}_xyzirnc_ground_01")
#enable to overwrite result when processed again
LIDAR_2014_catalog@output_options$drivers$Raster$param$overwrite <- TRUE

#apply terrain gridding
ground_class_CAT2014 <- lidR::grid_terrain(LIDAR_2014_catalog, res=0.1, algorithm = knnidw(k = 20L, p = 3, rmax = 50))

#create a basic function
DTM_20XX <- function(LIDAR_2014_catalog)
{
  dtm_2014 <- grid_terrain(LIDAR_2014_catalog, 1, res=0.1, algorithm = knnidw(k = 20L, p = 3, rmax = 50)) # create dtm
  return(dtm_2014) # output
}


#create a bit more complicated function
DTM_20XX <- function(LIDAR_2014_catalog)
{
  opt_output_files(LIDAR_2014_catalog) <- paste0(path_analysis_data_dtm2014, "/{*}_xyzirnc_ground_IDW01")
  LIDAR_2014_catalog@output_options$drivers$Raster$param$overwrite <- TRUE
  lidR::opt_chunk_buffer(LIDAR_2014_catalog) <- 50
  dtm_2014 <- grid_terrain(LIDAR_2014_catalog, 1, res=0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
  return(dtm_2014) # output
}
DTM_20XX(LIDAR_2014_catalog)

#Warnmeldungen:####
#Warnmeldungen:
#1: There were 418 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2455 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#3: There were 467 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#4: There were 2632 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#5: There were 424 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#6: There were 2879 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#7: There were 469 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#8: There were 2747 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#9: There were 465 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#10: There were 2523 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#11: There were 341 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#12: There were 2554 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#13: There were 393 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#14: There were 2558 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#15: There were 324 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#16: There were 2524 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#17: Different files have different X scale factors and are incompatible. The first file has precedence and data were rescaled.
#18: Different files have different Y scale factors and are incompatible. The first file has precedence and data were rescaled.
#19: Different files have different Z scale factors and are incompatible. The first file has precedence and data were rescaled.
#20: There were 330 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#21: There were 2856 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#22: Different files have different X scale factors and are incompatible. The first file has precedence and data were rescaled.
#23: Different files have different Y scale factors and are incompatible. The first file has precedence and data were rescaled.
#24: Different files have different Z scale factors and are incompatible. The first file has precedence and data were rescaled.
#25: There were 391 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#26: There were 2956 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#27: Different files have different X scale factors and are incompatible. The first file has precedence and data were rescaled.
#28: Different files have different Y scale factors and are incompatible. The first file has precedence and data were rescaled.
#29: Different files have different Z scale factors and are incompatible. The first file has precedence and data were rescaled.
#30: There were 368 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#31: There were 2867 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#32: There were 300 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#33: There were 2504 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#34: There were 365 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#35: There were 2390 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#36: There were 463 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#37: There were 2689 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#38: There were 484 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#39: There were 2885 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#40: There were 438 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#41: There were 2949 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#42: There were 320 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#43: There were 2534 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#44: There were 380 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#45: There were 2768 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#46: There were 517 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#47: There were 3068 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#48: There were 585 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#49: There were 3255 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#50: There were 604 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
