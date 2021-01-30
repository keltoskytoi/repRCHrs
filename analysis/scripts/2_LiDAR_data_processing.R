####################################SHORTCUTS###################################
#Because the the Lidar data from 2014 is appr. 8 BG and that from 2018 appr.
#150 GBs, it had to be moved outside of the project.
lsLIDAR14 <- list.files(("E:/REPO/LiDAR_14"),
                        pattern = glob2rx("*.laz"),
                        full.names = TRUE)

lsDTMs <- list.files(("E:/REPO/LidR_test"),
                        pattern = glob2rx("*.tif"),
                        full.names = TRUE)

#define points for cross section:
point1 <- c(478000, 5616000) #xy
point2 <- c(478500, 5616500) #xy
point3 <- c(478500, 5616500) #xy
point4 <- c(479000, 5617000) #xy

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

#assign projection#####
sp::proj4string(LIDR_2014_1) <- sp::CRS("+init=epsg:25832")

print(LIDR_2014_1)
#class        : LAS (v1.3 format 1)
#memory       : 780.3 Mb
#extent       : 478000, 479000, 5616000, 5617000 (xmin, xmax, ymin, ymax)
#coord. ref.  : ETRS89 / UTM zone 32N
#area         : 1 km²
#points       : 10.23 million points
#density      : 10.23 points/m²

#summary####
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

#check data quality####
#before getting started it is always good to check the data quality

las_check(LIDR_2014_1)
#⚠ 402 points are duplicated and share XYZ coordinates with other points
#⚠ There were 370 degenerated ground points. Some X Y Z coordinates were repeated.
#⚠ There were 2247 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates.
#⚠ 'ScanDirectionFlag' attribute is not populated.
#⚠ A proj4string found but no CRS in the header.
#- Checking normalization... no

################################################################################
#########################(RE)CLASSIFICATION OF GROUND POINTS########################
#set the number of threads/cores lidR should use
getDTthreads() #6
lidR::set_lidr_threads(4)

#get to know the pointcloud####

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

#read a selected pointcloud: x,y,z, return number and number of returns, intensity, classification
LIDR_2014_1_xyzirnc <- lidR::readLAS(lsLIDAR14[1], select = "xyzirnc")

print(LIDR_2014_1_xyzirnc) #no CRS

#assign projection
sp::proj4string(LIDR_2014_1_xyzirnc) <- sp::CRS("+init=epsg:25832")
crs(LIDR_2014_1_xyzirnc) #+proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs

print(LIDR_2014_1_xyzirnc)

                    ####USING POINT CLASSIFICATION####
LIDR_2014_1_ground <- lidR::readLAS(lsLIDAR14[1], select = "xyzirnc", filter ="keep_class 2")

print(LIDR_2014_1_ground)
#class        : LAS (v1.3 format 1)
#memory       : 429.2 Mb
#extent       : 478000, 479000, 5616000, 5617000 (xmin, xmax, ymin, ymax)
#coord. ref.  : NA
#area         : 1 kunits²
#points       : 10.23 million points
#density      : 10.23 points/units²

#assign projection
sp::proj4string(LIDR_2014_1_ground) <- sp::CRS("+init=epsg:25832")


                ####PROGRESSIVE MORPHOLOGICAL FILTER####
          #based on Zhang et al 2013, but applied to a point cloud

#first let's test a simple morphological filter (see LidRbook)####
LIDR_2014_1_xyzirnc_pmf <- lidR::classify_ground(LIDR_2014_1_xyzirnc, algorithm = pmf(ws = 5, th = 3))
#Original dataset already contains 7718079 ground points. These points were
#reclassified as 'unclassified' before performing a new ground classification.

#plot(LIDR_2014_1_xyzirnc_pmf, color = "Classification", size = 3, bg = "white")

