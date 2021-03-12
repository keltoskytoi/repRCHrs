link2GI::linkAll()

initGRASS(gisBase = "C:/Program Files/GRASS GIS 7.9",
          gisDbase = "E:/repRCHrs/analysis/data/GRASS",
          location = "Init_project",
          mapset = "PERMANENT",
          gisdbase_exist = TRUE)

# set computational region to default (optional)
system("g.region -dp")
# verify metadata
gmeta()

system("g.mapsets  mapset=PERMANENT operation=add")
system("g.mapsets  mapset=Init_project operation=add")
system("g.list type=rast")

#Loading/Importing the cropped raster in Grass
rgrass7::execGRASS('r.import',
                   flags=c('o',"overwrite","quiet"),
                   input= "E:/repRCHrs/analysis/data/dtm2014/TEST_AREA/3dm_32482_5618_1_he_xyzirnc_ground_IDW01.tif",
                   output= "test_area_GRASS.tif"
)

##############CALCULATE A LOCAL RELIEF MODEL FROM THE CROPPED RASTER############
rgrass7::execGRASS(cmd = "r.local.relief",
                   flags = "overwrite",
                   input = "test_area_GRASS.tif@PERMANENT",
                   output = "test_area_LRM.tif")

rgrass7::execGRASS(cmd = 'r.out.gdal',
                   flags=c("m","f", "t","overwrite","verbose"),
                   input="test_area_LRM.tif@PERMANENT",
                   format="GTiff",
                   type="Float64",
                   output=paste0(path_analysis_data_dtm2014_iMound,"test_area_LRM.tif"))

LRM <- raster(paste0(path_output,"test_area_LRM.tif"))
plot(LRM)
raster::setMinMax(LRM)
summary(LRM)
