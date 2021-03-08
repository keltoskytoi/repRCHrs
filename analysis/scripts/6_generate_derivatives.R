#test area
test_area <- raster(paste0(path_analysis_data_dtm2014_TEST_AREA, lstestarea[[3]]))
test_area
#values     : 181.3, 259.38  (min, max)

#first locate the raster and map it
my_colors <- terrain.colors(79)
mapview::mapviewOptions(mapview.maxpixels = test_area@ncols*test_area@nrows/100)
mapview::mapview(test_area, col.regions = my_colors, legend = TRUE)

#as you can see you can see nothing! But we can see that the area is in the right
#spot!

#or:
plot(test_area,
     col = terrain.colors(200))

#Calculate multiple derivatives

#from the raster::terrain description:

#when neighbors=4, slope and aspect are computed according to Fleming and Hoffer
#(1979) and Ritter (1987); when neigbors=8, slope and aspect are computed according
#to Horn (1981). The Horn algorithm may be best for rough surfaces, and the
#Fleming and Hoffer algorithm may be better for smoother surfaces (Jones, 1997;
#Burrough and McDonnell, 1998).

#We do have a smooth surface, so: neighbors=4

#Slope
Slope<- raster::terrain(test_area, opt = "slope", unit="radians", neighbors = 4,
                        filename = "Slope.tif")
#Aspect
Aspect <- terrain(test_area, opt = "aspect", unit="degrees", neighbors = 4,
                          filename = "Aspect.tif")


#Local Relief Model
#1) DTM -> smoothing focal filte 25x25 m
#2) Difference Map: DTM - DTMsmoothed
#3) 0 meter contours on the difference model )=
con_tour <- rasterToContour(test_area)
plot(test_area)
plot(con_tour, add=TRUE)

#4) extract elevation from the original DTM along the elevation contours (extract by mask)
#= SER Simplified Elevation Raster

#5) SER to points

#6)TIN from 5)

#7) conversion of TIN (6) to a DTM
#8) DEM - 7)

initGRASS(gisBase = "C:/OSGeo4W64/apps/grass/grass78",
          gisDbase = "E:/repRCHrs/analysis/data/GRASS",
          location = "Init_project",
          mapset = "PERMANENT",
          SG="elevation",
          override = TRUE)

# set computational region to default (optional)
system("g.region -dp")
# verify metadata
gmeta()










## find all GRASS GIS installations at the default search location
grass <- link2GI::findGRASS()
print(grass)
#1                  C:/OSGEO4~1/bin            78           osgeo4W
#2 C:\\Program Files\\GRASS GIS 7.6 GRASS GIS 7.6              NSIS
#3 C:\\Program Files\\GRASS GIS 7.9 GRASS GIS 7.9              NSIS
#4         C:\\PROGRA~1\\QGIS2~1.18   grass-7.2.1           osgeo4W
#5       C:/PROGRA~1/QGIS3~1.12/bin            78           osgeo4W

#Loading/Importing the cropped raster in Grass
rgrass7::execGRASS('r.import',
                   input= "E:/repRCHrs/analysis/data/dtm2014/TEST_AREA/3dm_32482_5618_1_he_xyzirnc_ground_IDW01.tif",
                   output= "test_area_GRASS.tif",
                   flags=c("overwrite"))

##############CALCULATE A LOCAL RELIEF MODEL FROM THE CROPPED RASTER############

rgrass7::execGRASS(cmd = "r.local.relief",
                   flags = "overwrite",
                   input = "Duens_GRASS.tif@PERMANENT",
                   output = "Duens_LRM.tif")

rgrass7::execGRASS(cmd = 'r.out.gdal',
                   flags=c("m","f", "t","overwrite","verbose"),
                   input="Duens_LRM.tif@PERMANENT",
                   format="GTiff",
                   type="Float64",
                   output=paste0(path_output,"Duensberg_LRM.tif"))

LRM <- raster(paste0(path_output,"Duensberg_LRM.tif"))
plot(LRM)
raster::setMinMax(LRM)
summary(LRM)

