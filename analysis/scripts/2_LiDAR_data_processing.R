####################################SHORTCUTS###################################
#Because the the Lidar data from 2014 is appr. 8 BG and that from 2018 appr.
#150 GBs, it had to be moved outside of the project.
lsLIDAR14 <- list.files(("E:/REPO/LiDAR_14"),
                        pattern = glob2rx("*.laz"),
                        full.names = TRUE)

lsLIDAR18 <- list.files(("E:/REPO/LiDAR_18/Lidar"),
                        pattern = glob2rx("*.las"),
                        full.names = TRUE)

###############################TESTS ON 1 LAZ FILE##############################
###############################READ 1 LAZ FILE##################################
#read with rlas####
LIDAR_2014_1 <- rlas::read.las(lsLIDAR14[1])
LIDAR_2014_1
#       X       Y      Z      gpstime           Intensity ReturnNumber NumberOfReturns ScanDirectionFlag EdgeOfFlightline Classification Synthetic_flag Keypoint_flag Withheld_flag ScanAngleRank UserData PointSourceID
#1: 478000.4 5616942 190.86 139821.0               63            1               1                 0                0              2          FALSE         FALSE         FALSE           120        0           518
#2: 478000.9 5616942 190.86 139821.0               59            1               1                 0                0              2          FALSE         FALSE         FALSE           120        0           518
#3: 478001.3 5616941 190.82 139821.0               56            1               1                 0                0              2          FALSE         FALSE         FALSE           120        0           518
#4: 478000.3 5616941 190.86 139821.0               66            1               1                 0                0              2          FALSE         FALSE         FALSE           120        0           518
#5: 478001.7 5616940 190.76 139821.0               61            1               1                 0                0              2          FALSE         FALSE         FALSE           120        0           518
#---
#10227000: 478629.6 5616719 170.79 144503.0        18            1               1                 0                0              1          FALSE         FALSE         FALSE            79        0           560
#10227001: 478630.3 5616719 170.75 144503.0       159            1               1                 0                0              1          FALSE         FALSE         FALSE            79        0           560
#10227002: 478626.5 5616720 170.85 144503.1        35            1               1                 0                0              1          FALSE         FALSE         FALSE            80        0           560
#10227003: 478627.2 5616720 170.88 144503.1        46            1               1                 0                0              1          FALSE         FALSE         FALSE            80        0           560
#10227004: 478627.9 5616720 170.74 144503.1        16            1               2                 0                0              1          FALSE         FALSE         FALSE            79        0           560


#read with lidR####
LIDR_2014_1 <- lidR::readLAS(lsLIDAR14[1])
#Warnmeldung:
#Invalid data: ScanAngleRank greater than 90 degrees
print(LIDR_2014_1)
#class        : LAS (v1.3 format 1)
#memory       : 780.3 Mb
#extent       : 478000, 479000, 5616000, 5617000 (xmin, xmax, ymin, ymax)
#coord. ref.  : NA
#area         : 1 kunits²
#points       : 10.23 million points
#density      : 10.23 points/units²

#assign projection
sp::proj4string(LIDR_2014_1) <- sp::CRS("+init=epsg:25832")

print(LIDR_2014_1)
#class        : LAS (v1.3 format 1)
#memory       : 780.3 Mb
#extent       : 478000, 479000, 5616000, 5617000 (xmin, xmax, ymin, ymax)
#coord. ref.  : ETRS89 / UTM zone 32N
#area         : 1 km²
#points       : 10.23 million points
#density      : 10.23 points/m²

summary(LIDR_2014_1)
#class        : LAS (v1.3 format 1)
#memory       : 780.3 Mb
#extent       : 478000, 479000, 5616000, 5617000 (xmin, xmax, ymin, ymax)
#coord. ref.  : ETRS89 / UTM zone 32N
#area         : 1 km²
#points       : 10.23 million points
#density      : 10.23 points/m²
#File signature:           LASF
#File source ID:           0
#Global encoding:
#- GPS Time Type: GPS Week Time
#- Synthetic Return Numbers: no
#- Well Know Text: CRS is GeoTIFF
#- Aggregate Model: false
# ID - GUID:        00000000-0000-0000-0000-000000000000
#Version:                  1.3
#System identifier:        LAStools (c) by rapidlasso GmbH
#Generating software:      lasmerge (version 161114)
#File creation d/y:        122/2016
#header size:              235
#Offset to point data:     235
#Num. var. length record:  0
#Point data format:        1
#Point data record length: 28
#Num. of point records:    10227004
#Num. of points by return: 8999985 949108 240884 34535 2423
#Scale factor X Y Z:       0.001 0.001 0.001
#Offset X Y Z:             478000 5616942 100
#min X Y Z:                478000 5616000 166
#max X Y Z:                479000 5617000 264.9
#Variable length records:  void

