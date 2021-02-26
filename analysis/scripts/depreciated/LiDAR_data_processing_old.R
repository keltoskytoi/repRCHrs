####################################SHORTCUTS###################################
#lslaz <-list.files(file.path(path_data_LiDAR_14), pattern=".laz")

#list laz files 
laz_files = list.files(paste0(path_data_LiDAR_14),
                       pattern = glob2rx("*.laz"),
                       full.names = TRUE)


#################################read las file##################################
#rlas:::lasfilterusage()
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


LASfile <- ("/home/keltoskytoi/R_Projekte/Master_thesis/PIA/REPOSITORY/data/3dm_32470_5610_1_he.laz")
las_Duens = readLAS(LASfile)
#las = duens_las
#plot(las)
las_Duens
print(las_Duens)
#class        : LAS (LASF v1.3)
#point format : 1
#memory       : 1 Gb 
#extent       :470000, 471000, 5610000, 5611000 (xmin, xmax, ymin, ymax)
#coord. ref.  : NA 
#area         : 1 kunits²
#points       : 13.73 million points
#density      : 13.73 points/units²
#names        : X Y Z gpstime Intensity ReturnNumber NumberOfReturns 
#               ScanDirectionFlag EdgeOfFlightline Classification Synthetic_flag 
#               Keypoint_flag Withheld_flag ScanAngleRank UserData PointSourceID

setwd(path_output)
##################test lasground#######################

#Cloth Simulation Filter
las <- lasground(las_Duens, csf())
plot(las, color = "Classification")
dtm_csf = grid_terrain(las, res = 0.5, algorithm = tin ())
writeRaster(dtm_csf, "dtm_csf.tif")

#Progressive morphological Filter

#sequence of window size and threshold height:
ws  <- seq(3,12, 3)
th  <- seq(0.1, 1.5, length.out = length(ws))

las_1 <- lasground(las_Duens, pmf(ws, th))
#plot(las_1, color = "Classification")
dtm_pmf = grid_terrain(las_1, res = 0.5, algorithm = tin ())
writeRaster(dtm_pmf, "dtm_pmf.tif")

#sequence of window size and threshold height:
ws  <- seq(3,3,3)
th  <- seq(0.1, 1.5, length.out = length(ws))

las_2 <- lasground(las_Duens, pmf(ws, th))

dtm_pmf_2 = grid_terrain(las_2, res = 0.5, algorithm = tin ())
writeRaster(dtm_pmf_2, "dtm_pmf_2.tif")

#sequence of window size and threshold height:
ws  <- seq(3,9,3)
th  <- seq(0.1, 1.5, length.out = length(ws))

las_3 <- lasground(las_Duens, pmf(ws, th))

dtm_pmf_3 = grid_terrain(las_3, res = 0.5, algorithm = tin ())
writeRaster(dtm_pmf_3, "dtm_pmf_3.tif")

#sequence of window size and threshold height:
ws  <- seq(3,6,3)
th  <- seq(0.1, 1, length.out = length(ws))

las_4 <- lasground(las_Duens, pmf(ws, th))

dtm_pmf_4 = grid_terrain(las_4, res = 0.5, algorithm = tin ())
writeRaster(dtm_pmf_4, "dtm_pmf_4.tif")

####combined with smoothing ####
las_Duens = readLAS(LASfile)
#sequence of window size and threshold height:
ws  <- seq(3,6,3)
th  <- seq(0.1, 1, length.out = length(ws))

las_4 <- lasground(las_Duens, pmf(ws, th))

lassm <- lassmooth(las_4, 4, "gaussian", "square", sigma = 2)
dtm_pmf_05_smoothed = grid_terrain(lassm, res = 0.5, algorithm = tin ())
writeRaster(dtm_pmf_05_smoothed, "dtm_pmf_05_smoothed.tif")

