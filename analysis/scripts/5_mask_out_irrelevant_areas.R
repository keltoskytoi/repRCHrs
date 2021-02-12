 ####++CUT THE OSM LANDUSE MAP TO THE SIZE OF THE SMALLEST LIDAR DATASET++####

#load landuse in Hessen
landuse_Hessen <- readOGR(paste0(path_analysis_data_LiDAR_data, "gis_osm_landuse_a_free_1.shp"))
#OGR data source with driver: ESRI Shapefile
#Source: "E:\repRCHrs\analysis\data\LiDAR_data\gis_osm_landuse_a_free_1.shp", layer: "gis_osm_landuse_a_free_1"
#with 384394 features
#It has 4 fields
crs(landuse_Hessen)
#CRS arguments: +proj=longlat +datum=WGS84 +no_defs

#load LiDAR outline 2018
outline_LiDAR_2018 <- readOGR(paste0(path_analysis_data_LiDAR_data, "outline_LIDAR2018.shp"))
#OGR data source with driver: ESRI Shapefile
#Source: "E:\repRCHrs\analysis\data\LiDAR_data\outline_LIDAR2018.shp", layer: "outline_LIDAR2018"
#with 1 features
#It has 1 fields
#Integer64 fields read as strings:  id
crs(outline_LiDAR_2018)
#CRS arguments: #+proj=utm +zone=32 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs
extent(outline_LiDAR_2018)


#transform the crs of landuse in Hessen
landuse_Hessen_trsfd <- spTransform(landuse_Hessen,
                                    crs(outline_LiDAR_2018))
crs(landuse_Hessen_trsfd)
#CRS arguments:
#+proj=utm +zone=32 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs

#crop landuse in Hessen to the outline of the LiDAR data from 2018
lu_HE_cropped<- crop(outline_LiDAR_2018, landuse_Hessen_trsfd)

#because the lu layer for Hessen is more than 1 GB in size, R struggles to cut the 180 km2s
#thus it was than in QGIS to make it quick and dirty...


 ####++FITLER THE LIDAR2018 OSM LANDUSE MAP FOR THE RELEVANT STRUCTURES++####

#load landuse LIDAR2018
landuse_LIDAR2018 <- readOGR(paste0(path_analysis_data_LiDAR_data, "LIDAR2018_landuseosm.shp"))
crs(landuse_LIDAR2018)
#CRS arguments: +proj=longlat +datum=WGS84 +no_defs

#reproject/transform the crs of LIDAR2018_lu_osm_repr
LIDAR2018_lu_osm_repr <- spTransform(landuse_LIDAR2018,
                                    crs(outline_LiDAR_2018))

#write out LIDAR2018_lu_osm_repr
rgdal::writeOGR(obj=LIDAR2018_lu_osm_repr, dsn = "E:/repRCHrs/analysis/data/LiDAR_data",
                layer ="LIDAR2018_lu_osm_repr", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)

#read it again for test
LIDAR2018_lu_osm_repr <- readOGR(paste0(path_analysis_data_LiDAR_data, "LIDAR2018_lu_osm_repr.shp"))

names(LIDAR2018_lu_osm_repr)
#[1] "osm_id" "code"   "fclass" "name"

#we can see in QGIS, that some building areas are not covered by the land-use map.
#There is around 10 % of the building are which is not mapped - it is OK;
#a lot faster this way than clicking it by yourself

#now we want to filter the land use layer to allotments, cemetery, commercial,
#farmyard, industrial, quarry, recreation_ground, residential and retail
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

rgdal::writeOGR(obj=LIDAR2018_lu_osm_repr_filt, dsn = "E:/repRCHrs/analysis/data/LiDAR_data",
                layer ="LIDAR2018_lu_osm_repr_filt", driver = "ESRI Shapefile",
                verbose = TRUE, overwrite_layer = TRUE)

                         ####++MERGE THE 2014 DTMS++####





tiff_list <- list.files(paste0(path_analysis_data_dtm2014), full.names = TRUE,
                        pattern = glob2rx("*.tif"))








# wd and paths

#wd <- ("E:/Lidar_Arch/basic_R_scr/merge_tif_folder")
#setwd(wd)

raster_in <- paste0(path_analysis_data_dtm2014)
raster_out <- paste0(path_analysis_data_dtm2014_merged)


# shorts and vars.

merged_raster <- ("DTM2014_mgrd")


# Build list of all raster files you want to join (in your current working directory).

raster_files <-  list.files(raster_in,
                            pattern = glob2rx("*.tif"),
                            full.names = TRUE)

all_my_rasts <- c(raster_files)


# Make a template raster file to build onto. Think of this a big blank canvas to add tiles to.

e <- extent(478000 , 488000, 5616000, 5634000)
template <- raster(e)
projection(template) <- '+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0'
writeRaster(template, file=paste0(raster_out, "/", merged_raster, ".tif"), format="GTiff")

# Merge all raster tiles into one big raster.
mosaic_rasters(gdalfile=all_my_rasts, dst_dataset=paste0(raster_out, "/", merged_raster, ".tif"), of="GTiff")


gdalinfo(merged_raster)


plot(merged_raster)