#plot in pointcloud viewer
#plot(LIDR_2014_1, bg = "green", color = "Z",colorPalette = terrain.colors(256),backend="pcv")

##################################CHECK DATA QUALITY############################
#before getting started it is always good to check the data quality

lascheck(LIDR_2014_1)
#⚠ 402 points are duplicated and share XYZ coordinates with other points
#⚠ There were 370 degenerated ground points. Some X Y Z coordinates were repeated.
#⚠ There were 2247 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates.
#⚠ 'ScanDirectionFlag' attribute is not populated.
#⚠ A proj4string found but no CRS in the header.
#- Checking normalization... no

################################################################################
#########################CLASSIFICATION OF GROUND POINTS########################
#set the number of threads/cores lidR should use
getDTthreads() #4
lidR::set_lidr_threads(4)

#selecting and filtering the pointcloud####

#LAS stores x,y,z for each point + many other information=attributes and this
#can take a lot of of memory from the PC

# 'select' enables to choose between attributes/rows
names(LIDR_2014_1@data)
#[1] "X"                 "Y"                 "Z"                 "gpstime"
#[5] "Intensity"         "ReturnNumber"      "NumberOfReturns"   "ScanDirectionFlag"
#[9] "EdgeOfFlightline"  "Classification"    "Synthetic_flag"    "Keypoint_flag"
#[13] "Withheld_flag"     "ScanAngleRank"     "UserData"          "PointSourceID"
#queries are: t - gpstime, a - scan angle, i - intensity, n - number of returns,
#r - return number, c - classification, s - synthetic flag, k - keypoint flag,
#w - withheld flag, o - overlap flag (format 6+), u - user data, p - point source ID,
#e - edge of flight line flag, d - direction of scan flag
#default is xyz

#'filter' enables to choose between the rows/points; the filter options can be
#accessed by: read.las(filter = "-help")

#note: when using the select and filter arguments with readLAS, this allows to filter while
#reading the file thus saving memory and computation time - it the same as when reading
#the las file and then filtering the pint cloud

                    ####USING THE POINT CLASSIFICATIONS####

LIDAR_2014_1_ground <- lidR::readLAS(lsLIDAR14[1], select = "xyzrnc", filter ="keep_class 2")

dtm_2014_1_ground_tin05 <- grid_terrain(LIDAR_2014_1_ground, res = 0.1, algorithm = tin())
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2247 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
print(dtm_2014_1_ground_tin05)
#assign projection
sp::proj4string(dtm_2014_1_ground_tin05) <- sp::CRS("+init=epsg:25832")
raster::writeRaster(dtm_2014_1_ground_tin05, paste0(path_tests, "test_dtm_2014_1_ground_tin05.tif"), overwrite = TRUE)
crs(LIDA)

               ####PROGRESSIVE MORPHOLOGICAL FILTER####
#based on Zhang et al 2013, but applied to a point cloud

#read a selected pointcloud: x,y,z, return number and number of returns, classification
LIDR_2014_11 <- lidR::readLAS(lsLIDAR14[1], select = "xyzrnc")
print(LIDR_2014_11)
#assign projection
sp::proj4string(LIDR_2014_11) <- sp::CRS("+init=epsg:25832")
crs(LIDR_2014_11) #+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs

print(LIDR_2014_11)
#class        : LAS (v1.3 format 1)
#memory       : 312.1 Mb
#extent       : 478000, 479000, 5616000, 5617000 (xmin, xmax, ymin, ymax)
#coord. ref.  : ETRS89 / UTM zone 32N
#area         : 1 km²
#points       : 10.23 million points
#density      : 10.23 points/m²

#first let's test a first morphological filter:
LIDR_2014_1_pmf <- classify_ground(LIDR_2014_11, algorithm = pmf(ws = 5, th = 3))
plot(LIDR_2014_1_pmf, color = "Classification", size = 3, bg = "white")

