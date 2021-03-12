###################################SHORTCUTS####################################
lstestarea <-  list.files(file.path(path_analysis_data_dtm2014_TEST_AREA),
                          pattern = ".tif")
lsLRM <- list.files(file.path(path_analysis_data_dtm2014_derivatives_LRM),
                    pattern = ".tif")
################################################################################

#test area
testdtm <- raster(paste0(path_analysis_data_dtm2014_TEST_AREA, lstestarea[[3]]))
testdtm
#values     : 181.3, 259.38  (min, max)
names(testdtm) <- "testdtm"


#first locate the raster and map it
my_colors <- terrain.colors(79)
mapview::mapviewOptions(mapview.maxpixels = testdtm@ncols*testdtm@nrows/100)
mapview::mapview(testdtm, col.regions = my_colors, legend = TRUE)

#as you can see you can see nothing! But we can see that the area is in the right
#spot!

#or:
plot(test_area,
     col = terrain.colors(200))

##########################Calculate multiple derivatives########################

            ####using filters: sum, min, max, sd, mean, sobel####
#sum, min, max, sd, mean, sobel
filter_testdtm<- filtR(testdtm, filtRs="all", sizes=c(3,5), NArm=TRUE)

names(filter_testdtm)
#[1] "X3dm_32482_5618_1_he_xyzirnc_ground_IDW01_sum3"
#[2] "X3dm_32482_5618_1_he_xyzirnc_ground_IDW01_sum5"
#[3] "X3dm_32482_5618_1_he_xyzirnc_ground_IDW01_min3"
#[4] "X3dm_32482_5618_1_he_xyzirnc_ground_IDW01_min5"
#[5] "X3dm_32482_5618_1_he_xyzirnc_ground_IDW01_max3"
#[6] "X3dm_32482_5618_1_he_xyzirnc_ground_IDW01_max5"
#[7] "X3dm_32482_5618_1_he_xyzirnc_ground_IDW01_sd3"
#[8] "X3dm_32482_5618_1_he_xyzirnc_ground_IDW01_sd5"
#[9] "X3dm_32482_5618_1_he_xyzirnc_ground_IDW01_mean3"
#[10] "X3dm_32482_5618_1_he_xyzirnc_ground_IDW01_mean5"
#[11] "X3dm_32482_5618_1_he_xyzirnc_ground_IDW01_sobel3"
#[12] "X3dm_32482_5618_1_he_xyzirnc_ground_IDW01_sobel5"

names(filter_testdtm) <- c("testdtm_sum3", "testdtm_sum5", "testdtm_min3",
                                 "testdtm_min5", "testdtm_max3", "testdtm_max5",
                                 "testdtm_sd3", "testdtm_sd5", "testdtm_mean3",
                                 "testdtm_mean5", "testdtm_sobel3", "testdtm_sobel5")
#export filter
writeRaster(filter_testdtm, paste0(path_analysis_data_dtm2014_derivatives,
                            filename = names(filter_testdtm), ".tif"),
                            format= "GTiff", bylayer = TRUE, overwrite=TRUE)


                         ####Slope and Apsect####
#from the raster::terrain description:

#when neighbors=4, slope and aspect are computed according to Fleming and Hoffer
#(1979) and Ritter (1987); when neigbors=8, slope and aspect are computed according
#to Horn (1981). The Horn algorithm may be best for rough surfaces, and the
#Fleming and Hoffer algorithm may be better for smoother surfaces (Jones, 1997;
#Burrough and McDonnell, 1998).

#We do have a smooth surface, so: neighbors=4

#Slope
Slope<- raster::terrain(testdtm, opt = "slope", unit="radians", neighbors = 4,
                        filename = paste0(path_analysis_data_dtm2014_derivatives, "test_Slope.tif"),
                        overwrite = TRUE)
#Aspect
Aspect <- raster::terrain(testdtm, opt = "aspect", unit="degrees", neighbors = 4,
                  filename = paste0(path_analysis_data_dtm2014_derivatives, "test_Aspect_deg.tif"),
                  overwrite = TRUE)
Aspect_rad <- raster::terrain(testdtm, opt = "aspect", unit="radians", neighbors = 4,
                      filename = paste0(path_analysis_data_dtm2014_derivatives, "test_Aspect_rad.tif"),
                      overwrite = TRUE)

                                  ####Hillshade####
