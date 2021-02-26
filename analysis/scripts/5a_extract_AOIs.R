####################################SHORTCUTS###################################
lsDTM2014_1 <- list.files(file.path(path_analysis_data_dtm2014_AOI_1),
                          full.names = TRUE, pattern = glob2rx("*.tif"))

lsDTM2014_2 <- list.files(file.path(path_analysis_data_dtm2014_AOI_2),
                          full.names = TRUE, pattern = glob2rx("*.tif"))
lsDTM2014_3 <- list.files(file.path(path_analysis_data_dtm2014_AOI_3),
                          full.names = TRUE, pattern = glob2rx("*.tif"))
lsDTM2014_4 <- list.files(file.path(path_analysis_data_dtm2014_AOI_4),
                          full.names = TRUE, pattern = glob2rx("*.tif"))
lsDTM2014_5 <- list.files(file.path(path_analysis_data_dtm2014_AOI_5),
                          full.names = TRUE, pattern = glob2rx("*.tif"))
lstestarea <-  list.files(file.path(path_analysis_data_dtm2014_TEST_AREA),
                          full.names = TRUE, pattern = glob2rx("*.tif"))

                    ####++MERGE THE 2014 DTM AOIs++####

                                  #AoI 1 (7 tiles)####
#first make sure they have the same projection####
#this step is slow!
proj_new <- '+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0'

for (i in 1:length(lsDTM2014_1)) {
  r <- raster(lsDTM2014_1[i])
  prj <- projectRaster(r, crs=proj_new, method = 'bilinear', res = 0.1,
                       filename = paste0(path_analysis_data_dtm2014_AOI_1_repr, names(r), "_r.tif"),
                       format="GTiff", overwrite=TRUE)
}

#Warnmeldungen:
#1: In projectRaster(r, crs = proj_new, method = "bilinear",  ... : input and ouput crs are the same

#great! so this step could be left out! this is just to make sure that the crs matches!!!

#then check all raster for missing data by plotting their histograms####
par(mfrow = c(4, 2))
for (i in 1:length(lsDTM2014_1)) {
    r <- raster(lsDTM2014_1[i])
    hist(r,
         main = paste("Distribution of surface elevation values", i),
         xlab = "Elevation (meters)", ylab = "Frequency",
         col = "goldenrod")
}

#now merge the raster in the respective AoI!####
lsDTM2014_1_repr <-  list.files(file.path(path_analysis_data_dtm2014_AOI_1_repr),
                                full.names = TRUE, pattern = glob2rx("*.tif"))

#crs test
test <- raster(lsDTM2014_1_repr[1])
crs(test)
# +proj=utm +zone=32 +datum=WGS84 +units=m +no_defs

#first let's create a template raster file to fit our rasters into it
#note that the extent is not important
#e <- extent(-131, -124, 49, 53)
#template <- raster(e)
#projection(template) <- '+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0'
#writeRaster(template, file=paste0(path_analysis_data_dtm2014_AREA1_mrgd, "/", "DTM2014_1_template.tif"), format="GTiff")

# Merge all raster tiles into one big raster.
mosaic_rasters(gdalfile = lsDTM2014_1_repr,
               dst_dataset = paste0(path_analysis_data_dtm2014_AOI_1_mrgd,
               "DTM2014_AoI_1_merged.tif"), of="GTiff", overwrite = TRUE)


                                    #AoI 2 (4 tiles)####
#first make sure they have the same projection####
#this step is slow!
proj_new <- '+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0'

for (i in 1:length(lsDTM2014_2)) {
  r <- raster(lsDTM2014_2[i])
  prj <- projectRaster(r, crs=proj_new, method = 'bilinear', res = 0.1,
                       filename = paste0(path_analysis_data_dtm2014_AOI_2_repr, names(r), "_r.tif"),
                       format="GTiff", overwrite=TRUE)
}

#Warnmeldungen:
#1: In projectRaster(r, crs = proj_new, method = "bilinear",  ... : input and ouput crs are the same
#great! so this step could be left out! this is just to make sure that the crs matches!!!

