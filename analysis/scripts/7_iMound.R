################## THE WORKFLOW IS FIRST TESTED ONly ON 1 TILE##################
####################################SHORTCUTS###################################
lstestarea <-  list.files(file.path(path_analysis_data_dtm2014_TEST_AREA), pattern = ".tif")
lsoutput <- list.files(file.path(path_analysis_data_dtm2014_iMound), pattern = ".tif")

lstestarea
#[1] "E:/repRCHrs//analysis/data/dtm2014/TEST_AREA/3dm_32482_5616_1_he_xyzirnc_ground_IDW01.tif"
#[2] "E:/repRCHrs//analysis/data/dtm2014/TEST_AREA/3dm_32482_5617_1_he_xyzirnc_ground_IDW01.tif"
#[3] "E:/repRCHrs//analysis/data/dtm2014/TEST_AREA/3dm_32482_5618_1_he_xyzirnc_ground_IDW01.tif"
#[4] "E:/repRCHrs//analysis/data/dtm2014/TEST_AREA/3dm_32482_5619_1_he_xyzirnc_ground_IDW01.tif"
#[5] "E:/repRCHrs//analysis/data/dtm2014/TEST_AREA/3dm_32483_5616_1_he_xyzirnc_ground_IDW01.tif"
################################################################################

###################################1. read DTM##################################
testdtm <- raster(paste0(path_analysis_data_dtm2014_TEST_AREA, lstestarea[[3]]))
mapview(testdtm)
plot(testdtm)
crs(testdtm)
#CRS arguments:
#+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
################################################################################
###############################2. filter DTM  mean/low pass#####################
#let's use a 3x3 moving window
testdtm_mean <- raster::focal(testdtm, w=matrix(1/(3*3)), fun=mean, na.rm=FALSE)
mapview(testdtm_mean)
plot(testdtm_mean)
crs(testdtm_mean)
################################################################################
#################################3.invert the filtered DTM######################
#spatialEco::raster.invert Inverts raster values using the formula: (((x - max(x)) * -1) + min(x)
itDTMm <- spatialEco::raster.invert(testdtm_mean)
################################################################################
#####################4.pit filling of inverse filtered DTM############
#Freeland et al. 2016 & Rom et al. use Wang and Liu 2006, which is implemented in Whitebox GAT & SAGA
#link to SAGA
saga<-linkSAGA(ver_select = TRUE)
env<-RSAGA::rsaga.env(path = saga$sagaPath)

#Module Fill Sinks (Wang & Liu)
minslope = 0
raster::writeRaster(itDTMm, filename=paste0(file.path(path_tmp),"/itDTMm.sdat"),overwrite = TRUE, NAflag = 0)
RSAGA::rsaga.geoprocessor(lib = "ta_preprocessor", module = 4,
                          param = list(ELEV =    paste(path_tmp,"/itDTMm.sgrd", sep = ""),
                                       WSHED =   paste(path_tmp,"/wshed.sgrd", sep = ""),
                                       FDIR =    paste(path_tmp,"/fdir.sgrd", sep = ""),
                                       FILLED =  paste(path_tmp,"/filled_dem.sgrd", sep = ""),
                                       MINSLOPE = minslope))

filled_dtm <- raster::raster(file.path(path_tmp, "filled_dem.sdat"))
raster::writeRaster(filled_dtm, filename=paste0(file.path(path_analysis_data_dtm2014_iMound),"/filled_dtm_W&L.tif"), overwrite = TRUE, NAflag = 0)

crs(filled_dtm) <- crs(testdtm)
filled_dtm





#also in R
filled_dtm_R <- SinkFill(itDTMm)
DEM_with_sink <- s.map$DEM_original
DEM_sinkfilled <- SinkFill( DEM_with_sink )
DEM_nosink <- DEM_sinkfilled$nosink
partitions <- DEM_sinkfilled$partition
## Check maps
par(mfrow=c(2,2))
plot(DEM_with_sink)
plot(DEM_nosink)
plot(DEM_with_sink - DEM_nosink)
plot(partitions)





#5.inverse DTM - pit-filled DTM####
poss_mound_layer_1 <- itDTMm - filled_dtm
raster::writeRaster(poss_mound_layer_1, filename=paste0(file.path(path_analysis_data_dtm2014_iMound),"/poss_mound_layer_1.tif"), overwrite = TRUE, NAflag = 0)


