################################Local Relief Model##############################
###################################SHORTCUTS####################################
lstestarea <-  list.files(file.path(path_analysis_data_dtm2014_TEST_AREA),
                          pattern = ".tif")
lsLRM <- list.files(file.path(path_analysis_data_dtm2014_derivatives_LRM),
                    pattern = ".tif")
################################################################################
###################################test area####################################
testdtm <- raster(paste0(path_analysis_data_dtm2014_TEST_AREA, lstestarea[[3]]))
testdtm
#values     : 181.3, 259.38  (min, max)
names(testdtm) <- "testdtm"
########################1) DTM -> smoothing focal filter########################
#25x25 m after Hesse 2010; our area is quite flat and we are looking
#for delicate structures 3 and 5 was tested but

#mean or low pass filter with a 3x3 moving window
testdtm_mean3 <- raster::focal(testdtm, w=matrix(1/(3*3), nrow = 3, ncol =3), fun=mean, na.rm=FALSE)
raster::writeRaster(testdtm_mean3, filename=paste0(file.path(path_analysis_data_dtm2014_derivatives_LRM),
                                                   "/testdtm_mean3.tif"), overwrite = TRUE, NAflag = 0)

testdtm_mean3
#values: 20.1458, 28.81086  (min, max)

#mean or low pass filter with a 5x5 moving window####
testdtm_mean5 <- raster::focal(testdtm, w=matrix(1/(5*5), nrow=5,ncol=5), fun=mean, na.rm=FALSE)
raster::writeRaster(testdtm_mean5, filename=paste0(file.path(path_analysis_data_dtm2014_derivatives_LRM),
                                                   "/testdtm_mean5.tif"), overwrite = TRUE, NAflag = 0)
testdtm_mean5
#values     : 7.252768, 10.37074  (min, max)

#2) Difference Map: DTM - DTMsmoothed####

DiffMap <- (testdtm - testdtm_mean3)
raster::writeRaster(DiffMap, filename=paste0(file.path(path_analysis_data_dtm2014_derivatives_LRM),
                                             "/DiffMap.tif"), overwrite = TRUE, NAflag = 0)
plot(DiffMap)

DiffMap2 <- (testdtm_mean3 - testdtm)
raster::writeRaster(DiffMap2, filename=paste0(file.path(path_analysis_data_dtm2014_derivatives_LRM),
                                              "/DiffMap2.tif"), overwrite = TRUE, NAflag = 0)
plot(DiffMap2)

#3)calculate contours from the DiffMap####
#alternative, already SpatialLinesDataframe####
contour05 <- rasterToContour(DiffMap, nlevels = 138)
writeOGR(contour05, layer= "contour05", paste0(file.path(path_analysis_data_dtm2014_derivatives_LRM),
                                               "/contour05.shp"), driver = "ESRI Shapefile", overwrite = TRUE)
contour02 <- rasterToContour(DiffMap, nlevels = 552)
writeOGR(contour02, layer= "contour02", paste0(file.path(path_analysis_data_dtm2014_derivatives_LRM),
                                               "/contour02.shp"), driver = "ESRI Shapefile", overwrite = TRUE)
contour01 <- rasterToContour(DiffMap, nlevels = 690)
writeOGR(contour01, layer= "contour01", paste0(file.path(path_analysis_data_dtm2014_derivatives_LRM),
                                               "/contour01.shp"), driver = "ESRI Shapefile", overwrite = TRUE)

#from: http://132.72.155.230:3838/r/combining-rasters-and-vector-layers.html#raster-to-contour####
#there are problems to transform back into SpatialLinesDataframe but apparently spatialLines if good for extract!
DiffMap <- stars::read_stars(paste0(path_analysis_data_dtm2014_derivatives_LRM, lsLRM[[1]]))
DiffMap = st_warp(src = DiffMap, crs = 32632, cellsize = 0.1)
range(DiffMap[[1]], na.rm = TRUE)
#[1] 161.1542 230.5694

names(DiffMap) <- "DiffMap_testdtm"

#set breaks/sequnece for countours lines
cntrl = seq(161.1542, 230.5694, 0.5)
cntrl2 = seq(161.1542, 230.5694, 0.2)
cntrl3 = seq(161.1542, 230.5694, 0.1)

DiffMap_contour01 = st_contour(DiffMap, breaks = cntrl3, contour_lines = TRUE)
#Simple feature collection with 475752 features and 1 field
#geometry type:  LINESTRING
#dimension:      XY
#bbox:           xmin: 482000.1 ymin: 5618000 xmax: 482999.9 ymax: 5619000
#projected CRS:  WGS 84 / UTM zone 32N
#First 10 features:
#  DiffMap_testarea                       geometry
#1       (215,215.1] LINESTRING (482000.2 561900...
#2       (215.8,215.9] LINESTRING (482010.2 561900...
#3       (216.3,216.4] LINESTRING (482021.6 561900...
#4       (216.4,216.5] LINESTRING (482024.5 561900...
#5       (216.5,216.6] LINESTRING (482028.3 561900...
#6       (217,217.1] LINESTRING (482041.2 561900...
#7       (217.2,217.3] LINESTRING (482047.7 561900...
#8       (217.3,217.4] LINESTRING (482051.3 561900...
#9       (217.8,217.9] LINESTRING (482066.1 561900...
#10      (218,218.1] LINESTRING (482096 5619000,...