#make a cross section and check the classification results:
LIDR_2014_1_xyzirnc_pmf_clipped <- clip_transect(LIDR_2014_1_xyzirnc_pmf, point1, point2, width = 4, xz = TRUE)
ggplot(LIDR_2014_1_xyzirnc_pmf_clipped@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

LIDR_2014_1_xyzirnc_pmf_clipped2 <- clip_transect(LIDR_2014_1_xyzirnc_pmf, point3, point4, width = 4, xz = TRUE)
ggplot(LIDR_2014_1_xyzirnc_pmf_clipped2@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(LIDR_2014_1_xyzirnc_pmf_clipped, colour_by = factor(Classification))
plot_crossection(LIDR_2014_1_xyzirnc_pmf_clipped2, colour_by = factor(Classification))

#what about using a sequence####
ws <- seq(3, 12, 3)
th <- seq(0.1, 1.5, length.out = length(ws))
LIDR_2014_1_xyzirnc_pmf_seq <- lidR::classify_ground(LIDR_2014_1_xyzirnc, algorithm = pmf(ws = ws, th = th))
#Original dataset already contains 7718079 ground points. These points were
#reclassified as 'unclassified' before performing a new ground classification.

LIDR_2014_1_xyzirnc_pmf_seq_clipped3 <- clip_transect(LIDR_2014_1_xyzirnc_pmf_seq, point1, point2, width = 4, xz = TRUE)
ggplot(LIDR_2014_1_xyzirnc_pmf_seq_clipped3@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

LIDR_2014_1_xyzirnc_pmf_seq_clipped4 <- clip_transect(LIDR_2014_1_xyzirnc_pmf_seq, point3, point4, width = 4, xz = TRUE)
ggplot(LIDR_2014_1_xyzirnc_pmf_seq_clipped4@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(LIDR_2014_1_xyzirnc_pmf_seq_clipped3, colour_by = factor(Classification))
plot_crossection(LIDR_2014_1_xyzirnc_pmf_seq_clipped4, colour_by = factor(Classification))
#it did not classify all ground points

                          ####CLOTH SIMULATION FUNCTION####
                            #based on Zhang et al 2016
#default settings of csf####
LIDR_2014_1_xyzirnc_csf <- lidR::classify_ground(LIDR_2014_1_xyzirnc, algorithm = csf())
#Original dataset already contains 7718079 ground points. These points were
#reclassified as 'unclassified' before performing a new ground classification

#plot(LIDR_2014_1_xyzirnc_csf, color = "Classification", size = 3, bg = "white")

#make a cross section and check the classification results:
LIDR_2014_1_xyzirnc_csf_clipped <- clip_transect(LIDR_2014_1_xyzirnc_csf, point1, point2, width = 4, xz = TRUE)
ggplot(LIDR_2014_1_xyzirnc_csf_clipped@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

LIDR_2014_1_xyzirnc_csf_clipped2 <- clip_transect(LIDR_2014_1_xyzirnc_csf, point3, point4, width = 4, xz = TRUE)
ggplot(LIDR_2014_1_xyzirnc_csf_clipped2@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(LIDR_2014_1_xyzirnc_csf_clipped, colour_by = factor(Classification))
plot_crossection(LIDR_2014_1_xyzirnc_csf_clipped2, colour_by = factor(Classification))

#settings of csf from LidRbook - even though it looks good, a check if it can be made better!####
csf_1 <- csf(sloop_smooth = TRUE, class_threshold = 1, cloth_resolution = 1, time_step = 1)
LIDR_2014_1_xyzirnc_csf2 <- lidR::classify_ground(LIDR_2014_1_xyzirnc, csf_1)

#plot(LIDR_2014_1_xyzirnc_csf2, color = "Classification", size = 3, bg = "white")

#make a cross section and check the classification results:
LIDR_2014_1_xyzirnc_csf2_clipped <- clip_transect(LIDR_2014_1_xyzirnc_csf2, point1, point2, width = 4, xz = TRUE)
ggplot(LIDR_2014_1_xyzirnc_csf2_clipped@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

LIDR_2014_1_xyzirnc_csf2_clipped2 <- clip_transect(LIDR_2014_1_xyzirnc_csf2, point3, point4, width = 4, xz = TRUE)
ggplot(LIDR_2014_1_xyzirnc_csf2_clipped2@data, aes(X,Z, color = Z)) +
  geom_point(size = 0.5) +
  coord_equal() +
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(LIDR_2014_1_xyzirnc_csf2_clipped, colour_by = factor(Classification))
plot_crossection(LIDR_2014_1_xyzirnc_csf2_clipped2, colour_by = factor(Classification))
#it does not seem to make such a big difference!

##################################DTM GENERAtion################################
#the classified point clouds, which are found to be useful:####
LIDR_2014_1_ground
LIDR_2014_1_xyzirnc_pmf
LIDR_2014_1_xyzirnc_csf

#one question is still lingering around: which resolution should be used?
#well, because quite huge data sets are going to be used, the tiles should not be too big
#in the following different resolutions have been computed and even if one thrives to
#work with VHR resolution, the question is: is it worth it? do we see more of a 3 m
#object in a 5 cm resolution image than in a 10 cm one? For comparison:
#a 5 cm resolution DTM is 1 GB
#a 10 cm resolution raster is 300 MB
#in the 2014 data set there are 209 tiles (~ 8 GB)
#in the 2018 data set are 45 tiles (~ 160 GB)

                 ###Triangular Irregular Network (TIN)####

#using the point classification####
#0.1m####
LIDR_2014_1_ground_tin01 <- lidR::grid_terrain(LIDR_2014_1_ground, res = 0.1, algorithm = tin())
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2247 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_2014_1_ground_tin01)
#class      : RasterLayer
#dimensions : 10000, 10000, 1e+08  (nrow, ncol, ncell)
#resolution : 0.1, 0.1  (x, y)
#extent     : 478000, 479000, 5616000, 5617000  (xmin, xmax, ymin, ymax)
#crs        : +proj=utm +zone=32 +ellps=GRS80 +units=m +no_defs
#source     : memory
#names      : Z
#values     : 166.088, 237.402  (min, max)

#write/export as raster
raster::writeRaster(LIDR_2014_1_ground_tin01, file.path(path_tests,
                                                       "dtm_2014_1_xyzirnc_ground_tin_01.tif"),
                                                       format = "GTiff", overwrite = TRUE)
#0.05m####
LIDR_2014_1_ground_tin005 <- lidR::grid_terrain(LIDR_2014_1_ground, res = 0.05, algorithm = tin())
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2247 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_2014_1_ground_tin005)

#write/export as raster
raster::writeRaster(LIDR_2014_1_ground_tin005, file.path(path_tests,
                                                       "dtm_2014_1_xyzirnc_ground_tin_005.tif"),
                                                       format = "GTiff", overwrite = TRUE)


#0.1m with

#Progressive Morphological Filter####
#0.5 m####
LIDR_2014_1_xyzirnc_pmf_tin05 <- lidR::grid_terrain(LIDR_2014_1_xyzirnc_pmf, res = 0.5, algorithm = tin())
#Warning messages:
#1: There were 389 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2614 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_2014_1_xyzirnc_pmf_tin05)

#write/export as raster
raster::writeRaster(LIDR_2014_1_xyzirnc_pmf_tin05, paste0(path_tests,
                                                          "dtm_2014_1_xyzirnc_1_pmf_tin_05.tif"),
                                                          format = "GTiff", overwrite = TRUE)

#0.2 m####
LIDR_2014_1_xyzirnc_pmf_tin02 <- lidR::grid_terrain(LIDR_2014_1_xyzirnc_pmf, res = 0.2, algorithm = tin())
#Warning messages:
#1: There were 389 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2614 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_2014_1_xyzirnc_pmf_tin02)

#write/export as raster
raster::writeRaster(LIDR_2014_1_xyzirnc_pmf_tin02, paste0(path_tests, "dtm_2014_1_xyzirnc_pmf_tin_02.tif"), overwrite = TRUE)

#0.1 m####
LIDR_2014_1_xyzirnc_pmf_tin01 <- lidR::grid_terrain(LIDR_2014_1_xyzirnc_pmf, res = 0.1, algorithm = tin())
#Warning messages:
#1: There were 389 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2614 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_2014_1_xyzirnc_pmf_tin01)

#write/export as raster
raster::writeRaster(LIDR_2014_1_xyzirnc_pmf_tin01, paste0(path_tests, "dtm_2014_1_xyzirnc_pmf_tin_01.tif"), overwrite = TRUE)

#0.05m####
LIDR_2014_1_xyzirnc_pmf_dtm_tin005 <- lidR::grid_terrain(LIDR_2014_1_xyzirnc_pmf, res = 0.05, algorithm = tin())
#1: There were 389 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2614 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_2014_1_xyzirnc_pmf_dtm_tin005)

#write/export as raster
raster::writeRaster(LIDR_2014_1_xyzirnc_pmf_dtm_tin005, paste0(path_tests, "dtm_2014_1_xyzirnc_pmf_tin_005.tif"), overwrite = TRUE)


#Cloth Simulation Function####
LIDR_2014_1_xyzirnc_csf_tin01 <- lidR::grid_terrain(LIDR_2014_1_xyzirnc_csf, res = 0.1, algorithm = tin())
#Warning messages:
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2262 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_2014_1_xyzirnc_csf_tin01)

#write/export as raster
raster::writeRaster(LIDR_2014_1_xyzirnc_csf_tin01, paste0(path_tests, "dtm_2014_1_xyzirnc_csf_tin_01.tif"), overwrite = TRUE)

                     ###Invert Distance Weighting####
#using the point classification####
#0.1 + default settings####
LIDR_2014_1_ground_idw01 <- lidR::grid_terrain(LIDR_2014_1_ground, res= 0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2247 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_2014_1_ground_idw01)

#write/export as raster
raster::writeRaster(LIDR_2014_1_ground_idw01, paste0(path_tests,
                                                     "dtm_2014_1_xyzirnc_ground_idw_01.tif"),
                                                      format = "GTiff", overwrite = TRUE)

#0.1 with setting from Chris####
LIDR_2014_1_ground_idw01_2 <- lidR::grid_terrain(LIDR_2014_1_ground, res= 0.1, algorithm = knnidw(k = 50L, p = 3))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2247 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_2014_1_ground_idw01_2)

#write/export as raster
raster::writeRaster(LIDR_2014_1_ground_idw01_2, paste0(path_tests,
                                                       "dtm_2014_1_xyzirnc_ground_idw_01_2.tif"),
                                                       format = "GTiff", overwrite = TRUE)

#0.1 with half of the default settings####
LIDR_2014_1_ground_idw01_3 <- lidR::grid_terrain(LIDR_2014_1_ground, res=0.1, algorithm = knnidw(k = 5L, p = 2, rmax = 25))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2262 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_2014_1_ground_idw01_3)

#write/export as raster
raster::writeRaster(LIDR_2014_1_ground_idw01_3, paste0(path_tests,
                                                       "dtm_2014_1_xyzirnc_ground_idw_01_3.tif"),
                                                       format = "GTiff", overwrite = TRUE)

#0.1 + changes default settings####
LIDR_2014_1_ground_idw01_4 <- lidR::grid_terrain(LIDR_2014_1_ground, res=0.1, algorithm = knnidw(k = 20L, p = 2, rmax = 50))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2262 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_2014_1_ground_idw01_4)

#write/export as raster
raster::writeRaster(LIDR_2014_1_ground_idw01_4, paste0(path_tests,
                                                       "dtm_2014_1_xyzirnc_ground_idw_01_4.tif"),
                                                       format = "GTiff", overwrite = TRUE)

#0.1 + changes default settings####
LIDR_2014_1_ground_idw01_5 <- lidR::grid_terrain(LIDR_2014_1_ground, res=0.1, algorithm = knnidw(k = 20L, p = 3, rmax = 50))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2262 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_2014_1_ground_idw01_5)

