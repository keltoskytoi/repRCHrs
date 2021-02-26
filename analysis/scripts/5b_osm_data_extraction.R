####++FITLER THE LIDAR2018 OSM LANDUSE MAP FOR THE RELEVANT STRUCTURES++####

#because the lu layer for Hessen is more than 1 GB in size ("gis_osm_landuse_a_free_1.shp"),
#R struggles to cut the 180 km2s and thus it was done in QGIS to make it quick and dirty...

#load LiDAR outline 2018
outline_LiDAR_2018 <- readOGR(paste0(path_analysis_data_LiDAR_info, "outline_LIDAR2018_32632.shp"))
#OGR data source with driver: ESRI Shapefile
#Source: "E:\repRCHrs\analysis\data\LiDAR_data\outline_LIDAR2018.shp", layer: "outline_LIDAR2018"
#with 1 features
#It has 1 fields
#Integer64 fields read as strings:  id
crs(outline_LiDAR_2018)
#CRS arguments: #+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs
extent(outline_LiDAR_2018)

#load landuse LIDAR2018
landuse_LIDAR2018 <- readOGR(paste0(path_analysis_data_LiDAR_info, "LIDAR2018_landuseosm.shp"))
crs(landuse_LIDAR2018)
#CRS arguments: +proj=longlat +datum=WGS84 +no_defs

#reproject/transform the crs of LIDAR2018_lu_osm_repr
LIDAR2018_lu_osm_repr <- spTransform(landuse_LIDAR2018,
                                     crs(outline_LiDAR_2018))
crs(LIDAR2018_lu_osm_repr)
#+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs

#write out LIDAR2018_lu_osm_repr
rgdal::writeOGR(obj=LIDAR2018_lu_osm_repr, dsn = "E:/repRCHrs/analysis/data/LiDAR_info",
                layer ="LIDAR2018_lu_osm_repr", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)

#read it again for test
LIDAR2018_lu_osm_repr <- readOGR(paste0(path_analysis_data_LiDAR_info, "LIDAR2018_lu_osm_repr.shp"))
crs(LIDAR2018_lu_osm_repr)
#+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs

names(LIDAR2018_lu_osm_repr)
#[1] "osm_id" "code"   "fclass" "name"

#we can see in QGIS, that some building areas are not covered by the land-use map.
#There is around 10 % of the building are which is not mapped - it is OK;
#a lot faster this way than clicking it by yourself

#now we want to filter the land use layer to allotments, cemetery, commercial,
#farmyard, industrial, quarry, recreation_ground, residential and retail;
#farmland, forest, grass, heath, meadow, nature_reserve, orchard, park, scrub and vineyard stays

LIDAR2018_lu_osm_repr
#class       : SpatialPolygonsDataFrame
#features    : 4609
#extent      : 477999.9, 488000, 5615998, 5634000  (xmin, xmax, ymin, ymax)
#variables   : 4
# A tibble: 4,609 x 4

LIDAR2018_lu_osm_repr$fclass <- as.factor(LIDAR2018_lu_osm_repr$fclass)

LIDAR2018_lu_osm_repr_filt <-
  LIDAR2018_lu_osm_repr %>% dplyr::filter(fclass == "allotments" |
                                            fclass == "cemetery" |
                                            fclass == "commercial" |
                                            fclass == "farmyard" |
                                            fclass == "industrial" |
                                            fclass == "quarry" |
                                            fclass == "recreation_ground" |
                                            fclass == "residential" |
                                            fclass == "retail")
plot(LIDAR2018_lu_osm_repr_filt)

rgdal::writeOGR(obj=LIDAR2018_lu_osm_repr_filt, dsn = "E:/repRCHrs/analysis/data/LiDAR_info",
                layer ="LIDAR2018_lu_osm_repr_filt", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)

LIDAR2018_lu_osm_repr_filt <- readOGR(paste0(path_analysis_data_LiDAR_info, "LIDAR2018_lu_osm_repr_filt.shp"))
crs(LIDAR2018_lu_osm_repr_filt)

     ####++CUT THE OSM LANDUSE MAP TO THE SIZE OF THE LIDAR DATASETS++####