######testoutsomething######
LASfile <- ("/home/keltoskytoi/R_Projekte/Master_thesis/PIA/REPOSITORY/data/3dm_32470_5610_1_he.laz")
las_Duens = readLAS(LASfile)
#las = lasnormalize(las_Duens, tin())

Duens_ground_csf<- lidR::lasground(las_Duens, csf())
lassm <- lassmooth(Duens_ground_csf, 4, "gaussian", "square", sigma = 2)

dtm_knn = lidR::grid_terrain(Duens_ground_csf, res=0.5,  algorithm = lidR::knnidw(k=50, p=3))
writeRaster(dtm_knn, "dtm_knn.tif")

dtm_tin = lidR::grid_terrain(Duens_ground_csf, res=0.5,  algorithm = lidR::tin())
writeRaster(dtm_tin, "dtm_tin.tif")

dtm_pmf_tin = lidR::grid_terrain(las_4, res=0.5,  algorithm = lidR::tin())
writeRaster(dtm_pmf_tin, "dtm_pmf_tin.tif")

dtm_tin_lassm = lidR::grid_terrain(lassm, res=0.5,  algorithm = lidR::tin())
writeRaster(dtm_tin_lassm, "dtm_tin_lassm.tif")

#compare dtms
plot(dtm_knn - dtm_tin)

#######Filter the Sufracepoints = surface, not good#####
#subset = lasfiltersurfacepoints(las_Duens, 0.5)
#plot(subset)

#####Return Points With Matching Conditions####
# Select the first returns classified as ground
ground = lasfilter(las_Duens, Classification == 2)
plot(ground)
dtm_ground = grid_terrain(ground, res = 0.5, algorithm = tin ())
writeRaster(dtm_ground, "ground_class.tif")

#using gridterrain 
dtm = grid_terrain(las, res = 1, algorithm = tin ())
writeRaster(dtm, "dtm.tif")
plot(dtm)

dtm
#class      : RasterLayer 
#dimensions : 1010, 1010, 1020100  (nrow, ncol, ncell)
#resolution : 1, 1  (x, y)
#extent     : 469995, 471005, 5609995, 5611005  (xmin, xmax, ymin, ymax)
#crs        : +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
#source     : memory
#names      : Z 
#values     : 279.9863, 499.0585  (min, max)

projection(dtm)
#assign a projection 
projection(dtm)<- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 "
dtm <- projectRaster(dtm, crs ="+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 ")
proj4string(dtm)
dtm@crs

#zoom into the tile:
plot(dtm, 
     xlim = c(470200, 470230),
     ylim = c(5610773, 5610795),
     main = "Tile 32470_5610 zoomed in")
dtm

#0.5 resolution
dtm_05 = grid_terrain(las, res = 0.5, algorithm = tin ())
writeRaster(dtm_05, "dtm_05.tif")
plot(dtm_05)

projection(dtm_05)
#assign a projection 
projection(dtm_05)<- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 "
dtm_05 <- projectRaster(dtm_05, crs ="+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 ")
proj4string(dtm_05)
dtm_05@crs

dtm_05

#dtm1 = grid_terrain(las, algorithm = tin ())
#writeRaster(dtm1, "dtm_1.tif")

#dtm2 = grid_terrain(las, algorithm = knnidw(k = 2L, p = 3))
#writeRaster(dtm2, "dtm_4.tif")
#xres(dtm2)
#yres(dtm2)

#############################FIRST STEPS########################################
#Specify the dataframe and test it: Duensberg_4
Duensberg_4 <- read.table("/home/keltoskytoi/R_Projekte/CAA2019/REPOSITORY/data/470000_5610000.xyz")
head(Duensberg_4)
summary(Duensberg_4)

#Transform the dataframe into a spatial object
Duens4 <- raster::rasterFromXYZ(Duensberg_4, res=c(1, 1), crs=sp::CRS("+init=epsg:32632"))
Duens4
raster::setMinMax(Duens4)