#write/export as raster
raster::writeRaster(LIDR_2014_1_ground_idw01_5, paste0(path_tests,
                                                       "dtm_2014_1_xyzirnc_ground_idw_01_5.tif"),
                                                       format = "GTiff", overwrite = TRUE)


#Progressive Morphological Filter####
#0.1 + default settings
LIDR_2014_1_xyzirnc_pmf_idw01 <- lidR::grid_terrain(LIDR_2014_1_xyzirnc_pmf, res=0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
#1: There were 389 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2614 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_2014_1_xyzirnc_pmf_idw01)

#write/export as raster
raster::writeRaster(LIDR_2014_1_xyzirnc_pmf_idw01, paste0(path_tests,
                                                          "dtm_2014_1_xyzirnc_pmf_idw_01.tif"),
                                                           format = "GTiff", overwrite = TRUE)
#Cloth Simulation Function####

#0.1 + default settings####
LIDR_2014_1_xyzirnc_csf_idw01 <- lidR::grid_terrain(LIDR_2014_1_xyzirnc_csf, res=0.1, algorithm = knnidw(k = 10L, p = 2, rmax = 50))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2262 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_2014_1_xyzirnc_csf_idw01)

#write/export as raster
raster::writeRaster(LIDR_2014_1_xyzirnc_csf_idw01, paste0(path_tests,
                                                          "dtm_2014_1_xyzirnc_csf_idw_01.tif"),
                                                           format = "GTiff", overwrite = TRUE)

