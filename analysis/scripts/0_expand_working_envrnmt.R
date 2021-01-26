                                #+++PREPARATIONS+++#

#+++removing everything from R, to get a clear working environment
rm(list=ls())

#+++ preparing a system-independent environment
#please change the path to the projects library according to where you want to
#place the R project library on you computer!
if(Sys.info()["sysname"] == "Windows"){
  projRootDir <- "E:/repRCHrs/"
} else {
  projRootDir <- "/home/keltoskytoi/repRCHrs"
}

#+++ suplimenting the folder structure of rrtools
paths<-link2GI::initProj(projRootDir = projRootDir,
                         projFolders = c("analysis/scripts",
                                        "analysis/qgis",
                                         "R/", "man/", "tests/"),
                         global = TRUE,
                         path_prefix = "path_")

#if not possible to install via github please install:
devtools::install_github("gisma/uavRst", ref = "master", dependencies = TRUE, force = TRUE)
devtools::install_github("giswqs/whiteboxR")
devtools::install_github("jannes-m/RQGIS", force = TRUE)
devtools::install_github("Jean-Romain/rlas")
devtools::install_github("Jean-Romain/lidR")
devtools::install_github("Jean-Romain/PointCloudViewer")
devtools::install_github("crsh/citr")
devtools::install_github("SchoenbergA/IKARUS")
devtools::install_github("SchoenbergA/LEGION@develop", build_vignettes = TRUE)
devtools::install_github("SchoenbergA/CENITH@develop")

#to add pacages to the namespace & description:
rrtools::add_dependencies_to_description()

