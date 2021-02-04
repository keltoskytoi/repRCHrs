####################################SHORTCUTS###################################
#Because the the Lidar data from 2014 is appr. 8 BG and that from 2018 appr.
#150 GBs, it had to be moved outside of the project.
lsLIDAR14 <- list.files(("E:/REPO/LiDAR_14"),
                        pattern = glob2rx("*.laz"),
                        full.names = TRUE)

##########################APPLICATION TO THE WHOLE DATASET#########################
################################BUILD A LAZ CATALOG###############################
#we have multiple LAZ files, so it is best to write them in a catalog

#define projection - EPSG 25832 ETRS89/UTM 32N
#check projection!

LIDAR_2014_catalog <-  lidR::readLAScatalog(lsLIDAR14, select = "xyzirnc", filter ="keep_class 2")
#set the projection of the lidR catalog
sp::proj4string(LIDAR_2014_catalog) <- sp::CRS("+init=epsg:25832")
#paralellize the work
future::plan(multisession, workers = 2L)
#set the number of threads lidR should use
lidR::set_lidr_threads(4)

#summary of the catalog
summary(LIDAR_2014_catalog)
#class       : LAScatalog (v1.3 format 1)
#extent      : 477996.1, 489000, 5616000, 5635000 (xmin, xmax, ymin, ymax)
#coord. ref. : ETRS89 / UTM zone 32N
#area        : 209 km²
#points      : 2.39billion points
#density     : 11.4 points/m²
#num. files  : 209
#proc. opt.  : buffer: 30 | chunk: 0
#input opt.  : select: xyzirnc | filter: keep_class 2
#output opt. : in memory | w2w guaranteed | merging enabled
#drivers     :
# - Raster : format = GTiff  NAflag = -999999
#- LAS : no parameter
#- Spatial : overwrite = FALSE
#- SimpleFeature : quiet = TRUE
#- DataFrame : no parameter

las_check(LIDAR_2014_catalog)
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

#chunk size in which lidR should process: 209 x 4 = 836
#lidR::opt_chunk_size(LIDAR_2014_catalog) <- 836
#- it stopped after 3 hours + all chunks had warnings
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


#create a function
DTM_20XX <- function(LIDAR_2014_catalog)
{
  opt_output_files(LIDAR_2014_catalog) <- paste0(path_analysis_data_dtm1, "/{*}_xyzirnc_ground_IDW01")
  LIDAR_2014_catalog@output_options$drivers$Raster$param$overwrite <- TRUE
  lidR::opt_chunk_buffer(LIDAR_2014_catalog) <- 50
  dtm_2014 <- grid_terrain(LIDAR_2014_catalog, 1, res=0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50)) # create dtm
  return(dtm_2014) # output
}
DTM_20XX(LIDAR_2014_catalog)

