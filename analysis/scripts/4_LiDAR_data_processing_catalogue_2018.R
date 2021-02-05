####################################SHORTCUTS###################################
#Because the the Lidar data from 2014 is appr. 8 BG and that from 2018 appr.
#150 GBs, it had to be moved outside of the project and also partitioned if not
#the Computer would stopf after few tiles because they are 4x the size of the
#2014 tiles

lsLIDAR18a <- list.files(("E:/REPO/LiDAR_18/Lidar/a"),
                        pattern = glob2rx("*.las"),
                        full.names = TRUE)

lsLIDAR18b <- list.files(("E:/REPO/LiDAR_18/Lidar/b"),
                         pattern = glob2rx("*.las"),
                         full.names = TRUE)

lsLIDAR18c <- list.files(("E:/REPO/LiDAR_18/Lidar/c"),
                         pattern = glob2rx("*.las"),
                         full.names = TRUE)

lsLIDAR18d <- list.files(("E:/REPO/LiDAR_18/Lidar/d"),
                         pattern = glob2rx("*.las"),
                         full.names = TRUE)

lsLIDAR18e <- list.files(("E:/REPO/LiDAR_18/Lidar/e"),
                         pattern = glob2rx("*.las"),
                         full.names = TRUE)

lsLIDAR18f <- list.files(("E:/REPO/LiDAR_18/Lidar/f"),
                         pattern = glob2rx("*.las"),
                         full.names = TRUE)

lsLIDAR18g <- list.files(("E:/REPO/LiDAR_18/Lidar/g"),
                         pattern = glob2rx("*.las"),
                         full.names = TRUE)

lsLIDAR18h <- list.files(("E:/REPO/LiDAR_18/Lidar/h"),
                         pattern = glob2rx("*.las"),
                         full.names = TRUE)

lsLIDAR18i <- list.files(("E:/REPO/LiDAR_18/Lidar/i"),
                         pattern = glob2rx("*.las"),
                         full.names = TRUE)


##########################APPLICATION TO THE WHOLE DATASET#########################
################################BUILD A LAZ CATALOG###############################
#we have multiple LAZ files, so it is best to write them in a catalog

#define projection - EPSG 25832 ETRS89/UTM 32N
#check projection!

#check tile size####
LIDR_2018_1 <- lidR::readLAS(lsLIDAR18a[1])
sp::proj4string(LIDR_2018_1) <- sp::CRS("+init=epsg:25832")
print(LIDR_2018_1)
#class        : LAS (v1.3 format 1)
#memory       : 6.2 Gb
#extent       : 478000, 480000, 5616000, 5618000 (xmin, xmax, ymin, ymax)
#coord. ref.  : ETRS89 / UTM zone 32N
#area         : 4 km²
#points       : 82.97 million points
#density      : 20.74 points/m²

#LIDAR_2018_catalog_a####
LIDAR_2018_catalog_a <-  lidR::readLAScatalog(lsLIDAR18a, select = "xyzirnc", filter ="keep_class 2")
#set the projection of the lidR catalog
sp::proj4string(LIDAR_2018_catalog_a) <- sp::CRS("+init=epsg:25832")

#summary of the catalog
summary(LIDAR_2018_catalog_a)
#class       : LAScatalog (v1.3 format 1)
#extent      : 478000, 480000, 5616000, 5626000 (xmin, xmax, ymin, ymax)
#coord. ref. : ETRS89 / UTM zone 32N
#area        : 20 km²
#points      : 497.3million points
#density     : 24.9 points/m²
#num. files  : 5
#proc. opt.  : buffer: 30 | chunk: 0
#input opt.  : select: xyzirnc | filter: keep_class 2
#output opt. : in memory | w2w guaranteed | merging enabled
#drivers     :
#- Raster : format = GTiff  NAflag = -999999
#- LAS : no parameter
#- Spatial : overwrite = FALSE
#- SimpleFeature : quiet = TRUE
#- DataFrame : no parameter

lidR::las_check(LIDAR_2018_catalog_a)
#Checking headers consistency
#- Checking file version consistency... ✓
#- Checking scale consistency... ✓
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

#LIDAR_2018_catalog_b####
LIDAR_2018_catalog_b <-  lidR::readLAScatalog(lsLIDAR18b, select = "xyzirnc", filter ="keep_class 2")
#set the projection of the lidR catalog
sp::proj4string(LIDAR_2018_catalog_b) <- sp::CRS("+init=epsg:25832")

#summary of the catalog
summary(LIDAR_2018_catalog_b)
#class       : LAScatalog (v1.3 format 1)
#extent      : 478000, 482000, 5616000, 5634000 (xmin, xmax, ymin, ymax)
#coord. ref. : ETRS89 / UTM zone 32N
#area        : 20 km²
#points      : 603.17million points
#density     : 30.2 points/m²
#num. files  : 5
#proc. opt.  : buffer: 30 | chunk: 0
#input opt.  : select: xyzirnc | filter: keep_class 2
#output opt. : in memory | w2w guaranteed | merging enabled
#drivers     :
#- Raster : format = GTiff  NAflag = -999999
#- LAS : no parameter
#- Spatial : overwrite = FALSE
#- SimpleFeature : quiet = TRUE
#- DataFrame : no parameter


#plot the chunks#####
#a####
plot(LIDAR_2018_catalog_a, chunk = TRUE)
plot(LIDAR_2018_catalog_a, mapview = TRUE, map.type = "Esri.WorldImagery")
#check outliers:
spplot(LIDAR_2018_catalog_a, "Min.Z")
#b####
plot(LIDAR_2018_catalog_b, chunk = TRUE)
plot(LIDAR_2018_catalog_b, mapview = TRUE, map.type = "Esri.WorldImagery")
#check outliers:
spplot(LIDAR_2018_catalog_b, "Min.Z")




#paralellize the work####
future::plan(multisession, workers = 2L)
#set the number of threads lidR should use
lidR::set_lidr_threads(4)


#create a function
process_bigdata <- function(LIDAR_2014_catalog_b){
  opt_output_files(LIDAR_2014_catalog_b) <- paste0(path_analysis_data_dtm2018b, "/{*}_xyzirnc_ground_IDW01")
  LIDAR_2018_catalog_b@output_options$drivers$Raster$param$overwrite <- TRUE
  lidR::opt_chunk_buffer(LIDAR_2018_catalog_b) <- 50
  dtm_2018 <- grid_terrain(LIDAR_2018_catalog_b, 1, res=0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
  return(dtm_2018)
}

process_bigdata(LIDAR_2018_catalog_b)

