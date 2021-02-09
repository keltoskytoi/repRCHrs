####################################SHORTCUTS###################################
#Because the the Lidar data from 2014 is appr. 8 BG and that from 2018 appr.
#150 GBs, it had to be moved outside of the project and also partitioned if not
#the Computer would stop after few tiles because they are 4x the size of the
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

#LIDAR_2018_catalog_c####
LIDAR_2018_catalog_c <-  lidR::readLAScatalog(lsLIDAR18c, select = "xyzirnc", filter ="keep_class 2")
#set the projection of the lidR catalog
sp::proj4string(LIDAR_2018_catalog_c) <- sp::CRS("+init=epsg:25832")

#summary of the catalog
summary(LIDAR_2018_catalog_c)
#class       : LAScatalog (v1.3 format 1)
#extent      : 480000, 482000, 5618000, 5628000 (xmin, xmax, ymin, ymax)
#coord. ref. : ETRS89 / UTM zone 32N
#area        : 20 km²
#points      : 641.11million points
#density     : 32.1 points/m²
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

#LIDAR_2018_catalog_d####
LIDAR_2018_catalog_d <-  lidR::readLAScatalog(lsLIDAR18d, select = "xyzirnc", filter ="keep_class 2")
#set the projection of the lidR catalog
sp::proj4string(LIDAR_2018_catalog_d) <- sp::CRS("+init=epsg:25832")

#summary of the catalog
summary(LIDAR_2018_catalog_d)
#class       : LAScatalog (v1.3 format 1)
#extent      : 480000, 484000, 5616000, 5634000 (xmin, xmax, ymin, ymax)
#coord. ref. : ETRS89 / UTM zone 32N
#area        : 20 km²
#points      : 747.25million points
#density     : 37.4 points/m²
#num. files  : 5
#proc. opt.  : buffer: 30 | chunk: 0
#input opt.  : select: xyzirnc | filter: keep_class 2
#output opt. : in memory | w2w guaranteed | merging enabled
#drivers     :
# - Raster : format = GTiff  NAflag = -999999
#- LAS : no parameter
#- Spatial : overwrite = FALSE
#- SimpleFeature : quiet = TRUE
#- DataFrame : no parameter

#LIDAR_2018_catalog_e####
LIDAR_2018_catalog_e <-  lidR::readLAScatalog(lsLIDAR18e, select = "xyzirnc", filter ="keep_class 2")
#set the projection of the lidR catalog
sp::proj4string(LIDAR_2018_catalog_e) <- sp::CRS("+init=epsg:25832")

#summary of the catalog
summary(LIDAR_2018_catalog_e)
#class       : LAScatalog (v1.3 format 1)
#extent      : 482000, 484000, 5620000, 5630000 (xmin, xmax, ymin, ymax)
#coord. ref. : ETRS89 / UTM zone 32N
#area        : 20 km²
#points      : 684.99million points
#density     : 34.2 points/m²
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

#LIDAR_2018_catalog_f####
LIDAR_2018_catalog_f <-  lidR::readLAScatalog(lsLIDAR18f, select = "xyzirnc", filter ="keep_class 2")
#set the projection of the lidR catalog
sp::proj4string(LIDAR_2018_catalog_f) <- sp::CRS("+init=epsg:25832")

#summary of the catalog
summary(LIDAR_2018_catalog_f)
#class       : LAScatalog (v1.3 format 1)
#extent      : 482000, 486000, 5616000, 5634000 (xmin, xmax, ymin, ymax)
#coord. ref. : ETRS89 / UTM zone 32N
#area        : 20 km²
#points      : 607.95million points
#density     : 30.4 points/m²
#num. files  : 5
#proc. opt.  : buffer: 30 | chunk: 0
#input opt.  : select: xyzirnc | filter: keep_class 2
#output opt. : in memory | w2w guaranteed | merging enabled
#drivers     :
# - Raster : format = GTiff  NAflag = -999999
#- LAS : no parameter
#- Spatial : overwrite = FALSE
#- SimpleFeature : quiet = TRUE
#- DataFrame : no parameter

