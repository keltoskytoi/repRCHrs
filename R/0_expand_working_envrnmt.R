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

#+++ supplementing the folder structure of 'rrtools'
paths<-link2GI::initProj(projRootDir = projRootDir,
                         projFolders = c("analysis/data/dtm2014/TEST_AREA/",
                                         "analysis/data/dtm2014/TEST_AREA_repr/",
                                         "analysis/data/dtm2014/TEST_AREA_mrgd/",
                                         "analysis/data/dtm2014/AOI_1/",
                                         "analysis/data/dtm2014/AOI_1_repr/",
                                         "analysis/data/dtm2014/AOI_1_mrgd/",
                                         "analysis/data/dtm2014/AOI_1_rast/",
                                         "analysis/data/dtm2014/AOI_1_masked/",
                                         "analysis/data/dtm2014/AOI_2/",
                                          "analysis/data/dtm2014/AOI_2_repr/",
                                         "analysis/data/dtm2014/AOI_2_mrgd/",
                                         "analysis/data/dtm2014/AOI_2_rast/",
                                         "analysis/data/dtm2014/AOI_2_masked/",
                                         "analysis/data/dtm2014/AOI_3/",
                                         "analysis/data/dtm2014/AOI_3_repr/",
                                         "analysis/data/dtm2014/AOI_3_mrgd/",
                                         "analysis/data/dtm2014/AOI_3_rast/",
                                         "analysis/data/dtm2014/AOI_3_masked/",
                                         "analysis/data/dtm2014/AOI_4/",
                                         "analysis/data/dtm2014/AOI_4_repr/",
                                         "analysis/data/dtm2014/AOI_4_mrgd/",
                                         "analysis/data/dtm2014/AOI_4_rast/",
                                         "analysis/data/dtm2014/AOI_4_masked/",
                                         "analysis/data/dtm2014/AOI_5/",
                                         "analysis/data/dtm2014/AOI_5_repr/",
                                         "analysis/data/dtm2014/AOI_5_mrgd/",
                                         "analysis/data/dtm2014/AOI_5_rast/",
                                         "analysis/data/dtm2014/AOI_5_masked/",
                                         "analysis/data/dtm2014/iMound/",

                                         "analysis/data/dtm2018/AOI_1/",
                                         "analysis/data/dtm2018/AOI_1_repr/",
                                         "analysis/data/dtm2018/AOI_1_mrgd/",
                                         "analysis/data/dtm2018/AOI_2/",
                                         "analysis/data/dtm2018/AOI_2_repr/",
                                         "analysis/data/dtm2018/AOI_2_mrgd/",
                                         "analysis/data/dtm2018/AOI_3/",
                                         "analysis/data/dtm2018/AOI_3_repr/",
                                         "analysis/data/dtm2018/AOI_3_mrgd/",
                                         "analysis/data/dtm2018/AOI_4/",
                                         "analysis/data/dtm2018/AOI_4_repr/",
                                         "analysis/data/dtm2018/AOI_4_mrgd/",
                                         "analysis/data/dtm2018/AOI_5/",
                                         "analysis/data/dtm2018/AOI_5_repr/",
                                         "analysis/data/dtm2018/AOI_5_mrgd/",
                                         "analysis/data/barrows/",
                                         "analysis/data/LiDAR_info/",
                                         "analysis/scripts/depreciated",
                                         "analysis/qgis/",
                                         "R/", "man/", "tests/"),
                         global = TRUE,
                         path_prefix = "path_")

##+++ load library
#The source file enables you to install and activate packages in one run
source("E:/repRCHrs/R/00_library_n_prep.R")

#if not possible to install via 'install.packages()' please install via github:
devtools::install_github("benmarwick/rrtools")
devtools::install_github("crsh/citr")
devtools::install_github("Jean-Romain/rlas")
devtools::install_github("Jean-Romain/lidR")
BiocManager::install("EBImage")
remotes::install_github("Jean-Romain/lidRplugins")
#to install lidRviewer, first install the following R file:
#it may be possible that you have to reopen R as administrator to be able to
#install it, if R is under C: on Windows
source("https://raw.githubusercontent.com/Jean-Romain/lidRviewer/master/sdl.R")
devtools::install_github("Jean-Romain/lidRviewer")

#to be able to install uavRst you will need to install the packages'velox'
#and 'spatial.tools' from the CRAN archive from source
devtools::install_url('http://cran.r-project.org/src/contrib/Archive/spatial.tools/spatial.tools_1.6.2.tar.gz')
devtools::install_url('http://cran.r-project.org/src/contrib/Archive/velox/velox_0.2.0.tar.gz')
devtools::install_github("gisma/uavRst", ref = "master", dependencies = TRUE,
                         force = TRUE)

devtools::install_github("giswqs/whiteboxR")
devtools::install_github("jannes-m/RQGIS", force = TRUE)

devtools::install_github("crsh/citr")
#devtools::install_github("SchoenbergA/IKARUS")
#devtools::install_github("SchoenbergA/LEGION@develop", build_vignettes = TRUE)
#devtools::install_github("SchoenbergA/CENITH@develop")

#to add packages to the namespace & description:
rrtools::add_dependencies_to_description()