#then check all raster for missing data by plotting their histograms####
par(mfrow = c(2, 2))
for (i in 1:length(lsDTM2014_2)) {
  r <- raster(lsDTM2014_2[i])
  hist(r,
       main = paste("Distribution of surface elevation values", i),
       xlab = "Elevation (meters)", ylab = "Frequency",
       col = "darkseagreen4")
}

#now merge the raster in the respective AoI!####
lsDTM2014_2_repr <-  list.files(file.path(path_analysis_data_dtm2014_AOI_2_repr),
                                full.names = TRUE, pattern = glob2rx("*.tif"))

#first let's create a template raster file to fit our rasters into it
#note that the extent is not important
#e <- extent(-131, -124, 49, 53)
#template <- raster(e)
#projection(template) <- '+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0'
#writeRaster(template, file=paste0(path_analysis_data_dtm2014_AREA1_mrgd, "/", "DTM2014_1_template.tif"), format="GTiff")

# Merge all raster tiles into one big raster.
mosaic_rasters(gdalfile = lsDTM2014_2_repr,
               dst_dataset = paste0(path_analysis_data_dtm2014_AOI_2_mrgd,
               "DTM2014_AoI_2_merged.tif"), of="GTiff", overwrite = TRUE)

                                    #AoI 3 (11 tiles)####
#first make sure they have the same projection####
#this step is slow!
proj_new <- '+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0'

for (i in 1:length(lsDTM2014_3)) {
  r <- raster(lsDTM2014_3[i])
  prj <- projectRaster(r, crs=proj_new, method = 'bilinear', res = 0.1,
                       filename = paste0(path_analysis_data_dtm2014_AOI_3_repr, names(r), "_r.tif"),
                       format="GTiff", overwrite=TRUE)
}

#Warnmeldungen:
#1: In projectRaster(r, crs = proj_new, method = "bilinear",  ... : input and ouput crs are the same
#great! so this step could be left out! this is just to make sure that the crs matches!!!

#then check all raster for missing data by plotting their histograms####
par(mfrow = c(4, 3))
for (i in 1:length(lsDTM2014_3)) {
  r <- raster(lsDTM2014_3[i])
  hist(r,
       main = paste("Distribution of surface elevation values", i),
       xlab = "Elevation (meters)", ylab = "Frequency",
       col = "coral2")
}

#now merge the raster in the respective AoI!####
lsDTM2014_3_repr <-  list.files(file.path(path_analysis_data_dtm2014_AOI_3_repr),
                                full.names = TRUE, pattern = glob2rx("*.tif"))

#first let's create a template raster file to fit our rasters into it
#note that the extent is not important
#e <- extent(-131, -124, 49, 53)
#template <- raster(e)
#projection(template) <- '+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0'
#writeRaster(template, file=paste0(path_analysis_data_dtm2014_AREA1_mrgd, "/", "DTM2014_1_template.tif"), format="GTiff")

# Merge all raster tiles into one big raster.
mosaic_rasters(gdalfile = lsDTM2014_3_repr,
               dst_dataset = paste0(path_analysis_data_dtm2014_AOI_3_mrgd,
               "DTM2014_AoI_3_merged.tif"), of="GTiff", overwrite = TRUE)

                                   #AoI 4 (18 tiles)####
#first make sure they have the same projection####
#this step is slow!
proj_new <- '+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0'
#this step is slow!

for (i in 1:length(lsDTM2014_4)) {
  r <- raster(lsDTM2014_4[i])
  prj <- projectRaster(r, crs=proj_new, method = 'bilinear', res = 0.1,
                       filename = paste0(path_analysis_data_dtm2014_AOI_4_repr, names(r), "_r.tif"),
                       format="GTiff", overwrite=TRUE)
}

#Warnmeldungen:
#1: In projectRaster(r, crs = proj_new, method = "bilinear",  ... : input and ouput crs are the same
#great! so this step could be left out! this is just to make sure that the crs matches!!!