#0.1 with setting from Chris####
LIDR_2014_1_xyzirnc_csf_idw01_2 <- lidR::grid_terrain(LIDR_2014_1_xyzirnc_csf, res=0.1, algorithm = knnidw(k = 50L, p = 3))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2262 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_2014_1_xyzirnc_csf_idw01_2)

#write/export as raster
raster::writeRaster(LIDR_2014_1_xyzirnc_csf_idw01_2, paste0(path_tests,
                                                            "dtm_2014_1_xyzirnc_csf_idw_01_2.tif"),
                                                            format = "GTiff", overwrite = TRUE)

#0.1 with half of the default settings####
LIDR_2014_1_xyzirnc_csf_idw01_3 <- lidR::grid_terrain(LIDR_2014_1_xyzirnc_csf, res=0.1, algorithm = knnidw(k = 5L, p = 2, rmax = 25))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2262 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_2014_1_xyzirnc_csf_idw01_3)

#write/export as raster
raster::writeRaster(LIDR_2014_1_xyzirnc_csf_idw01_3, paste0(path_tests,
                                                            "dtm_2014_1_xyzirnc_csf_idw_01_3.tif"),
                                                            format = "GTiff", overwrite = TRUE)

#0.1 + changes default settings
LIDR_2014_1_xyzirnc_csf_idw01_4 <- grid_terrain(LIDR_2014_1_xyzirnc_csf, res=0.1, algorithm = knnidw(k = 20L, p = 2, rmax = 50))
#1: There were 370 degenerated ground points. Some X Y Z coordinates were repeated. They were removed.
#2: There were 2262 degenerated ground points. Some X Y coordinates were repeated but with different Z coordinates. min Z were retained.