#Warnmeldungen:####
#1: There were 418 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2455 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#3: In getProjectionRef(x, OVERRIDE_PROJ_DATUM_WITH_TOWGS84 = OVERRIDE_PROJ_DATUM_WITH_TOWGS84,  ... :Discarded datum European_Terrestrial_Reference_System_1989 in Proj4 definition: +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
#4: In showSRID(uprojargs, format = "PROJ", multiline = "NO",  ... :Discarded datum Unknown based on GRS80 ellipsoid in Proj4 definition
#5: There were 424 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#6: There were 2879 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#7: In getProjectionRef(x, OVERRIDE_PROJ_DATUM_WITH_TOWGS84 = OVERRIDE_PROJ_DATUM_WITH_TOWGS84,  ... :Discarded datum European_Terrestrial_Reference_System_1989 in Proj4 definition: +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
#8: In showSRID(uprojargs, format = "PROJ", multiline = "NO",  ... :Discarded datum Unknown based on GRS80 ellipsoid in Proj4 definition
#9: There were 467 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#10: There were 2632 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#11: In getProjectionRef(x, OVERRIDE_PROJ_DATUM_WITH_TOWGS84 = OVERRIDE_PROJ_DATUM_WITH_TOWGS84,  ... :Discarded datum European_Terrestrial_Reference_System_1989 in Proj4 definition: +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
#12: In showSRID(uprojargs, format = "PROJ", multiline = "NO",  ... :Discarded datum Unknown based on GRS80 ellipsoid in Proj4 definition
#13: There were 469 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#14: There were 2747 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#15: In getProjectionRef(x, OVERRIDE_PROJ_DATUM_WITH_TOWGS84 = OVERRIDE_PROJ_DATUM_WITH_TOWGS84,  ... :Discarded datum European_Terrestrial_Reference_System_1989 in Proj4 definition: +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
#16: In showSRID(uprojargs, format = "PROJ", multiline = "NO",  ... :Discarded datum Unknown based on GRS80 ellipsoid in Proj4 definition
#17: There were 465 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#18: There were 2523 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#19: In getProjectionRef(x, OVERRIDE_PROJ_DATUM_WITH_TOWGS84 = OVERRIDE_PROJ_DATUM_WITH_TOWGS84,  ... :Discarded datum European_Terrestrial_Reference_System_1989 in Proj4 definition: +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
#20: In showSRID(uprojargs, format = "PROJ", multiline = "NO",  ... :Discarded datum Unknown based on GRS80 ellipsoid in Proj4 definition
#21: There were 341 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#22: There were 2554 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#23: In getProjectionRef(x, OVERRIDE_PROJ_DATUM_WITH_TOWGS84 = OVERRIDE_PROJ_DATUM_WITH_TOWGS84,  ... :Discarded datum European_Terrestrial_Reference_System_1989 in Proj4 definition: +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
#24: In showSRID(uprojargs, format = "PROJ", multiline = "NO",  ... :Discarded datum Unknown based on GRS80 ellipsoid in Proj4 definition
#25: There were 393 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#26: There were 2558 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#27: In getProjectionRef(x, OVERRIDE_PROJ_DATUM_WITH_TOWGS84 = OVERRIDE_PROJ_DATUM_WITH_TOWGS84,  ... :Discarded datum European_Terrestrial_Reference_System_1989 in Proj4 definition: +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
#28: In showSRID(uprojargs, format = "PROJ", multiline = "NO",  ... :Discarded datum Unknown based on GRS80 ellipsoid in Proj4 definition
#29: There were 324 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#30: There were 2524 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#31: In getProjectionRef(x, OVERRIDE_PROJ_DATUM_WITH_TOWGS84 = OVERRIDE_PROJ_DATUM_WITH_TOWGS84,  ... :Discarded datum European_Terrestrial_Reference_System_1989 in Proj4 definition: +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
#32: In showSRID(uprojargs, format = "PROJ", multiline = "NO",  ... :Discarded datum Unknown based on GRS80 ellipsoid in Proj4 definition
#33: Different files have different X scale factors and are incompatible. The first file has precedence and data were rescaled.
#34: Different files have different Y scale factors and are incompatible. The first file has precedence and data were rescaled.
#35: Different files have different Z scale factors and are incompatible. The first file has precedence and data were rescaled.
#36: There were 330 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#37: There were 2856 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#38: In getProjectionRef(x, OVERRIDE_PROJ_DATUM_WITH_TOWGS84 = OVERRIDE_PROJ_DATUM_WITH_TOWGS84,  ... :Discarded datum European_Terrestrial_Reference_System_1989 in Proj4 definition: +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
#39: In showSRID(uprojargs, format = "PROJ", multiline = "NO",  ... :Discarded datum Unknown based on GRS80 ellipsoid in Proj4 definition
#40: Different files have different X scale factors and are incompatible. The first file has precedence and data were rescaled.
#41: Different files have different Y scale factors and are incompatible. The first file has precedence and data were rescaled.
#42: Different files have different Z scale factors and are incompatible. The first file has precedence and data were rescaled.
#43: There were 391 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#44: There were 2956 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
#45: In getProjectionRef(x, OVERRIDE_PROJ_DATUM_WITH_TOWGS84 = OVERRIDE_PROJ_DATUM_WITH_TOWGS84,  ... :Discarded datum European_Terrestrial_Reference_System_1989 in Proj4 definition: +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
#46: In showSRID(uprojargs, format = "PROJ", multiline = "NO",  ... :Discarded datum Unknown based on GRS80 ellipsoid in Proj4 definition
#47: Different files have different X scale factors and are incompatible. The first file has precedence and data were rescaled.
#48: Different files have different Y scale factors and are incompatible. The first file has precedence and data were rescaled.
#49: Different files have different Z scale factors and are incompatible. The first file has precedence and data were rescaled.
#50: There were 368 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
