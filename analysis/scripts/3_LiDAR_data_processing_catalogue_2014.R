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