#LIDAR_2018_catalog_g####
LIDAR_2018_catalog_g <-  lidR::readLAScatalog(lsLIDAR18g, select = "xyzirnc", filter ="keep_class 2")
#set the projection of the lidR catalog
sp::proj4string(LIDAR_2018_catalog_g) <- sp::CRS("+init=epsg:25832")

#summary of the catalog
summary(LIDAR_2018_catalog_g)
##class       : LAScatalog (v1.3 format 1)
#extent      : 482000, 486000, 5616000, 5634000 (xmin, xmax, ymin, ymax)
#coord. ref. : ETRS89 / UTM zone 32N
#area        : 20 km²
#points      : 607.95million points
#density     : 30.4 points/m²
#num. files  : 5
#proc. opt.  : buffer: 30 | chunk: 0
#input opt.  : select: xyzirnc | filter: keep_class 2
#output opt. : in memory | w2w guaranteed | merging enabled
#drivers     :
# - Raster : format = GTiff  NAflag = -999999
#- LAS : no parameter
#- Spatial : overwrite = FALSE
#- SimpleFeature : quiet = TRUE
#- DataFrame : no parameter

#LIDAR_2018_catalog_h####
LIDAR_2018_catalog_h <-  lidR::readLAScatalog(lsLIDAR18h, select = "xyzirnc", filter ="keep_class 2")
#set the projection of the lidR catalog
sp::proj4string(LIDAR_2018_catalog_h) <- sp::CRS("+init=epsg:25832")

#summary of the catalog
summary(LIDAR_2018_catalog_h)
#class       : LAScatalog (v1.3 format 1)
#extent      : 484000, 488000, 5616000, 5634000 (xmin, xmax, ymin, ymax)
#coord. ref. : ETRS89 / UTM zone 32N
#area        : 20 km²
#points      : 533.3million points
#density     : 26.7 points/m²
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

#LIDAR_2018_catalog_i####
LIDAR_2018_catalog_i <-  lidR::readLAScatalog(lsLIDAR18i, select = "xyzirnc", filter ="keep_class 2")
#set the projection of the lidR catalog
sp::proj4string(LIDAR_2018_catalog_i) <- sp::CRS("+init=epsg:25832")

#summary of the catalog
summary(LIDAR_2018_catalog_i)
#class       : LAScatalog (v1.3 format 1)
#extent      : 486000, 488000, 5624000, 5634000 (xmin, xmax, ymin, ymax)
#coord. ref. : ETRS89 / UTM zone 32N
#area        : 20 km²
#points      : 582.3million points
#density     : 29.1 points/m²
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

#c####
plot(LIDAR_2018_catalog_c, chunk = TRUE)
plot(LIDAR_2018_catalog_c, mapview = TRUE, map.type = "Esri.WorldImagery")
#check outliers:
spplot(LIDAR_2018_catalog_c, "Min.Z")

#d####
plot(LIDAR_2018_catalog_d, chunk = TRUE)
plot(LIDAR_2018_catalog_d, mapview = TRUE, map.type = "Esri.WorldImagery")
#check outliers:
spplot(LIDAR_2018_catalog_d, "Min.Z")

#e####
plot(LIDAR_2018_catalog_e, chunk = TRUE)
plot(LIDAR_2018_catalog_e, mapview = TRUE, map.type = "Esri.WorldImagery")
#check outliers:
spplot(LIDAR_2018_catalog_e, "Min.Z")

#f####
plot(LIDAR_2018_catalog_f, chunk = TRUE)
plot(LIDAR_2018_catalog_f, mapview = TRUE, map.type = "Esri.WorldImagery")
#check outliers:
spplot(LIDAR_2018_catalog_f, "Min.Z")

#g####
plot(LIDAR_2018_catalog_g, chunk = TRUE)
plot(LIDAR_2018_catalog_g, mapview = TRUE, map.type = "Esri.WorldImagery")
#check outliers:
spplot(LIDAR_2018_catalog_g, "Min.Z")

#h####
plot(LIDAR_2018_catalog_h, chunk = TRUE)
plot(LIDAR_2018_catalog_h, mapview = TRUE, map.type = "Esri.WorldImagery")
#check outliers:
spplot(LIDAR_2018_catalog_h, "Min.Z")