#6. thresholds for height, and area?
poss_mound_layer_1
#class      : RasterLayer
#dimensions : 10000, 10000, 1e+08  (nrow, ncol, ncell)
#resolution : 0.1, 0.1  (x, y)
#extent     : 482000, 483000, 5618000, 5619000  (xmin, xmax, ymin, ymax)
#crs        : +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
#source     : memory
#names      : layer
#values     : -0.1355563, 8.477105e-07  (min, max)

plot(poss_mound_layer_1)
hist(poss_mound_layer_1,
     main="Distribution of inverse mound heights",
     xlab="inverse mound height (m)",
     col="cadetblue4")

#here are a lot of values that == 0 or less. let’s set those to NA and plot again

poss_mound_layer_1[poss_mound_layer_1 <= 0] <- NA
hist(poss_mound_layer_1,
     main="Distribution of inverse mound heights (pixels <= 0 NA)",
     xlab="inverse mound height (m)",
     col="cadetblue4")

plot(poss_mound_layer_1)

poss_mound_layer_1_stats_min <- cellStats(poss_mound_layer_1, min)
#2.119276e-07
poss_mound_layer_1_stats_max <- cellStats(poss_mound_layer_1, max)
#8.477105e-07

#reclassify raster 3
pp <- quantile(poss_mound_layer_1, c(0, 0.15, 0.30, 0.45, 0.60, 0.85, 1))
pp
#          0%           15%           30%           45%           60%           85%          100%
#2.119276e-07 2.119276e-07 4.238553e-07 4.238553e-07 6.357829e-07 8.477105e-07 8.477105e-07
pp1 <-quantile(poss_mound_layer_1, c(0, 0.30, 1))
#          0%           15%          100%
#-1.355563e-01 -8.477105e-07  8.477105e-07

ix <- findInterval(getValues(poss_mound_layer_1), pp)
ix2 <-findInterval(getValues(poss_mound_layer_1), pp1)

classified_poss_mound_layer_1 <- setValues(poss_mound_layer_1, ix)
classified_poss_mound_layer_2 <- setValues(poss_mound_layer_1, ix2)

poss_mound_layer_1
#class      : RasterLayer
#dimensions : 10000, 10000, 1e+08  (nrow, ncol, ncell)
#resolution : 0.1, 0.1  (x, y)
#extent     : 482000, 483000, 5618000, 5619000  (xmin, xmax, ymin, ymax)
#crs        : +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
#source     : memory
#names      : layer
#values     : -0.1355563, 8.477105e-07  (min, max)

classified_poss_mound_layer_1
#class      : RasterLayer
#dimensions : 10000, 10000, 1e+08  (nrow, ncol, ncell)
#resolution : 0.1, 0.1  (x, y)
#extent     : 482000, 483000, 5618000, 5619000  (xmin, xmax, ymin, ymax)
#crs        : +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
#source     : memory
#names      : layer
#values     : 1, 7  (min, max)

classified_poss_mound_layer_2
#class      : RasterLayer
#dimensions : 10000, 10000, 1e+08  (nrow, ncol, ncell)
#resolution : 0.1, 0.1  (x, y)
#extent     : 482000, 483000, 5618000, 5619000  (xmin, xmax, ymin, ymax)
#crs        : +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
#source     : memory
#names      : layer
#values     : 1, 3  (min, max)

plot(classified_poss_mound_layer_1)

col <- c("red", "green", "white")
plot(classified_poss_mound_layer_2, col = col)





#reclassify raster 2
mound_layerm <- c(0, poss_mound_layer_1_stats_max ,4)
mound_layerm.m <- matrix(mound_layerm, ncol=1, byrow=TRUE)
mound_layer_reclass <- reclassify(poss_mound_layer_1, mound_layerm.m)

plot(mound_layer_reclass)

#reclassify raster 1
reclass_poss_mound_layer_1 <- c( 8.477105e-07, - 0.04, NA,
                                -0.04, - 0.07, 1,
                                - 0.07, - 0.1355563, 2)
reclass_poss_mound_layer_1
reclass_poss_mound_layer_1.m <- matrix(reclass_poss_mound_layer_1,
                                       ncol=3,
                                       byrow=TRUE)
reclass_poss_mound_layer_1.m

#reclassify the raster using the reclass object
reclass_poss_mound_layer <- reclassify(poss_mound_layer_1,
                                       reclass_poss_mound_layer_1.m)

#invert result back
