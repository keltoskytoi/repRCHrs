#load Hessen landuse
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

landuse_Hessen_trsfd <- spTransform(landuse_Hessen,
                                    crs(outline_LiDAR_2018))
crs(landuse_Hessen_trsfd)
#CRS arguments:
#+proj=utm +zone=32 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs


lu_HE_cropped<- crop(outline_LiDAR_2018, landuse_Hessen_trsfd)

writeOGR(lu_HE_cropped, paste0(path_analysis_data_LiDAR_data, "LiDAR_LU_cropped.shp"),
         driver = "ESRI Shapefile", verbose = TRUE)

names(landuse_Hessen)
#[1] "osm_id" "code"   "fclass" "name"
landuse_Hessen$fclass
str(landuse_Hessen)
