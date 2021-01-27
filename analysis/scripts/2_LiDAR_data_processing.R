####################################SHORTCUTS###################################
#list laz files in source folder
laz_files = list.files(paste0(path_data_LiDAR_14),
                       pattern = glob2rx("*.laz"),
                       full.names = TRUE)
                                    ####
#################################TESTS ON 1 LAZ FILE##################################
#read with rlas####
LIDAR_2014_1 <- rlas::read.las(laz_files[1]) 
LIDAR_2014_1
#               X       Y      Z  gpstime       Intensity ReturnNumber NumberOfReturns ScanDirectionFlag EdgeOfFlightline Classification Synthetic_flag Keypoint_flag Withheld_flag ScanAngleRank UserData PointSourceID
#1:        470001.4 5507000 93.148 434508.7       203            1               1                 0                0              2          FALSE         FALSE         FALSE            -7        1          4027
#2:        470001.3 5507000 95.706 434508.7        22            2               3                 0                0             20          FALSE         FALSE         FALSE            -7        1          4027
#3:        470001.0 5507000 93.172 434508.7       118            3               3                 0                0              2          FALSE         FALSE         FALSE            -7        1          4027
#4:        470001.2 5507000 98.305 434508.7        12            1               2                 0                0             20          FALSE         FALSE         FALSE            -7        1          4027
#5:        470000.6 5507000 93.114 434508.7       152            2               2                 0                0              2          FALSE         FALSE         FALSE            -7        1          4027
#---                                                                                                                                                                                                          
#31826911: 470605.1 5507008 91.350 434510.8         9            1               1                 0                0              0          FALSE         FALSE         FALSE            25        1          4027
#31826912: 470582.4 5507198 91.473 435707.4        15            1               1                 0                0              0          FALSE         FALSE         FALSE            15        2          4028
#31826913: 470459.0 5507285 91.359 434512.1        12            1               1                 0                0              0          FALSE         FALSE         FALSE            19        2          4027
#31826914: 470581.9 5507198 91.459 435707.4        13            2               2                 0                0              0          FALSE         FALSE         FALSE            15        2          4028
#31826915: 470403.9 5507108 91.394 434512.1        17            4               4                 0                0              0          FALSE         FALSE         FALSE            15        1          4027

#read with lidR####
LIDR_2014_1 <- lidR::readLAS(laz_files[1])
print(LIDR_2014_1)
#class        : LAS (v1.3 format 1)
#memory       : 2.4 Gb 
#extent       : 470000, 471000, 5507000, 5508000 (xmin, xmax, ymin, ymax)
#coord. ref.  : NA 
#area         : 1 kunits²
#points       : 31.83 million points
#density      : 31.83 points/units²

#assign projection
sp::proj4string(LIDR_2014_1) <- sp::CRS("+init=epsg:25832")

print(LIDR_2014_1)
#class        : LAS (v1.3 format 1)
#memory       : 2.4 Gb 
#extent       : 470000, 471000, 5507000, 5508000 (xmin, xmax, ymin, ymax)
#coord. ref.  : ETRS89 / UTM zone 32N 
#area         : 1 km²
#points       : 31.83 million points
#density      : 31.83 points/m²

summary(LIDR_2014_1)
#class        : LAS (v1.3 format 1)
#memory       : 2.4 Gb 
#extent       : 470000, 471000, 5507000, 5508000 (xmin, xmax, ymin, ymax)
#coord. ref.  : ETRS89 / UTM zone 32N 
#area         : 1 km²
#points       : 31.83 million points
#density      : 31.83 points/m²
#File signature:           LASF 
#File source ID:           0 
#Global encoding:
#- GPS Time Type: GPS Week Time 
#- Synthetic Return Numbers: no 
#- Well Know Text: CRS is GeoTIFF 
#- Aggregate Model: false 
#Project ID - GUID:        00000000-0000-0000-0000-000000000000 
#Version:                  1.3
#System identifier:        LAStools (c) by rapidlasso GmbH 
#Generating software:      las2las (version 160730) 
#File creation d/y:        185/2017
#header size:              235 
#Offset to point data:     235 
#Num. var. length record:  0 
#Point data format:        1 
#Point data record length: 28 
#Num. of point records:    31826915 
#Num. of points by return: 24210684 4389761 2321960 759668 144842 
#Scale factor X Y Z:       0.001 0.001 0.001 
#Offset X Y Z:             470001 5507000 0 
#min X Y Z:                470000 5507000 -70 
#max X Y Z:                471000 5508000 148.385 
#Variable length records:  void

#plot in pointcloud viewer
plot(LIDR_2014_1, bg = "green", color = "Z",colorPalette = terrain.colors(256),backend="pcv")

#LAS stores x,y,z for each point + many other information/attributes and this 
#can take a lot of of memory from the PC
# 'select' enables to choose between attributes/rows 
names(LIDAR_2014_1)
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
#note: when using the filter argument with readLAS, this allows to filter while 
#reading thus saving memory and computation time - it the same as when reading 
#the las file and then filtering the pint cloud

