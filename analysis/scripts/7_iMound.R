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

#1. read DTM
testdtm <- raster(paste0(path_analysis_data_dtm2014_TEST_AREA, lstestarea[[3]]))
mapview(testdtm)
plot(testdtm)
crs(testdtm)
#CRS arguments:
#+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs

#2. filtered DTM - mean/low pass
#let's test a 3x3 moving window
testdtm_mean <- raster::focal(testdtm, w=matrix(1/(3*3)), fun=mean, na.rm=FALSE)
mapview(testdtm_mean)
plot(testdtm_mean)
crs(testdtm_mean)

#3.inverse filtered DTM
#spatialEco::raster.invert Inverts raster values using the formula: (((x - max(x)) * -1) + min(x)
itDTMm <- spatialEco::raster.invert(testdtm_mean)

#4.pit filling algorithm of inverse filtered DTM
#Freeland et al. 2016 & Rom et al. useWang and Liu 2006, which is implemented in Whitebox GAT & SAGA
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

#5.inverse DTM - pit-filled DTM
poss_mound_layer_1 <- itDTMm - filled_dtm
raster::writeRaster(poss_mound_layer_1, filename=paste0(file.path(path_analysis_data_dtm2014_iMound),"/poss_mound_layer_1.tif"), overwrite = TRUE, NAflag = 0)

#thresholds for size, height and area
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

#reclassify raster
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