AOI_1 <-raster(paste0(path_analysis_data_dtm2014_AOI_1_mrgd, "DTM2014_AoI_1_merged.tif"))
AOI_2 <-raster(paste0(path_analysis_data_dtm2014_AOI_2_mrgd, "DTM2014_AoI_2_merged.tif"))
AOI_3 <-raster(paste0(path_analysis_data_dtm2014_AOI_3_mrgd, "DTM2014_AoI_3_merged.tif"))
AOI_4 <-raster(paste0(path_analysis_data_dtm2014_AOI_4_mrgd, "DTM2014_AoI_4_merged.tif"))
AOI_5 <-raster(paste0(path_analysis_data_dtm2014_AOI_5_mrgd, "DTM2014_AoI_5_merged.tif"))
test_area <- raster(paste0(path_analysis_data_dtm2014_AOI_5_mrgd, "DTM2014_test_area_merged.tif"))

AOI_1shp <-readOGR(paste0(path_analysis_data_LiDAR_info, "AOI_1.shp"))
AOI_2shp <-readOGR(paste0(path_analysis_data_LiDAR_info, "AOI_2.shp"))
AOI_3shp <-readOGR(paste0(path_analysis_data_LiDAR_info, "AOI_3.shp"))
AOI_4shp <-readOGR(paste0(path_analysis_data_LiDAR_info, "AOI_4.shp"))
AOI_5shp <-readOGR(paste0(path_analysis_data_LiDAR_info, "AOI_5.shp"))

lu_AOI_1 <- crop(LIDAR2018_lu_osm_repr_filt, AOI_1shp)
plot(AOI_1)
plot(lu_AOI_1, add = TRUE)
rgdal::writeOGR(obj=lu_AOI_1, dsn = "E:/repRCHrs/analysis/data/LiDAR_info",
                layer ="lu_AOI_1", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)

lu_AOI_2 <- crop(LIDAR2018_lu_osm_repr_filt, AOI_2shp)
plot(AOI_2)
plot(lu_AOI_2, add = TRUE)
rgdal::writeOGR(obj=lu_AOI_2, dsn = "E:/repRCHrs/analysis/data/LiDAR_info",
                layer ="lu_AOI_2", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)

lu_AOI_3 <- crop(LIDAR2018_lu_osm_repr_filt, AOI_3shp)
plot(AOI_3)
plot(lu_AOI_3, add = TRUE)
#the burial mounds are on the terrain of the Botanical Garden, thus the class
#recreational is filtered out from this shapefile
lu_AOI_3$fclass <- as.factor(lu_AOI_3$fclass)

lu_AOI_3_filt <-
  lu_AOI_3 %>% dplyr::filter(fclass == "allotments" |
                               fclass == "cemetery" |
                               fclass == "commercial" |
                               fclass == "farmyard" |
                               fclass == "industrial" |
                               fclass == "quarry" |
                               fclass == "residential" |
                               fclass == "retail")
plot(AOI_3)
plot(lu_AOI_3_filt, add = TRUE)

rgdal::writeOGR(obj=lu_AOI_3_filt, dsn = "E:/repRCHrs/analysis/data/LiDAR_info",
                layer ="lu_AOI_3_filt", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)

lu_AOI_4 <- crop(LIDAR2018_lu_osm_repr_filt, AOI_4shp)
plot(AOI_4)
plot(lu_AOI_4, add = TRUE)
rgdal::writeOGR(obj=lu_AOI_4, dsn = "E:/repRCHrs/analysis/data/LiDAR_info",
                layer ="lu_AOI_4", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)

lu_AOI_5 <- crop(LIDAR2018_lu_osm_repr_filt, AOI_5shp)
plot(AOI_5)
plot(lu_AOI_5, add = TRUE)
rgdal::writeOGR(obj=lu_AOI_5, dsn = "E:/repRCHrs/analysis/data/LiDAR_info",
                layer ="lu_AOI_5", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)