##################################CHECK DATA QUALITY############################
#before getting started it is always good to check the data quality 

lascheck(LIDR_2014_1)
#⚠ 15613462 points are duplicated and share XYZ coordinates with other points
#⚠ There were 11158256 degenerated ground points. Some X Y Z coordinates were repeated
#⚠ There were 49 degenerated ground points. Some X Y coordinates were repeated 
#but with different Z coordinates
#✗ 11972545 pulses (points with the same gpstime) have points with identical ReturnNumber
#⚠ 31826915 points have a non 0 UserData attribute. This probably has a meaning.
#⚠ A proj4string found but no CRS in the header
#- Checking normalization... no
#⚠ 138 points below 0
################################################################################
#########################CLASSIFICATION OF GROUND POINTS########################
#set the number of threads/cores lidR should use
lidR::set_lidr_threads(4)

####PROGRESSIVE MORPHOLOGICAL FILTER####
#based on Zhang et al 2013, but applied to a point cloud 

#read a filtered pointcloud: x,y,z, return number and number of returns
LIDR_2014_11 <- lidR::readLAS(laz_files[1], select = "xyzrn")
print(LIDR_2014_11)
#assign projection
sp::proj4string(LIDR_2014_11) <- sp::CRS("+init=epsg:25832")

#first let's test a first filtering:
LIDR_2014_111 <- classify_ground(LIDR_2014_11, algorithm = pmf(ws = 5, th = 3))
plot(LIDR_2014_111, color = "Classification", size = 3, bg = "white") 

#make a cross section and check the classification results:
point1 <- c(470500, 5507500) #xy  
point2 <- c(471000, 5508000) #xy
las_clipped <- clip_transect(LIDR_2014_111, point1, point2, width = 4, xz = TRUE)
ggplot(las_clipped@data, aes(X,Z, color = Z)) + 
  geom_point(size = 0.5) + 
  coord_equal() + 
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

point3 <- c(4707500, 55077000) #xy  
point4 <- c(471000, 5508000) #xy
las_clipped2 <- clip_transect(LIDR_2014_111, point3, point4, width = 4, xz = TRUE)
ggplot(las_clipped2@data, aes(X,Z, color = Z)) + 
  geom_point(size = 0.5) + 
  coord_equal() + 
  theme_minimal() +
  scale_color_gradientn(colours = height.colors(50))

plot_crossection(las_clipped, colour_by = factor(Classification))

#the filtering is not perfect, let's do : still to test
ws <- seq(3, 12, 3)
th <- seq(0.1, 1.5, length.out = length(ws))
LIDR_2014_1111 <- classify_ground(LIDR_2014_11, algorithm = pmf(ws = ws, th = th))

##################################DTM generation################################
#test
dtm_tin <- grid_terrain(LIDR_2014_111, res = 0.5, algorithm = tin())
plot_dtm3d(dtm_tin, bg = "white") 
#Warning messages:
#1: There were 11550768 degenerated ground points. Some X Y Z coordinates were repeated. They were removed. 
#2: There were 51 degenerated ground points. Some X Y coordinates were repeated 
#but with different Z coordinates. min Z were retained. 


##########################APPLYING TO THE WHOLE DATASET#########################
################################BUILD LAZ CATALOG###############################
#we have multiple LAZ files, so it is best to write them in a catalog

#define projection - EPSG 25832?, ETRS89/UTM 32N
#check projection! 
#proj4_2014 <- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"
#proj4_2018 <- "+proj=utm +zone=32 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"

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
#extent      : 470000, 471000, 5507000, 5614000 (xmin, xmax, ymin, ymax)
#coord. ref. : +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs 
#area        : 14 km²
#points      : 215.23 million points
#density     : 15.4 points/m²
#num. files  : 14 
#proc. opt.  : buffer: 30 | chunk: 0
#input opt.  : select: * | filter: 
#  output opt. : in memory | w2w guaranteed | merging enabled
#drivers     :
# - Raster : format = GTiff  NAflag = -999999  
#- LAS : no parameter
#- Spatial : overwrite = FALSE  
#- SimpleFeature : quiet = TRUE  
#- DataFrame : no parameter

las_check(LIDAR_2014_catalog)
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
#- Checking negative outliers...
#⚠ 7 file(s) with points below 0
#- Checking normalization... no
#Checking the geometry
#- Checking overlapping tiles... ✓
#- Checking point indexation... no

#set variables for the lidR catalog#### 
#chunk sizez in which lidR should process: 14 x 40 = 560
lidR::opt_chunk_size(LIDAR_2014_catalog) <- 560
#lidR::opt_chunk_buffer() -> default: 30 

#enable to overwrite result when processed again
LIDAR_2014_catalog@output_options$drivers$Raster$param$overwrite <- TRUE

# add output filename template
lidR::opt_output_files(LIDAR_2014_catalog) <- paste0(path_normalized,"/{ID}_norm") 

#cloud_metrics(LIDAR_2014_catalog)