#make a cross section and check the classification results:
point1 <- c(478000, 5616000) #xy
point2 <- c(4785000, 5616500) #xy
las_clipped <- clip_transect(LIDR_2014_11_pmf, point1, point2, width = 4, xz = TRUE)
ggplot(las_clipped@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

point3 <- c(478500, 5616500) #xy
point4 <- c(479000, 5617000) #xy
las_clipped2 <- clip_transect(LIDR_2014_11_pmf, point3, point4, width = 4, xz = TRUE)
ggplot(las_clipped2@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(las_clipped, colour_by = factor(Classification))
plot_crossection(las_clipped2, colour_by = factor(Classification))

#if the filtering is not perfect, let's do:
ws <- seq(3, 12, 3)
th <- seq(0.1, 1.5, length.out = length(ws))
LIDR_2014_1_pmf_seq <- classify_ground(LIDR_2014_11, algorithm = pmf(ws = ws, th = th))

las_clipped3 <- clip_transect(LIDR_2014_1_pmf_seq, point1, point2, width = 4, xz = TRUE)
ggplot(LIDR_2014_1_pmf_seq@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

las_clipped4 <- clip_transect(LIDR_2014_1_pmf_seq, point3, point4, width = 4, xz = TRUE)
ggplot(LIDR_2014_1_pmf_seq@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

                          ####CLOTH SIMULATION FUNCTION####
testcsf <- csf(sloop_smooth = TRUE, class_threshold = 1, cloth_resolution = 1, time_step = 1)
LIDR_2014_1_csf <- classify_ground(LIDR_2014_11, testcsf)
plot(LIDR_2014_1_csf, color = "Classification", size = 3, bg = "white")
plot_crossection(LIDR_2014_1_csf, p1 = point1, p2 = point2, colour_by = factor(Classification))


##################################DTM GENERAtion################################
#Triangular Irregular Network (TIN)####
dtm_tin05 <- grid_terrain(LIDR_2014_1_pmf, res = 0.5, algorithm = tin())
#Warning messages:
#1: There were 389 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2614 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
plot_dtm3d(dtm_tin05, bg = "white")
crs(dtm_tin05)
#CRS arguments:
#+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
print(dtm_tin05)
raster::writeRaster(dtm_tin05, paste0(path_REPO_LidR_tes, "test_2014_1_tin_05.tif"), overwrite = TRUE)

dtm_tin02 <- grid_terrain(LIDR_2014_1_pmf, res = 0.2, algorithm = tin())
#Warning messages:
#1: There were 389 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2614 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
plot_dtm3d(dtm_tin02, bg = "white")
crs(dtm_tin02)
#CRS arguments:
#+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
print(dtm_tin02)
raster::writeRaster(dtm_tin02, paste0(path_REPO_LidR_tes, "test_2014_1_tin_02.tif"), overwrite = TRUE)

dtm_tin01 <- grid_terrain(LIDR_2014_1_pmf, res = 0.1, algorithm = tin())
#Warning messages:
#1: There were 389 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2614 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
plot_dtm3d(dtm_tin01, bg = "white")
crs(dtm_tin01)
#CRS arguments:
#+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
print(dtm_tin01)
raster::writeRaster(dtm_tin01, paste0(path_REPO_LidR_tes, "test_2014_1_tin_01.tif"), overwrite = TRUE)

dtm_tin001 <- grid_terrain(LIDR_2014_1_pmf, res = 0.01, algorithm = tin())
#Fehler: kann Vektor der Größe 37.3 GB nicht allozieren
#Warning messages:
#1: There were 389 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2614 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.
plot_dtm3d(dtm_tin01, bg = "white")
crs(dtm_tin01)
#CRS arguments:
#+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
print(dtm_tin01)
raster::writeRaster(dtm_tin01, paste0(path_REPO_LidR_tes, "test_2014_1_tin_01.tif"), overwrite = TRUE)

#Invert Distance Weighting####
dtm_idw <- grid_terrain(las, algorithm = knnidw(k = 10L, p = 2))
plot_dtm3d(dtm_idw, bg = "white")

#Kriging####
dtm_kriging <- grid_terrain(las, algorithm = kriging(k = 40))
plot_dtm3d(dtm_kriging, bg = "white")

##########################APPLICATION TO THE WHOLE DATASET#########################
################################BUILD A LAZ CATALOG###############################
#we have multiple LAZ files, so it is best to write them in a catalog

#define projection - EPSG 25832 ETRS89/UTM 32N
#check projection!

LIDAR_2014_catalog <-  lidR::readLAScatalog(laz_files)
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
#input opt.  : select: * | filter:
#  output opt. : in memory | w2w guaranteed | merging enabled
#drivers     :
#  - Raster : format = GTiff  NAflag = -999999
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

#set variables for the lidR catalog####
#chunk size in which lidR should process: 14 x 40 = 560
lidR::opt_chunk_size(LIDAR_2014_catalog) <- 560
#lidR::opt_chunk_buffer() -> default: 30

#enable to overwrite result when processed again
LIDAR_2014_catalog@output_options$drivers$Raster$param$overwrite <- TRUE

# add output filename template
lidR::opt_output_files(LIDAR_2014_catalog) <- paste0(path_normalized,"/{ID}_norm")

#cloud_metrics(LIDAR_2014_catalog)