#Map the raster to see if it`s in the right position 
pal2 <- colorRampPalette(brewer.pal(12, "Set3"))
mapview::mapviewOptions(mapview.maxpixels = Duens4@ncols*Duens4@nrows/100)
mapview::mapview(Duens4, col.regions = pal2, 
                 at = c(209,234,259,284,309,334,359,384,409,434,459,499), 
                 legend = TRUE)

#############WRITE THE SPATIAL DATAFRAME INTO A RASTER FILE AND CROP IT###############
#Write raster Duens_4
raster::writeRaster(Duens4, paste0(path_data,"Duens_4.tif"), overwrite = TRUE)

Duens_4 <-raster(paste0(path_data,"Duens_4.tif"))
summary(Duens_4)
raster::setMinMax(Duens_4)
extent(Duens_4)
#xmin        : 469999.5 
#xmax        : 475000.5 
#ymin        : 5610000 
#ymax        : 5615000 
#checking the projection of Duens_4
str(Duens_4)
proj4string(Duens_4)
coordinates(Duens_4)
Duens_4@crs
#CRS arguments:
#+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 

##############LOAD DUENS_4 IN GRASS AND COMPUTE A LOCAL RELIEF MODEL#########
################################STEPS 1+2#######################################
# set the environment and specify all the paths necessary to run QGIS from within R  
#Setting up a permanent structure and extension for the project ...
giLinks<-uavRst::linkAll() # saga, grass7, otb, gdal 
require(link2GI)

link2GI::linkGRASS7(x = Duens_4, 
                    gisdbase = "/home/keltoskytoi/R_Projekte/CAA2019/REPOSITORY/GRASS",
                    location = "Init_project",
                    gisdbase_exist = FALSE)  

#Loading/Importing the cropped raster in Grass
rgrass7::execGRASS('r.import', 
                   input= "/home/keltoskytoi/R_Projekte/CAA2019/REPOSITORY/data/Duens_4.tif", 
                   output= "Duens_GRASS.tif",
                   flags=c("overwrite"))

##############CALCULATE A LOCAL RELIEF MODEL FROM THE CROPPED RASTER############ 

rgrass7::execGRASS(cmd = "r.local.relief",
                   flags = "overwrite",
                   input = "Duens_GRASS.tif@PERMANENT",
                   output = "Duens_LRM.tif")

rgrass7::execGRASS(cmd = 'r.out.gdal', 
                   flags=c("m","f", "t","overwrite","verbose"), 
                   input="Duens_LRM.tif@PERMANENT",
                   format="GTiff",
                   type="Float64",
                   output=paste0(path_output,"Duensberg_LRM.tif"))

LRM <- raster(paste0(path_output,"Duensberg_LRM.tif"))
plot(LRM)
raster::setMinMax(LRM)
summary(LRM)

##############CALCULATING DIFFERENT DERIVATIVES OF THE DUENS_4 RASTER###########
################################STEP 3##########################################

#1_Elevation, #2_Slope, Aspect and Curvature, #3_Terrain Ruggedness Index, 
#4_Terrain Surface Convexity, #5_Terrain Surface Classification

setwd(path_derivatives)

#1 = the raster itself 

#Slope 
Duens_4_Slope <- terrain(Duens_4, opt = "slope", unit="radians", neighbors = 8, filename = "Duens_4_Slope.tif")  
Duens_4_Slope_smooth <- terrain(Duens_4, opt = "slope", unit="radians", neighbors = 4, filename = "Duens_4_Slope_sm.tif")  

#Aspect 
Duens_4_Aspect <- terrain(Duens_4, opt = "aspect", unit="degrees", neighbors = 8, filename = "Duens_4_Aspect.tif")
Duens_4_Aspect_sm <- terrain(Duens_4, opt = "aspect", unit="degrees", neighbors = 4, filename = "Duens_4_Aspect_sm.tif")