#raster package####
HS <- hillShade(slope=Slope, aspect=Aspect_rad, 40, 270,
                filename = paste0(path_analysis_data_dtm2014_derivatives, "test_HS.tif"))

plot(HS, col=grey(0:100/100), legend=FALSE, main='test area')
plot(test_area, col=terrain.colors(79, alpha=0.35), add=TRUE)

#whiteboxR####
wbt_version()

wbt_hillshade(
  dem = "E:/repRCHrs/analysis/data/dtm2014/TEST_AREA/3dm_32482_5618_1_he_xyzirnc_ground_IDW01.tif",
  output = "E:/repRCHrs/analysis/data/dtm2014/derivatives/test_HS_wb.tif",
  azimuth = 270,
  altitude = 40,
  zfactor = NULL,
  wd = paste0(path_analysis_data_dtm2014_TEST_AREA),
  verbose_mode = TRUE,
  compress_rasters = FALSE)

              ####Multiscale topographic position image works to 50%####

#first the Max elevation deviation has to be calculated with #wbt_max_elevation_deviation
#one has to test out he values
#local scale
wbt_max_elevation_deviation(
  dem = "E:/repRCHrs/analysis/data/dtm2014/TEST_AREA/3dm_32482_5618_1_he_xyzirnc_ground_IDW01.tif",
  out_mag = "E:/repRCHrs/analysis/data/dtm2014/derivatives/test_max_dev_local_magnitude_wb.tif",
  out_scale = "E:/repRCHrs/analysis/data/dtm2014/derivatives/test_max_dev_local_scale_wb.tif",
  min_scale = 1,
  max_scale= 10,
  step = 1,
  wd = NULL,
  verbose_mode = TRUE,
  compress_rasters = FALSE
)

#meso scale
wbt_max_elevation_deviation(
  dem = "E:/repRCHrs/analysis/data/dtm2014/TEST_AREA/3dm_32482_5618_1_he_xyzirnc_ground_IDW01.tif",
  out_mag = "E:/repRCHrs/analysis/data/dtm2014/derivatives/test_max_dev_meso_magnitude_wb.tif",
  out_scale = "E:/repRCHrs/analysis/data/dtm2014/derivatives/test_max_dev_meso_scale_wb.tif",
  min_scale = 10,
  max_scale= 50,
  step = 1,
  wd = NULL,
  verbose_mode = TRUE,
  compress_rasters = FALSE
)
#broad scale
wbt_max_elevation_deviation(
  dem = "E:/repRCHrs/analysis/data/dtm2014/TEST_AREA/3dm_32482_5618_1_he_xyzirnc_ground_IDW01.tif",
  out_mag = "E:/repRCHrs/analysis/data/dtm2014/derivatives/test_max_dev_broad_magnitude_wb.tif",
  out_scale = "E:/repRCHrs/analysis/data/dtm2014/derivatives/test_max_dev_broad_scale_wb.tif",
  min_scale = 50,
  max_scale= 100,
  step = 1,
  wd = NULL,
  verbose_mode = TRUE,
  compress_rasters = FALSE
)

max_dev_broad_scale <- raster::raster("E:/repRCHrs/analysis/data/dtm2014/derivatives/test_max_dev_broad_scale_wb.tif")
max_dev_meso_scale <- raster::raster ("E:/repRCHrs/analysis/data/dtm2014/derivatives/test_max_dev_meso_scale_wb.tif")
max_dev_local_scale <- raster::raster("E:/repRCHrs/analysis/data/dtm2014/derivatives/test_max_dev_local_scale_wb.tif")

#the MTPI - why does in NOT work???????
wbt_multiscale_topographic_position_image(
  local = max_dev_local_scale,
  meso = max_dev_meso_scale,
  broad = max_dev_broad_scale,
  output = (paste0(path_analysis_data_dtm2014_derivatives, "multiscale_tpi_wb.tif")),
  lightness = 1.2,
  wd = NULL,
  verbose_mode = TRUE,
  compress_rasters = FALSE
)

#TPI, TWI
#check derivatives from Niculita 2020a