st_write(DiffMap_contour01, paste0(file.path(path_analysis_data_dtm2014_derivatives_LRM),
                                   "/DiffMap_contour01.shp"), driver = "ESRI Shapefile",
         overwrite = TRUE)

DiffMap_contour02 = st_contour(DiffMap, breaks = cntrl2, contour_lines = TRUE)
st_write(DiffMap_contour02, paste0(file.path(path_analysis_data_dtm2014_derivatives_LRM),
                                   "/DiffMap_contour02.shp"), driver = "ESRI Shapefile",
         overwrite = TRUE)

DiffMap_contour05 = st_contour(DiffMap, breaks = cntrl, contour_lines = TRUE)
st_write(DiffMap_contour05, paste0(file.path(path_analysis_data_dtm2014_derivatives_LRM),
                                   "/DiffMap_contour05.shp"), driver = "ESRI Shapefile",
         overwrite = TRUE)

#plot the contour lines
plot(DiffMap, breaks = cntrl, col = terrain.colors(length(cntrl)-1),
     key.pos = 4, reset = FALSE)
plot(st_geometry(DiffMap_contour05), add = TRUE)
plot(DiffMap, breaks = cntrl2, col = terrain.colors(length(cntrl2)-1),
     key.pos = 4, reset = FALSE)
plot(st_geometry(DiffMap_contour02), add = TRUE)
plot(DiffMap, breaks = cntrl3, col = terrain.colors(length(cntrl3)-1),
     key.pos = 4, reset = FALSE)
plot(st_geometry(DiffMap_contour01), add = TRUE)

#4) extract elevation from the original DTM along the elevation contours####
#= SER Simplified Elevation Raster

DiffMap_contour05
#geometry type:  LINESTRING
DiffMap_contour05sp <- as(st_geometry(DiffMap_contour05), "Spatial")
#class: SpatialLines

DiffMap_contour02
DiffMap_contour02sp <- as(st_geometry(DiffMap_contour02), "Spatial")

DiffMap_contour01
DiffMap_contour01sp <- as(st_geometry(DiffMap_contour01), "Spatial")

#4.1 transform Linestring to multipoint and then to point####
#contourlines 05####
class(st_geometry(DiffMap_contour05, quiet = TRUE))
#"sfc_LINESTRING" "sfc"

DiffMap_contour05mpoint <- st_cast(DiffMap_contour05$geometry, "MULTIPOINT")
class(st_geometry(DiffMap_contour05mpoint, quiet = TRUE))
#"sfc_MULTIPOINT" "sfc"

DiffMap_contour05point <- st_cast(st_sfc(DiffMap_contour05mpoint), "POINT")
class(st_geometry(DiffMap_contour05mpoint, quiet = TRUE))
#"sfc_POINT" "sfc"

#DiffMap_contour02####
class(st_geometry(DiffMap_contour02, quiet = TRUE))
#"sfc_LINESTRING" "sfc"

DiffMap_contour02mpoint <- st_cast(DiffMap_contour02$geometry, "MULTIPOINT")
class(st_geometry(DiffMap_contour05mpoint, quiet = TRUE))
#"sfc_MULTIPOINT" "sfc"

DiffMap_contour02point <- st_cast(st_sfc(DiffMap_contour02mpoint), "POINT")
class(st_geometry(DiffMap_contour02point, quiet = TRUE))
#"sfc_POINT" "sfc"

#DiffMap_contour01####
class(st_geometry(DiffMap_contour01, quiet = TRUE))
#"sfc_LINESTRING" "sfc"

DiffMap_contour01mpoint <- st_cast(DiffMap_contour01$geometry, "MULTIPOINT")
class(st_geometry(DiffMap_contour01mpoint, quiet = TRUE))
#"sfc_MULTIPOINT" "sfc"

DiffMap_contour01point <- st_cast(st_sfc(DiffMap_contour01mpoint), "POINT")
class(st_geometry(DiffMap_contour01point, quiet = TRUE))
#"sfc_POINT" "sfc"

#4.2 Extract/mask elevation from the original DTM (testDTM)####
#contourpoints05 <- st_extract(DiffMap, DiffMap_contour05point)
#contourpoints02 <- st_extract(DiffMap, DiffMap_contour02point)
#contourpoints01 <- st_extract(DiffMap, DiffMap_contour01point)

#DiffMap_contour05sp: SpatialLines
#contour05: SpatialLinesDataFrame
#raster::extract -> SpatialLines
#raster::mask -> Raster* object or a Spatial* object

SER05xtr <- raster::extract(testdtm, DiffMap_contour05sp)


#or
SER05 <- mask(x=testdtm, mask=contour05, filename=paste0(file.path(path_analysis_data_dtm2014_derivatives_LRM),
                                                         "/SER05.tif"), overwrite = TRUE, NAflag = 0)

SER02 <- mask(testdtm, contour02)
SER01 <- mask(testdtm, contour01)

#5) SER to points (raster to points)

#6) Create a TIN from the points
#7) conversion of TIN (6) to a DTM
#8) DEM - 7)