#TPI
Duens_4_TPI <- terrain(Duens_4, opt = "TPI", neighbors = 8, filename = "Duens_4_TPI.tif")

#TRI
Duens_4_TRI <- terrain(Duens_4, opt = "TRI", neighbors = 8, filename = "Duens_4_TRI.tif")
Duens_4_TRI_detail <- terrain(Duens_4, opt = "TRI", neighbors = 1, filename = "Duens_4_TRI_detail.tif")
#TRI_detail is as calculated with RQGIS = almost the same, just with 1 neighbours around

#Roughness
Duens_4_roughness <- terrain(Duens_4, opt = "roughness", neighbors = 8, filename = "Duens_4_roughness.tif")

#Flowdir
Duens_4_flowdir <- terrain(Duens_4, opt = "flowdir", neighbors = 8, filename = "Duens_4_flowdir.tif")

########################################Working with RQGIS Modules########################################
library(RQGIS)
set_env(dev = FALSE)

#$root
#[1] "/usr"

#$qgis_prefix_path
#[1] "/usr/bin/qgis"

#$python_plugins
#[1] "/usr/share/qgis/python/plugins"

#sets all path necessary to run QGIS from within R 
open_app()

##################Terrain Rugedness Index#################

find_algorithms("TRI", name_only = TRUE)
#[1] "gdalogr:triterrainruggednessindex"

alg = "gdalogr:triterrainruggednessindex"
open_help(alg)
get_usage(alg)
#ALGORITHM: TRI (Terrain Ruggedness Index)
#  INPUT <ParameterRaster>
#  BAND <ParameterNumber>
#  COMPUTE_EDGES <ParameterBoolean>
#  OUTPUT <OutputRaster>

TRI = run_qgis(alg, INPUT = Duens_4, BAND = 1, COMPUTE_EDGES = TRUE,
                 OUTPUT = file.path(tempdir(),"Duens_TRI.tif"),
                 load_output = TRUE)

##############################Working with RSAGA Modules#############################
library(RSAGA)
rsaga.env()

Duens_saga <- write.sgrd(data = Duensberg_4, file = file.path(tempdir(), "Duens_saga"))

rsaga.get.libraries()

rsaga.get.modules(libs = "ta_morphometry")
rsaga.get.usage(lib = "ta_morphometry", module = "Slope, Aspect, Curvature")

rsaga.get.usage(lib = "io_gdal", module = "Import Raster")


#Transform GTIFF to SGRD
rsaga.import.gdal(in.grid = "Duens_4.tif",
                  out.grid = "Duens_4.sgrd")

#Slope, Aspect, Curvature 
rsaga.slope.asp.curv("Duens_4.sgrd", 
                     "slope", 
                     "aspect", 
                     "cgene", 
                     method = "maxslope", 
                     unit.slope = "degrees",
                     unit.aspect = "degrees", 
                     env = rsaga.env())

rsaga.get.usage(lib = "io_gdal", module = "Export Raster")
rsaga.sgrd.to.esri(in.sgrds = "slope.sgrd",
                   out.grids = "Duens4_SAGA_Slope",
                   out.path = "/home/keltoskytoi/R_Projekte/CAA2019/REPOSITORY/derivatives/",
                   format = "ascii")
rsaga.sgrd.to.esri(in.sgrds = "aspect.sgrd",
                   out.grids = "Duens4_SAGA_Aspect",
                   out.path = "/home/keltoskytoi/R_Projekte/CAA2019/REPOSITORY/derivatives/",
                   format = "ascii")
rsaga.sgrd.to.esri(in.sgrds = "cgene.sgrd",
                   out.grids = "Duens4_SAGA_Cgene",
                   out.path = "/home/keltoskytoi/R_Projekte/CAA2019/REPOSITORY/derivatives/",
                   format = "ascii")

