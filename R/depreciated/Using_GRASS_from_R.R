#from: https://userwikis.fu-berlin.de/display/gis/2020/06/24/Grass%2C+R+and+rgrass7+and+its+problems

library(rgrass7)
use_sp()
osgeo4w.root<-"C:\\OSGEO4W64"
Sys.setenv(OSGEO4W_ROOT=osgeo4w.root)
# define GISBASE
grass.gis.base<-paste0(osgeo4w.root,"\\apps\\grass\\grass78")
Sys.setenv(GISBASE=grass.gis.base)

Sys.setenv(GRASS_PYTHON=paste0(Sys.getenv("OSGEO4W_ROOT"),"\\bin\\python.exe"))
Sys.setenv(PYTHONHOME=paste0(Sys.getenv("OSGEO4W_ROOT"),"\\apps\\Python37"))
Sys.setenv(PYTHONPATH=paste0(Sys.getenv("OSGEO4W_ROOT"),"\\apps\\grass\\grass78\\etc\\python"))
Sys.setenv(GRASS_PROJSHARE=paste0(Sys.getenv("OSGEO4W_ROOT"),"\\share\\proj"))
Sys.setenv(PROJ_LIB=paste0(Sys.getenv("OSGEO4W_ROOT"),"\\share\\proj"))
Sys.setenv(GDAL_DATA=paste0(Sys.getenv("OSGEO4W_ROOT"),"\\share\\gdal"))
Sys.setenv(GEOTIFF_CSV=paste0(Sys.getenv("OSGEO4W_ROOT"),"\\share\\epsg_csv"))
Sys.setenv(FONTCONFIG_FILE=paste0(Sys.getenv("OSGEO4W_ROOT"),"\\etc\\fonts.conf"))

# call all OSGEO4W settings
system("C:/OSGeo4W64/bin/o-help.bat")

# create PATH variable
Sys.setenv(PATH=paste0(grass.gis.base,";",
                       "C:\\OSGEO4~1\\apps\\Python37\\lib\\site-packages\\numpy\\core",";",
                       "C:\\OSGeo4W64\\apps\\grass\\grass78\\bin",";",
                       "C:\\OSGeo4W64\\apps\\grass\\grass78\\lib",";",
                       "C:\\OSGeo4W64\\apps\\grass\\grass78\\etc",";",
                       "C:\\OSGeo4W64\\apps\\grass\\grass78\\etc\\python",";",
                       "C:\\OSGeo4W64\\apps\\Python37\\Scripts",";",
                       "C:\\OSGeo4W64\\bin",";",
                       "c:\\OSGeo4W64\\apps",";",
                       "C:\\OSGEO4~1\\apps\\saga",";",
                       paste0(Sys.getenv("WINDIR"),"/WBem"),";",
                       Sys.getenv("PATH")))

# initial again to be sure
use_sp()

#create a location so you can start with grass tasks
loc <- rgrass7::initGRASS(gisBase=grass.gis.base,
                          home=tempdir(),
                          mapset='PERMANENT',
                          override=TRUE)
