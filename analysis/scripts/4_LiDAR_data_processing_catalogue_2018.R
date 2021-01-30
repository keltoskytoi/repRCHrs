####################################SHORTCUTS###################################
#Because the the Lidar data from 2014 is appr. 8 BG and that from 2018 appr.
#150 GBs, it had to be moved outside of the project.

lsLIDAR18 <- list.files(("E:/REPO/LiDAR_18/Lidar"),
                        pattern = glob2rx("*.las"),
                        full.names = TRUE)

##########################APPLICATION TO THE WHOLE DATASET#########################
################################BUILD A LAZ CATALOG###############################
#we have multiple LAZ files, so it is best to write them in a catalog

#define projection - EPSG 25832 ETRS89/UTM 32N
#check projection!

LIDAR_2018_catalog <-  lidR::readLAScatalog(lsLIDAR18)
#set the projection of the lidR catalog
sp::proj4string(LIDAR_2018_catalog) <- sp::CRS("+init=epsg:25832")
#paralellize the work
future::plan(multisession, workers = 2L)
#set the number of threads lidR should use
lidR::set_lidr_threads(4)

#summary of the catalog
summary(LIDAR_2018_catalog)
#class       : LAScatalog (v1.3 format 1)
#extent      : 478000, 488000, 5616000, 5634000 (xmin, xmax, ymin, ymax)
#coord. ref. : ETRS89 / UTM zone 32N
#area        : 180 km²
#points      : 5.73billion points
#density     : 31.8 points/m²
#num. files  : 45
#proc. opt.  : buffer: 30 | chunk: 0
#input opt.  : select: * | filter:
#  output opt. : in memory | w2w guaranteed | merging enabled
#drivers     :
# - Raster : format = GTiff  NAflag = -999999
#- LAS : no parameter
#- Spatial : overwrite = FALSE
#- SimpleFeature : quiet = TRUE
#- DataFrame : no parameter

plot(LIDAR_2018_catalog)
plot(LIDAR_2018_catalog, mapview = TRUE, map.type = "Esri.WorldImagery")
