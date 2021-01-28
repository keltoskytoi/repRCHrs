#Packages in the library
library<-c("gdalUtils", "glcm","raster","rgdal", "mapview", "sp", "spData",
           "sf", "tools", "RStoolbox", "rgeos", "lattice", "ggplot2",
           "RColorBrewer", "signal", "rootSolve", "link2GI", "CAST",
           "caret", "doParallel", "data.table", "ggridges",
           "dplyr", "tidyverse", "hrbrthemes", "plyr", "ggridges",
           "plotly", "GGally", "rlas",  "lidR", "rLiDAR", "future",
           "ForestTools", "rrtools", "citr", "lidRplugins",
           "lidRviewer")

#Install CRAN packages if needed
inst <- library %in% installed.packages()
if(length(library[!inst]) > 0) install.packages(library[!inst])

#Load library packages into session if required
lapply(library, require, character.only=TRUE)

#+++checking GDAL installation on your computer#
gdalUtils::gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))
if(require(raster) && require(rgdal) && valid_install)
getGDALVersionInfo()