#check raster
print(LIDR_2014_1_xyzirnc_csf_idw01_4)

#write/export as raster
raster::writeRaster(LIDR_2014_1_xyzirnc_csf_idw01_4, paste0(path_tests,
                                                            "dtm_2014_1_xyzirnc_csf_idw_01_4.tif"),
                                                            format = "GTiff", overwrite = TRUE)




                          ####Kriging####
#way tooo slow ATM
#using the point classification####
LIDR_2014_1_ground_krig01 <- lidR::grid_terrain(LIDR_2014_1_ground, res= 0.1, algorithm = kriging())
#

#check raster
print(LIDR_2014_1_ground_krig01)

#write/export as raster
raster::writeRaster(LIDR_2014_1_ground_krig01, paste0(path_tests,
                                                     "dtm_2014_1_ground_krig_01.tif"),
                                                      format = "GTiff", overwrite = TRUE)

#Progressive Morphological Filter####
LIDR_2014_1_xyzirnc_pmf_krig01 <- lidR::grid_terrain(LIDR_2014_1_xyzirnc_pmf, res=0.1, algorithm = kriging())
#

#check raster
print(LIDR_2014_1_xyzirnc_pmf_krig01)

#write/export as raster
raster::writeRaster(LIDR_2014_1_xyzirnc_pmf_krig01, paste0(path_tests,
                                                           "dtm_2014_1_xyzirnc_pmf_krig_01.tif"),
                                                            format = "GTiff", overwrite = TRUE)

#Cloth Simulation Function####
LIDR_2014_1_xyzirnc_csf_krig01 <- lidR::grid_terrain(LIDR_2014_1_xyzirnc_csf, res=0.1, algorithm = kriging())
#

#check raster
print(LIDR_2014_1_xyzirnc_csf_krig01)

#write/export as raster
raster::writeRaster(LIDR_2014_1_xyzirnc_csf_krig01, paste0(path_tests,
                                                           "dtm_2014_1_xyzirnc_csf_krig_01.tif"),
                                                           format = "GTiff", overwrite = TRUE)


                 ####Comparing the DTM results####


#The test DTMs have been compared visually in QGIS. Keeping the aim of this thesis:
#the terrain should be as accurate as possible BUT there should be as minimal
#disturbances and artifacts/noise in the texture of the terrain as possible not to compete
#with the archaeological objects to be detected. Thus the existing ground
#classification, the pmf and csf was compared with TIN and IDW interpolation and
#it has been found that the ground classification + IDW gives the smoothest surface.
#Kriging is taking way too long and DTM generation is only a tool not the aim of
#this thesis.

#comparisions####
summary(LIDR_2014_1_ground_tin01 - LIDR_2014_1_ground_idw01)
#layer
#Min.    -3.594
#1st Qu. -0.006
#Median   0.000
#3rd Qu.  0.006
#Max.     3.061
#NA's    25.000

summary(LIDR_2014_1_ground_idw01_3 - LIDR_2014_1_ground_idw01)
#layer
#Min.    -2.339
#1st Qu. -0.002
#Median   0.000
#3rd Qu.  0.002
#Max.     2.276
#NA's    25.000

summary(LIDR_2014_1_ground_idw01_5 - LIDR_2014_1_ground_idw01_4)
layer
#Min.    -1.009
#1st Qu. -0.003
#Median   0.000
#3rd Qu.  0.003
#Max.     0.712
#NA's    25.000