lu_test_area <- crop(LIDAR2018_lu_osm_repr_filt, test_area)
plot(test_area)
plot(lu_test_area, add = TRUE)
rgdal::writeOGR(obj=lu_test_area, dsn = "E:/repRCHrs/analysis/data/LiDAR_info",
                layer ="lu_test_area", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)

                    ####++MASK OUT LANDUSE AREAS++####
AOI_1 <-raster(paste0(path_analysis_data_dtm2014_AOI_1_mrgd, "DTM2014_AoI_1_merged.tif"))
AOI_2 <-raster(paste0(path_analysis_data_dtm2014_AOI_2_mrgd, "DTM2014_AoI_2_merged.tif"))
AOI_3 <-raster(paste0(path_analysis_data_dtm2014_AOI_3_mrgd, "DTM2014_AoI_3_merged.tif"))
AOI_4 <-raster(paste0(path_analysis_data_dtm2014_AOI_4_mrgd, "DTM2014_AoI_4_merged.tif"))
AOI_5 <-raster(paste0(path_analysis_data_dtm2014_AOI_5_mrgd, "DTM2014_AoI_5_merged.tif"))

lu_AOI_1 <- readOGR(paste0(path_analysis_data_LiDAR_info, "lu_AOI_1v2.shp"))
lu_AOI_2 <- readOGR(paste0(path_analysis_data_LiDAR_info, "lu_AOI_2.shp"))
lu_AOI_3 <- readOGR(paste0(path_analysis_data_LiDAR_info, "lu_AOI_3_filt.shp"))
lu_AOI_4 <- readOGR(paste0(path_analysis_data_LiDAR_info, "lu_AOI_4.shp"))
lu_AOI_5 <- readOGR(paste0(path_analysis_data_LiDAR_info, "lu_AOI_5.shp"))

#first rasterize the respective shapefile
lu_AOI_1_rast <- rasterize(lu_AOI_1, AOI_1)
class(lu_AOI_1_rast) #raster
plot(lu_AOI_1_rast)
res(lu_AOI_1_rast) #0.1 0.1
writeRaster(lu_AOI_1_rast, paste0(path_analysis_data_dtm2014_AOI_1_rast,"lu_AOI_1_rast.tif"))
lu_AOI_1_rast <-raster(paste0(path_analysis_data_dtm2014_AOI_1_rast, "lu_AOI_1_rast.tif"))

lu_AOI_1_rast[lu_AOI_1_rast > 0] <- 1
plot(lu_AOI_1_rast)
# plot the masked data
plot(lu_AOI_1_rast,
     main = "The Raster Mask",
     col = c("deepskyblue4"),
     legend = FALSE,
     axes = FALSE,
     box = FALSE)
# add legend to map
par(xpd = TRUE) # force legend to plot outside of the plot extent
legend(x = lu_AOI_1_rast@extent@xmax, lu_AOI_1_rast@extent@ymax,
       c("Not masked", "Masked"),
       fill = c("deepskyblue4", "white"),
       bty = "n")

AOI_1_masked <- mask(AOI_1, mask = lu_AOI_1)
class(AOI_1_masked)

plot(AOI_1_masked)

              ############## to be continued ############

#first rasterize the respective shapefile
lu_AOI_2_rast <- rasterize(lu_AOI_2, AOI_2)
writeRaster(lu_AOI_2_rast, paste0(path_analysis_data_dtm2014_AOI_2_rast,"lu_AOI_2_rast.tif"))
lu_AOI_3_rast <- rasterize(lu_AOI_3, AOI_3)
writeRaster(lu_AOI_3_rast, paste0(path_analysis_data_dtm2014_AOI_3_rast,"lu_AOI_3_rast.tif"))
lu_AOI_4_rast <- rasterize(lu_AOI_4, AOI_4)
writeRaster(lu_AOI_4_rast, paste0(path_analysis_data_dtm2014_AOI_4_rast,"lu_AOI_4_rast.tif"))
lu_AOI_5_rast <- rasterize(lu_AOI_5, AOI_5)
writeRaster(lu_AOI_5_rast, paste0(path_analysis_data_dtm2014_AOI_5_rast,"lu_AOI_5_rast.tif"))