#i####
plot(LIDAR_2018_catalog_i, chunk = TRUE)
plot(LIDAR_2018_catalog_i, mapview = TRUE, map.type = "Esri.WorldImagery")
#check outliers:
spplot(LIDAR_2018_catalog_i, "Min.Z")

#paralellize the work####
future::plan(multisession, workers = 2L)
#set the number of threads lidR should use
lidR::set_lidr_threads(4)

#set variables and create a function

LIDAR_2018_catalog <- LIDAR_2018_catalog_i
opt_output_files(LIDAR_2018_catalog) <- paste0(path_analysis_data_dtm2018i, "/{*}_xyzirnc_ground_IDW01")

process_bigdata <- function(LIDAR_2018_catalog)
{
  LIDAR_2018_catalog@output_options$drivers$Raster$param$overwrite <- TRUE
  lidR::opt_chunk_buffer(LIDAR_2018_catalog) <- 50
  dtm_2018 <- grid_terrain(LIDAR_2018_catalog, 1, res=0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
  return(dtm_2018)
}
process_bigdata(LIDAR_2018_catalog)

#computing missing tiles because of errors####
#An error occurred when processing the chunk 3. Try to load this chunk with:
#chunk <- readRDS("C:\Users\solo\AppData\Local\Temp\Rtmp6XRY7s/chunk3.rds")
#las <- readLAS(chunk)
#kann Vektor der Größe 95.4 MB nicht allozieren

#lsLIDAR18g[3]####
#[3] "E:/REPO/LiDAR_18/Lidar/g/LIDAR_4840-5626_las1-3.las"

LIDR_2018_4840_5626 <- lidR::readLAS(lsLIDAR18g[3])
#Warnmeldungen:
#1: Invalid data: 52 points with a return number equal to 0 found.
#2: Invalid data: 52 points with a number of returns equal to 0 found.
print(LIDR_2018_4840_5626)
#class        : LAS (v1.3 format 1)
#memory       : 11.8 Gb
#extent       : 484000, 486000, 5626000, 5628000 (xmin, xmax, ymin, ymax)
#coord. ref.  : NA
#area         : 4 kunits²
#points       : 157.91 million points
#density      : 39.48 points/units²

#assign projection#####
sp::proj4string(LIDR_2018_4840_5626) <- sp::CRS("+init=epsg:25832")

LIDR_2018_4840_5626_ground_idw01 <- lidR::grid_terrain(LIDR_2018_4840_5626, res= 0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
raster::writeRaster(LIDR_2018_4840_5626_ground_idw01, paste0(path_analysis_data_dtm2018g,
                                                             "LIDAR_4840-5626_las1-3_xyzirnc_ground_IDW01.tif"),
                                                              format = "GTiff", overwrite = TRUE)

#lsLIDAR18i[3]####
#[3] "E:/REPO/LiDAR_18/Lidar/g/LIDAR_4840-5626_las1-3.las"

LIDR_2018_4860_5630 <- lidR::readLAS(lsLIDAR18i[4])
#Warnmeldungen:
#1: Invalid data: 52 points with a return number equal to 0 found.
#2: Invalid data: 52 points with a number of returns equal to 0 found.
print(LIDR_2018_4860_5630)
#class        : LAS (v1.3 format 1)
#memory       : 10.3 Gb
#extent       : 486000, 488000, 5630000, 5632000 (xmin, xmax, ymin, ymax)
#coord. ref.  : NA
#area         : 4 kunits²
#points       : 137.65 million points
#density      : 34.41 points/units²

#assign projection#####
sp::proj4string(LIDR_2018_4860_5630) <- sp::CRS("+init=epsg:25832")

LIDR_2018_4860_5630_ground_idw01 <- lidR::grid_terrain(LIDR_2018_4860_5630, res= 0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
raster::writeRaster(LIDR_2018_4860_5630_ground_idw01, paste0(path_analysis_data_dtm2018i,
                                                             "LIDAR_4860_5630_las1-3_xyzirnc_ground_IDW01.tif"),
                                                              format = "GTiff", overwrite = TRUE)