#Curvature is almost the same as TPI in the case of Duens_4
saga_aspect <- read.ascii.grid("/home/keltoskytoi/R_Projekte/CAA2019/REPOSITORY/derivatives/Duens4_SAGA_Aspect.asc")
str(saga_aspect)
gdal_translate(saga_aspect, saga_aspect, of = "GTiff",
               tr =c(1,1), r = "nearest", 
               projwin_srs = "+initepsg:32632", output_Raster = TRUE,
               ignore.full_scan = TRUE, verbose = TRUE)
#takes ages and is easier to do in QGIS - 3 clicks, 5seconds calculation time... 
#using only Curvature

############################testing - assigning projections################### 
#Curvature
Duens_Curvature <- raster(paste0(path_output,"Duens4_SAGA_Cgene.tif"))
coordinates(Duens_Curvature)
projection(Duens_Curvature)
#assign a projection 
projection(Duens_Curvature)<- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 "
Duens_4_Curvature <- projectRaster(Duens_Curvature, 
                                   crs ="+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 ")
proj4string(Duens_4_Curvature)
Duens_4_Curvature@crs
plot(Duens_4_Curvature)
raster::writeRaster(Duens_4_Curvature, paste0(path_run,"Duens_4_Curvature.tif"), overwrite = TRUE)

########################Derivatives from the RVToolbox########################
setwd(path_output)
#Hillshade
HS_10_3 <- raster(paste0(path_output,"470000_5610000_HS_A10_H3.tif"))
projection(HS_10_3)
#assign a projection 
projection(HS_10_3)<- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 "
Duens_4_HS_10_3 <- projectRaster(HS_10_3, 
                                 crs ="+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 ")
proj4string(Duens_4_HS_10_3)
Duens_4_HS_10_3@crs
plot(Duens_4_HS_10_3)
raster::writeRaster(Duens_4_HS_10_3, paste0(path_run,"Duens_4_HS_10_3.tif"), overwrite = TRUE)

#MultiHS
MULTI_HS_D16_H10 <-raster(paste0(path_output, "470000_5610000_MULTI-HS_D16_H10.tif"))
projection(MULTI_HS_D16_H10)
#assign a projection 
projection(MULTI_HS_D16_H10)<- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 "
Duens_4_MULTI_HS_D16_H10 <- projectRaster(MULTI_HS_D16_H10, 
                                          crs ="+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 ")
proj4string(Duens_4_MULTI_HS_D16_H10)
Duens_4_MULTI_HS_D16_H10@crs
plot(Duens_4_MULTI_HS_D16_H10)
raster::writeRaster(Duens_4_MULTI_HS_D16_H10, paste0(path_run,"Duens_4_MULTI_HS_D16_H10.tif"), overwrite = TRUE)

#OPEN-NEG
OPEN_NEG_R5_D32 <-raster(paste0(path_output, "470000_5610000_OPEN-NEG_R5_D32_NRstrong.tif"))
projection(OPEN_NEG_R5_D32)
#assign a projection 
projection(OPEN_NEG_R5_D32)<- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 "
Duens_4_OPEN_NEG_R5_D32 <- projectRaster(OPEN_NEG_R5_D32, 
                                         crs ="+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 ")
proj4string(Duens_4_OPEN_NEG_R5_D32)
Duens_4_OPEN_NEG_R5_D32@crs
plot(Duens_4_OPEN_NEG_R5_D32)
raster::writeRaster(Duens_4_OPEN_NEG_R5_D32, paste0(path_run,"Duens_4_OPEN-NEG_R5_D32.tif"), overwrite = TRUE)

#OPEN-POS
OPEN_POS_R5_D32 <-raster(paste0(path_output, "470000_5610000_OPEN-POS_R5_D32_NRstrong.tif"))
projection(OPEN_POS_R5_D32)
#assign a projection 
projection(OPEN_POS_R5_D32)<- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 "
Duens_4_OPEN_POS_R5_D32 <- projectRaster(OPEN_POS_R5_D32, 
                                         crs ="+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 ")