#then check all raster for missing data by plotting their histograms####
par(mfrow = c(4, 5))
for (i in 1:length(lsDTM2014_4)) {
  r <- raster(lsDTM2014_4[i])
  hist(r,
       main = paste("Distribution of surface elevation values", i),
       xlab = "Elevation (meters)", ylab = "Frequency",
       col = "cadetblue4")
}

#now merge the raster in the respective AoI!####
#list the reprojected files
lsDTM2014_4_repr <-  list.files(file.path(path_analysis_data_dtm2014_AOI_4_repr),
                                full.names = TRUE, pattern = glob2rx("*.tif"))

#merge all raster tiles
mosaic_rasters(gdalfile = lsDTM2014_4_repr,
               dst_dataset = paste0(path_analysis_data_dtm2014_AOI_4_mrgd,
                "DTM2014_AoI_4_merged.tif"), of="GTiff", overwrite = TRUE)

                                #AoI 5 (4 tiles)####
#first make sure they have the same projection####
#this step is slow!
proj_new <- '+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0'

for (i in 1:length(lsDTM2014_5)) {
  r <- raster(lsDTM2014_5[i])
  prj <- projectRaster(r, crs=proj_new, method = 'bilinear', res = 0.1,
                       filename = paste0(path_analysis_data_dtm2014_AOI_5_repr, names(r), "_r.tif"),
                       format="GTiff", overwrite=TRUE)
}

#Warnmeldungen:
#1: In projectRaster(r, crs = proj_new, method = "bilinear",  ... : input and ouput crs are the same
#great! so this step could be left out! this is just to make sure that the crs matches!!!

#then check all raster for missing data by plotting their histograms####
par(mfrow = c(2, 2))
for (i in 1:length(lsDTM2014_5)) {
  r <- raster(lsDTM2014_5[i])
  hist(r,
       main = paste("Distribution of surface elevation values", i),
       xlab = "Elevation (meters)", ylab = "Frequency",
       col = "burlywood4")
}

#now merge the raster in the respective AoI!####
#list the reprojected files
lsDTM2014_5_repr <-  list.files(file.path(path_analysis_data_dtm2014_AOI_5_repr),
                                full.names = TRUE, pattern = glob2rx("*.tif"))

#merge all raster tiles
mosaic_rasters(gdalfile = lsDTM2014_5_repr,
               dst_dataset = paste0(path_analysis_data_dtm2014_AOI_5_mrgd,
               "DTM2014_AoI_5_merged.tif"), of="GTiff", overwrite = TRUE)




                            #test area (5 tiles)####
#first make sure they have the same projection####
#this step is slow!
proj_new <- '+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0'

for (i in 1:length(lstestarea)) {
  r <- raster(lstestarea[i])
  prj <- projectRaster(r, crs=proj_new, method = 'bilinear', res = 0.1,
                       filename = paste0(path_analysis_data_dtm2014_TEST_AREA_repr, names(r), "_r.tif"),
                       format="GTiff", overwrite=TRUE)
}

#Warnmeldungen:
#1: In projectRaster(r, crs = proj_new, method = "bilinear",  ... : input and ouput crs are the same
#great! so this step could be left out! this is just to make sure that the crs matches!!!

#then check all raster for missing data by plotting their histograms####
par(mfrow = c(2, 3))
for (i in 1:length(lstestarea)) {
  r <- raster(lstestarea[i])
  hist(r,
       main = paste("Distribution of surface elevation values", i),
       xlab = "Elevation (meters)", ylab = "Frequency",
       col = "darkslategrey")
}

#now merge the raster in the respective AoI!####
#list the reprojected files
lstestarea_repr <-  list.files(file.path(path_analysis_data_dtm2014_TEST_AREA_repr),
                                full.names = TRUE, pattern = glob2rx("*.tif"))

#merge all raster tiles
mosaic_rasters(gdalfile = lstestarea_repr,
               dst_dataset = paste0(path_analysis_data_dtm2014_TEST_AREA_mrgd,
                                    "DTM2014_test_area_merged.tif"), of="GTiff", overwrite = TRUE)