proj4string(Duens_4_OPEN_POS_R5_D32)
Duens_4_OPEN_POS_R5_D32@crs
plot(Duens_4_OPEN_POS_R5_D32)
raster::writeRaster(Duens_4_OPEN_POS_R5_D32, paste0(path_run,"Duens_4_OPEN-POS_R5_D32.tif"), overwrite = TRUE)

#PCA
PCA_D16_H10 <-raster(paste0(path_output, "470000_5610000_PCA_D16_H10.tif"))
projection(PCA_D16_H10)
#assign a projection 
projection(PCA_D16_H10)<- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 "
Duens_4_PCA_D16_H10 <- projectRaster(PCA_D16_H10, 
                                     crs ="+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 ")
proj4string(Duens_4_PCA_D16_H10)
Duens_4_PCA_D16_H10@crs
plot(Duens_4_PCA_D16_H10)
raster::writeRaster(Duens_4_PCA_D16_H10, paste0(path_run,"Duens_4_PCA_D16_H10.tif"), overwrite = TRUE)

#SIM
SIM <-raster(paste0(path_output, "470000_5610000_SIM_overcast_500sp_100px.tif"))
projection(SIM)
#assign a projection 
projection(SIM)<- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 "
Duens_4_SIM <- projectRaster(SIM, 
               crs ="+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 ")
proj4string(Duens_4_SIM)
Duens_4_SIM@crs
plot(Duens_4_SIM)
raster::writeRaster(Duens_4_SIM, paste0(path_run,"Duens_4_SIM.tif"), overwrite = TRUE)

#ASVF 
SVF_A_R5_D32_A315 <-raster(paste0(path_output, "470000_5610000_SVF-A_R5_D32_A315_AIstrong_NRstrong.tif"))
projection(SVF_A_R5_D32_A315)
#assign a projection 
projection(SVF_A_R5_D32_A315)<- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 "
Duens_4_SVF_A_R5_D32_A315 <- projectRaster(SVF_A_R5_D32_A315, 
                             crs ="+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 ")
proj4string(Duens_4_SVF_A_R5_D32_A315)
Duens_4_SVF_A_R5_D32_A315@crs
plot(Duens_4_SVF_A_R5_D32_A315)
raster::writeRaster(Duens_4_SVF_A_R5_D32_A315, paste0(path_run,"Duens_4_SVF-A_R5_D32_A315.tif"), overwrite = TRUE)

#SVF 
SVF_R5_D32_A315 <-raster(paste0(path_output, "470000_5610000_SVF_R5_D32_NRstrong.tif"))
projection(SVF_R5_D32_A315)
#assign a projection 
projection(SVF_R5_D32_A315)<- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 "
Duens_4_SVF_R5_D32_A315 <- projectRaster(SVF_R5_D32_A315, 
                                           crs ="+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 ")
proj4string(Duens_4_SVF_R5_D32_A315)
Duens_4_SVF_R5_D32_A315@crs
plot(Duens_4_SVF_R5_D32_A315)
raster::writeRaster(Duens_4_SVF_R5_D32_A315, paste0(path_run,"Duens_4_SVF-R5_D32_A315.tif"), overwrite = TRUE)

#Local Dominance 
LD <- raster(paste0(path_output,"470000_5610000_LD_R_M10-20_DI1_A15_OH1.7.tif"))
projection(LD)
#assign a projection 
projection(LD)<- "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 "
Duens_LD_R_M10_20_DI1_A15 <- projectRaster(LD, 
                                 crs ="+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 ")
proj4string(Duens_LD_R_M10_20_DI1_A15)
Duens_LD_R_M10_20_DI1_A15@crs
plot(Duens_LD_R_M10_20_DI1_A15)
raster::writeRaster(Duens_LD_R_M10_20_DI1_A15, paste0(path_run,"Duens_LD_R_M10_20_DI1_A15.tif"), overwrite = TRUE)
