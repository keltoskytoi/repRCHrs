###################################################################
###################################################################
#-----Burial mound extraction from LiDAR DEM-v-01------------------
###################################################################
###################################################################
#
#
#    The self-explanatory R script performs burial mound (tumuli) 
#    extraction from LiDAR DEM using 3 steps:
# 1. Based on a DEM, generates local peaks as elevation maxima
#    in 3x3 pixels kernel windows.
# 2. Based on the watershed maxima seeds of local convexity
#    select only the peak that have a seed in a 3x3 pixels kernel
#    windows proximity.
# 3. Based on geomorphometric variables computed for watershed 
#    maxima segments applyes a randomForest model for burial
#    mounds detection.
# The script can be used as it is to replicate the data from the
# paper submitted to Sensors journal. In this state, two study 
# areas are used: northern study area used for model fitting 
# (dem1.asc & burial_mounds1.shp) and the southern study area 
# (dem2.asc & burial_mounds2.shp) is used for validation.
# REQUIRED DATA: DEM in .asc format and .shp with the delineated
#    mound and other mounds as polygons, having TYPE and 
#    integer unique ID attribute fields.
# !For running on you own study area, at least a DEM and several
# delineated tumuli must be given. 
#
###################################################################
#------Set working directory---------------------------------------
#------Please edit the code for you working directory--------------
###################################################################
wd=c("f:/zenodo_final/")
setwd(wd)
###################################################################
#------Install necessary packages----------------------------------
###################################################################
#--function taken from: https://gist.github.com/smithdanielle/9913897
# check.packages function: install and load multiple R packages.
# Check to see if packages are installed. Install them if they are not,
# then load them into the R session.
check.packages <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}
packages<-c("sp","rgdal","maptools","raster","RSAGA","randomForest",
            "dplyr","clhs","akima","randomForestExplainer", "randomForestSRC",
            "caret", "Boruta")
check.packages(packages)
library(sp)
library(rgdal)
library(maptools)
library(raster)
library(RSAGA)
library(randomForest)
library(dplyr)
library(clhs)
library(akima)
library(randomForestExplainer)
library(randomForestSRC)
library(caret)
library(Boruta)
#--function taken from: https://rdrr.io/cran/randomForestSRC/man/tune.rfsrc.html
## to visualize the nodesize/mtry OOB surface; needs akima package
plot.tune <- function(o, linear = TRUE) {
  x <- o$results[,1]
  y <- o$results[,2]
  z <- o$results[,3]
  so <- interp(x=x, y=y, z=z, linear = linear)
  idx <- which.min(z)
  x0 <- x[idx]
  y0 <- y[idx]
  filled.contour(x = so$x,
                 y = so$y,
                 z = so$z,
                 xlim = range(so$x, finite = TRUE) + c(-2, 2),
                 ylim = range(so$y, finite = TRUE) + c(-2, 2),
                 color.palette =
                   colorRampPalette(c("yellow", "red")),
                 xlab = "nodesize",
                 ylab = "mtry",
                 main = "OOB error for nodesize and mtry",
                 key.title = title(main = "OOB error", cex.main = 1),
                 plot.axes = {axis(1);axis(2);points(x0,y0,pch="x",cex=1,font=2);
                   points(x,y,pch=16,cex=.25)})
}
###################################################################
#------see and set set the memory limit & digits-------------------
###################################################################
memory.limit()
options("scipen"=100, "digits"=22)
###################################################################
#------set SAGA environment----------------------------------------
###################################################################
#--ussually is best to move a SAGA binary package to RSAGA folder from the library
#--v 7.0.0 maximum
myenv <- rsaga.env(workspace=wd,
                   path="C:/Users/Mihai/Documents/R/win-library/3.6/RSAGA/SAGA-GIS",
                   modules="C:/Users/Mihai/Documents/R/win-library/3.6/RSAGA/SAGA-GIS/tools")
###################################################################
#------read the DEM------------------------------------------
###################################################################
r=sp::read.asciigrid("dem.asc")
rr=raster::raster(r)
###################################################################
#------compute local peaks-----------------------------------------
###################################################################
#3x3 focal filters for pixels
f1=raster::focal(rr, w=matrix(c(1,0,0,0,0,0,0,0,0), nc=3, nr=3), fun=max)
f2=raster::focal(rr, w=matrix(c(0,1,0,0,0,0,0,0,0), nc=3, nr=3), fun=max)
f3=raster::focal(rr, w=matrix(c(0,0,1,0,0,0,0,0,0), nc=3, nr=3), fun=max)
f4=raster::focal(rr, w=matrix(c(0,0,0,1,0,0,0,0,0), nc=3, nr=3), fun=max)
f6=raster::focal(rr, w=matrix(c(0,0,0,0,0,1,0,0,0), nc=3, nr=3), fun=max)
f7=raster::focal(rr, w=matrix(c(0,0,0,0,0,0,1,0,0), nc=3, nr=3), fun=max)
f8=raster::focal(rr, w=matrix(c(0,0,0,0,0,0,0,1,0), nc=3, nr=3), fun=max)
f9=raster::focal(rr, w=matrix(c(0,0,0,0,0,0,0,0,1), nc=3, nr=3), fun=max)
peaks_function <- function(a,b,c,d,e,f,g,h,i) {
  ifelse(a<=e,
         ifelse(b<=e,
                ifelse(c<=e,
                       ifelse(d<=e,
                              ifelse(f<=e,
                                     ifelse(g<=e,
                                            ifelse(h<=e,
                                                   ifelse(i<=e,1,0),0),0),0),0),0),0),0)
}
peaks=raster::overlay(f1,f2,f3,f4,rr,f6,f7,f8,f9, fun=peaks_function, forcefun=TRUE)
raster::writeRaster(peaks, filename="peaks.asc", overwrite=TRUE)
#--check tumuli versus peaks
rsaga.geoprocessor("shapes_grid", 2 ,env=myenv,list(					
  GRIDS=paste(wd,"peaks.asc", sep=""), POLYGONS=paste(wd,"burial_mounds.shp", sep=""), 
  NAMING=1, METHOD=0, RESULT=paste(wd,"burial_mounds.shp", sep=""), 
  COUNT=0, MIN=0, MAX=1, RANGE=0, SUM=0, MEAN=0, VAR=0, STDDEV=0, QUANTILE=0, GINI=0))
shape <- rgdal::readOGR("burial_mounds.shp", "burial_mounds", verbose=TRUE)
#--0 are tumuli without peaks, while 1 are tumuli with peaks
table(shape@data$TYPE, shape@data$peaks..MAX.)
###################################################################
#------local convexity---------------------------------------------
###################################################################
#--local convexity counting method
rsaga.geoprocessor("ta_morphometry", 21, env=myenv,list(					
  DEM=paste(wd,"dem.asc", sep=""), CONVEXITY=paste(wd,"conv_c.sgrd", sep=""), 
  KERNEL=1, TYPE=0, EPSILON=0, SCALE=2, METHOD=0, DW_WEIGHTING=0))
#--local convexity resampling method
rsaga.geoprocessor("ta_morphometry", 21, env=myenv,list(					
  DEM=paste(wd,"dem.asc", sep=""), CONVEXITY=paste(wd,"conv_r.sgrd", sep=""), 
  KERNEL=1, TYPE=0, EPSILON=0, SCALE=2, METHOD=1, DW_WEIGHTING=0))
###################################################################
#------watershed segmentation--------------------------------------
###################################################################
rsaga.geoprocessor("imagery_segmentation", 0, env=myenv,list(					
  GRID=paste(wd,"conv_c.sgrd", sep=""), SEGMENTS=paste(wd,"segment_garbage.sgrd", sep=""), 
  SEEDS=paste(wd,"seeds.shp", sep=""), OUTPUT=0, DOWN=1, EDGE=0, BBORDERS=0))
rsaga.geoprocessor("imagery_segmentation", 0, env=myenv,list(					
  GRID=paste(wd,"conv_r.sgrd", sep=""), SEGMENTS=paste(wd,"conv_segments.sgrd", sep=""), 
  SEEDS=paste(wd,"seeds1.shp", sep=""), OUTPUT=0, DOWN=1, EDGE=0, BBORDERS=0))
###################################################################
#------seeds as rasters-------------------------------------------
###################################################################
rsaga.geoprocessor("grid_gridding", 0, env=myenv,list(					
  INPUT=paste(wd,"seeds.shp", sep=""), FIELD="VALUE", OUTPUT=0, MULTIPLE=0, 
  GRID_TYPE=9, TARGET_DEFINITION=1, TARGET_TEMPLATE=paste(wd,"conv_r.sgrd", sep=""), 
  GRID=paste(wd,"seeds.sgrd", sep="")))
###################################################################
#------export as ascii---------------------------------------------
###################################################################
rsaga.geoprocessor("io_grid", 0, env=myenv,list(					
  GRID=paste(wd,"seeds.sgrd", sep=""), FILE=paste(wd,"seeds.asc", sep=""), 
  FORMAT=1, GEOREF=0, PREC=1))
###################################################################
#------segments as polygons----------------------------------------
###################################################################
rsaga.geoprocessor("shapes_grid", 6, env=myenv,list(					
  GRID=paste(wd,"conv_segments.sgrd", sep=""), 
  POLYGONS=paste(wd,"conv_segments.shp", sep=""), 
  CLASS_ALL=1, SPLIT=1))
###################################################################
#------compute shape index-----------------------------------------
###################################################################
rsaga.geoprocessor("shapes_polygons", 7, env=myenv,list(					
  SHAPES=paste(wd,"conv_segments.shp", sep=""), 
  INDEX=paste(wd,"conv_segments.shp", sep=""), 
  GYROS=1, FERET=1, FERET_DIRS=18))
###################################################################
#------convergence index---------------------------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 2, env=myenv,list(					
  ELEVATION=paste(wd,"dem.asc", sep=""), CONVERGENCE=paste(wd,"ioc.sgrd", sep=""), 
  RADIUS=5, DISTANCE_WEIGHTING_DW_WEIGHTING=0, SLOPE=1, DIFFERENCE=0))
###################################################################
#------compute negative openess------------------------------------
###################################################################
rsaga.geoprocessor("ta_lighting", 5, env=myenv,list(					
  DEM=paste(wd,"dem.asc", sep=""), NEG=paste(wd,"nego.sgrd", sep=""),
  RADIUS=100, METHOD=0, DLEVEL=3, NDIRS=8))
###################################################################
#------compute slope and curvatures--------------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 23, env=myenv,list(					
  DEM=paste(wd,"dem.asc", sep=""), SLOPE=paste(wd,"slop.sgrd", sep=""),
  PROFC=paste(wd,"proc.sgrd", sep=""), PLANC=paste(wd,"plac.sgrd", sep=""),
  LONGC=paste(wd,"logc.sgrd", sep=""), CROSC=paste(wd,"croc.sgrd", sep=""),
  MINIC=paste(wd,"minc.sgrd", sep=""), MAXIC=paste(wd,"maxc.sgrd", sep=""),
  SIZE=2, CONSTRAIN=1))
###################################################################
#------compute real area-------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 6, env=myenv,list(					
  DEM=paste(wd,"dem.asc", sep=""), AREA=paste(wd,"rare.sgrd", sep="")))
###################################################################
#------compute wind exposition index-------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 27, env=myenv,list(					
  DEM=paste(wd,"dem.asc", sep=""), EXPOSITION=paste(wd,"wind.sgrd", sep=""),
  MAXDIST=0.1, STEP=15, OLDVER=0, ACCEL=1.5, PYRAMIDS=0))
###################################################################
#------compute topographic position index-------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 28, env=myenv,list(					
  DEM=paste(wd,"dem.asc", sep=""), TPI=paste(wd,"tpi.sgrd", sep=""),
  SCALE_MIN=1, SCALE_MAX=8, SCALE_NUM=8))
###################################################################
#------compute valley depth----------------------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 14, env=myenv,list(					
  DEM=paste(wd,"dem.asc", sep=""), HU=paste(wd,"vld.sgrd", sep="")))
###################################################################
#------compute morphometric protection index-----------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 7, env=myenv,list(					
  DEM=paste(wd,"dem.asc", sep=""), PROTECTION=paste(wd,"mpi.sgrd", sep=""), RADIUS=100))
###################################################################
#------compute terrain ruggedness index----------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 16, env=myenv,list(					
  DEM=paste(wd,"dem.asc", sep=""), TRI=paste(wd,"tri.sgrd", sep=""),
  MODE=1, RADIUS=2))
###################################################################
#------compute vector ruggedness measure---------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 17, env=myenv,list(					
  DEM=paste(wd,"dem.asc", sep=""), VRM=paste(wd,"vrm.sgrd", sep=""),
  MODE=1, RADIUS=2))
###################################################################
#------compute terrain surface texture-------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 20, env=myenv,list(					
  DEM=paste(wd,"dem.asc", sep=""), TEXTURE=paste(wd,"txt.sgrd", sep=""),
  EPSILON=0, SCALE=2, METHOD=1))
###################################################################
#------compute upslope/downslope-----------------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 26, env=myenv,list(					
  DEM=paste(wd,"dem.asc", sep=""), C_LOCAL=paste(wd,"clo.sgrd", sep=""), 
  C_UP=paste(wd,"cup.sgrd", sep=""), C_UP_LOCAL=paste(wd,"clu.sgrd", sep=""),
  C_DOWN=paste(wd,"cdo.sgrd", sep=""), C_DOWN_LOCAL=paste(wd,"cdl.sgrd", sep="")))
###################################################################
#------compute flow accumulation-----------------------------------
###################################################################
rsaga.geoprocessor("ta_hydrology", 1, env=myenv,list(					
  ELEVATION=paste(wd,"dem.asc", sep=""), FLOW=paste(wd,"flo.sgrd", sep=""),
  FLOW_UNIT=0, METHOD=3))
###################################################################
#------compute flow path length-------------------------
###################################################################
rsaga.geoprocessor("ta_hydrology", 6, env=myenv,list(					
  ELEVATION=paste(wd,"dem.asc", sep=""), LENGTH=paste(wd,"fpl.sgrd", sep=""),
  METHOD=1))
###################################################################
#------compute slope length----------------------------------------
###################################################################
rsaga.geoprocessor("ta_hydrology", 7, env=myenv,list(					
  DEM=paste(wd,"dem.asc", sep=""), LENGTH=paste(wd,"spl.sgrd", sep="")))
###################################################################
#------compute cell balance----------------------------------------
###################################################################
rsaga.geoprocessor("ta_hydrology", 10, env=myenv,list(					
  DEM=paste(wd,"dem.asc", sep=""), BALANCE=paste(wd,"cbl.sgrd", sep=""),
  METHOD=1))
###################################################################
#------compute SAGA Wetness Index-----------------------------------
###################################################################
rsaga.geoprocessor("ta_hydrology", 15, env=myenv,list(					
  DEM=paste(wd,"dem.asc", sep=""), TWI=paste(wd,"twi.sgrd", sep="")))
###################################################################
#------geomorphometry statistics-----------------------------------
###################################################################
rsaga.geoprocessor("shapes_grid", 2 ,env=myenv,list(					
  GRIDS=paste(paste(wd,"dem.asc", sep=""),paste(wd,"ioc.sgrd", sep=""),
              paste(wd,"conv_r.sgrd", sep=""),paste(wd,"nego.sgrd", sep=""),
              paste(wd,"slop.sgrd", sep=""),paste(wd,"proc.sgrd", sep=""),
              paste(wd,"plac.sgrd", sep=""),paste(wd,"logc.sgrd", sep=""),
              paste(wd,"croc.sgrd", sep=""),paste(wd,"minc.sgrd", sep=""),
              paste(wd,"maxc.sgrd", sep=""),paste(wd,"rare.sgrd", sep=""),
              paste(wd,"wind.sgrd", sep=""),paste(wd,"tpi.sgrd", sep=""),
              paste(wd,"vld.sgrd", sep=""),paste(wd,"mpi.sgrd", sep=""),
              paste(wd,"tri.sgrd", sep=""),paste(wd,"vrm.sgrd", sep=""),
              paste(wd,"txt.sgrd", sep=""),paste(wd,"clo.sgrd", sep=""),
              paste(wd,"cup.sgrd", sep=""),paste(wd,"clu.sgrd", sep=""),
              paste(wd,"cdo.sgrd", sep=""),paste(wd,"cdl.sgrd", sep=""),
              paste(wd,"flo.sgrd", sep=""),paste(wd,"fpl.sgrd", sep=""),
              paste(wd,"spl.sgrd", sep=""),paste(wd,"cbl.sgrd", sep=""),
              paste(wd,"twi.sgrd", sep=""), sep=";"), 
  POLYGONS=paste(wd,"conv_segments.shp", sep=""), 
  NAMING=1, METHOD=0, RESULT=paste(wd,"conv_segments.shp", sep=""), 
  COUNT=0, MIN=1, MAX=1, RANGE=1, SUM=1, MEAN=1, VAR=1, STDDEV=1, QUANTILE=5, GINI=0))
################
#--selectie peaks seeds
#--read seed raster
pp=sp::read.asciigrid("peaks.asc")
pp=raster::raster(pp)
pp[is.na(pp[])] <- 0
#--citeste rasterul seeds
ss=sp::read.asciigrid("seeds.asc")
ss=raster::raster(ss)
#--replace NAs with 0
ss[is.na(ss[])] <- 0
#--select peaks that overlay seeds, or seeds which are in a 3x3 quen case neighborhood
#3x3 focal filters for neighbour pixels
pf1=raster::focal(ss, w=matrix(c(1,0,0,0,0,0,0,0,0), nc=3, nr=3), fun=max)
pf2=raster::focal(ss, w=matrix(c(0,1,0,0,0,0,0,0,0), nc=3, nr=3), fun=max)
pf3=raster::focal(ss, w=matrix(c(0,0,1,0,0,0,0,0,0), nc=3, nr=3), fun=max)
pf4=raster::focal(ss, w=matrix(c(0,0,0,1,0,0,0,0,0), nc=3, nr=3), fun=max)
pf6=raster::focal(ss, w=matrix(c(0,0,0,0,0,1,0,0,0), nc=3, nr=3), fun=max)
pf7=raster::focal(ss, w=matrix(c(0,0,0,0,0,0,1,0,0), nc=3, nr=3), fun=max)
pf8=raster::focal(ss, w=matrix(c(0,0,0,0,0,0,0,1,0), nc=3, nr=3), fun=max)
pf9=raster::focal(ss, w=matrix(c(0,0,0,0,0,0,0,0,1), nc=3, nr=3), fun=max)
#--si au aceeasi valoare seed
ft <- function(a,b,c,d,e,f,g,h,i,j) {
  ifelse(a==1&b==1,1,
         ifelse(a==1&c==1,1,
                ifelse(a==1&d==1,1,
                       ifelse(a==1&e==1,1,
                              ifelse(a==1&f==1,1,
                                     ifelse(a==1&g==1,1,
                                            ifelse(a==1&h==1,1,
                                                   ifelse(a==1&i==1,1,
                                                          ifelse(a==1&j==1,1,0)))))))))
}
pksf3=overlay(pp,ss,pf1,pf2,pf3,pf4,pf6,pf7,pf8,pf9, fun=ft, forcefun=TRUE)
raster::writeRaster(pksf3, filename="selected_peaks.asc", overwrite=TRUE)
#--check the tumuli and selected peaks
rsaga.geoprocessor("shapes_grid", 2 ,env=myenv,list(					
  GRIDS=paste(wd,"selected_peaks.asc", sep=""), POLYGONS=paste(wd,"burial_mounds.shp", sep=""), 
  NAMING=1, METHOD=0, RESULT=paste(wd,"burial_mounds.shp", sep=""), 
  COUNT=0, MIN=0, MAX=1, RANGE=0, SUM=0, MEAN=0, VAR=0, STDDEV=0, QUANTILE=0, GINI=0))
shape <- rgdal::readOGR("burial_mounds.shp", "burial_mounds", verbose=TRUE)
table(shape@data$TYPE, shape@data$selected_pe)
#--flag the segments with selected peaks
rsaga.geoprocessor("shapes_grid", 2 ,env=myenv,list(					
  GRIDS=paste(wd,"selected_peaks.asc", sep=""), POLYGONS=paste(wd,"conv_segments.shp", sep=""), 
  NAMING=1, METHOD=0, RESULT=paste(wd,"conv_segments.shp", sep=""), 
  COUNT=0, MIN=0, MAX=1, RANGE=0, SUM=0, MEAN=0, VAR=0, STDDEV=0, QUANTILE=0, GINI=0))
###################################################################
#------flag lakes or other things---------------------------------
###################################################################
#--rasterize the lakes layer
rsaga.geoprocessor("grid_gridding", 0, env=myenv,list(					
  INPUT=paste(wd,"lakes.shp", sep=""), FIELD="ID", OUTPUT=0, MULTIPLE=0, 
  GRID_TYPE=9, TARGET_DEFINITION=1, TARGET_TEMPLATE=paste(wd,"conv_r.sgrd", sep=""), 
  GRID=paste(wd,"lakes.sgrd", sep="")))
#--transfer lake presence
rsaga.geoprocessor("shapes_grid", 2 ,env=myenv,list(					
  GRIDS=paste(wd,"lakes.sgrd", sep=""), POLYGONS=paste(wd,"conv_segments.shp", sep=""), 
  NAMING=1, METHOD=0, RESULT=paste(wd,"conv_segments.shp", sep=""), 
  COUNT=0, MIN=0, MAX=1, RANGE=0, SUM=0, MEAN=0, VAR=0, STDDEV=0, QUANTILE=0, GINI=0))
#--rasterize the dam layer
rsaga.geoprocessor("grid_gridding", 0, env=myenv,list(					
  INPUT=paste(wd,"dams.shp", sep=""), FIELD="ID", OUTPUT=0, MULTIPLE=0, GRID_TYPE=9, 
  TARGET_DEFINITION=1, TARGET_TEMPLATE=paste(wd,"conv_r.sgrd", sep=""), GRID=paste(wd,"dams.sgrd", sep="")))
#--transfer dam presence
rsaga.geoprocessor("shapes_grid", 2 ,env=myenv,list(					
  GRIDS=paste(wd,"dams.sgrd", sep=""), POLYGONS=paste(wd,"conv_segments.shp", sep=""), 
  NAMING=1, METHOD=0, RESULT=paste(wd,"conv_segments.shp", sep=""), 
  COUNT=0, MIN=0, MAX=1, RANGE=0, SUM=0, MEAN=0, VAR=0, STDDEV=0, QUANTILE=0, GINI=0))
#--rasterize the embankment layer
rsaga.geoprocessor("grid_gridding", 0, env=myenv,list(					
  INPUT=paste(wd,"embankments.shp", sep=""), FIELD="ID", OUTPUT=0, MULTIPLE=0, GRID_TYPE=9, 
  TARGET_DEFINITION=1, TARGET_TEMPLATE=paste(wd,"conv_r.sgrd", sep=""), GRID=paste(wd,"embankments.sgrd", sep="")))
#--transfer embankment presence
rsaga.geoprocessor("shapes_grid", 2 ,env=myenv,list(					
  GRIDS=paste(wd,"embankments.sgrd", sep=""), POLYGONS=paste(wd,"conv_segments.shp", sep=""), 
  NAMING=1, METHOD=0, RESULT=paste(wd,"conv_segments.shp", sep=""), 
  COUNT=0, MIN=0, MAX=1, RANGE=0, SUM=0, MEAN=0, VAR=0, STDDEV=0, QUANTILE=0, GINI=0))
###################################################################
#------flag the tumuli segments------------------------------------
###################################################################
#--get the tumuli centroids
rsaga.geoprocessor("shapes_polygons", 1, env=myenv,list(					
  POLYGONS=paste(wd,"burial_mounds.shp", sep=""), 
  CENTROIDS=paste(wd,"burial_mounds_centroids.shp", sep="")))
#--rasterize the centroids
rsaga.geoprocessor("grid_gridding", 0, env=myenv,list(					
  INPUT=paste(wd,"burial_mounds_centroids.shp", sep=""), 
  FIELD="ID", OUTPUT=0, MULTIPLE=0, GRID_TYPE=9, 
  TARGET_DEFINITION=1, TARGET_TEMPLATE=paste(wd,"conv_r.sgrd", sep=""), 
  GRID=paste(wd,"centroids.sgrd", sep="")))
#--transfer centroid presence
rsaga.geoprocessor("shapes_grid", 2 ,env=myenv,list(					
  GRIDS=paste(wd,"centroids.sgrd", sep=""), 
  POLYGONS=paste(wd,"conv_segments.shp", sep=""), 
  NAMING=1, METHOD=0, RESULT=paste(wd,"conv_segments.shp", sep=""), 
  COUNT=0, MIN=0, MAX=1, RANGE=0, SUM=0, MEAN=0, VAR=0, STDDEV=0, 
  QUANTILE=0, GINI=0))
##################################################################################################
##################################################################################################
#------prepare exterior testing study area---------
##################################################################################################
###################################################################
#------read the DEM------------------------------------------
###################################################################
rt=sp::read.asciigrid("dem1.asc")
rrt=raster::raster(rt)
###################################################################
#------compute local peaks-----------------------------------------
###################################################################
#3x3 focal filters for pixels
f1t=raster::focal(rrt, w=matrix(c(1,0,0,0,0,0,0,0,0), nc=3, nr=3), fun=max)
f2t=raster::focal(rrt, w=matrix(c(0,1,0,0,0,0,0,0,0), nc=3, nr=3), fun=max)
f3t=raster::focal(rrt, w=matrix(c(0,0,1,0,0,0,0,0,0), nc=3, nr=3), fun=max)
f4t=raster::focal(rrt, w=matrix(c(0,0,0,1,0,0,0,0,0), nc=3, nr=3), fun=max)
f6t=raster::focal(rrt, w=matrix(c(0,0,0,0,0,1,0,0,0), nc=3, nr=3), fun=max)
f7t=raster::focal(rrt, w=matrix(c(0,0,0,0,0,0,1,0,0), nc=3, nr=3), fun=max)
f8t=raster::focal(rrt, w=matrix(c(0,0,0,0,0,0,0,1,0), nc=3, nr=3), fun=max)
f9t=raster::focal(rrt, w=matrix(c(0,0,0,0,0,0,0,0,1), nc=3, nr=3), fun=max)
peakst=raster::overlay(f1t,f2t,f3t,f4t,rrt,f6t,f7t,f8t,f9t, fun=peaks_function, forcefun=TRUE)
raster::writeRaster(peakst, filename="peaks1.asc", overwrite=TRUE)
#--check tumuli versus peaks
rsaga.geoprocessor("shapes_grid", 2 ,env=myenv,list(					
  GRIDS=paste(wd,"peaks1.asc", sep=""), POLYGONS=paste(wd,"burial_mounds1.shp", sep=""), 
  NAMING=1, METHOD=0, RESULT=paste(wd,"burial_mounds1.shp", sep=""), 
  COUNT=0, MIN=0, MAX=1, RANGE=0, SUM=0, MEAN=0, VAR=0, STDDEV=0, QUANTILE=0, GINI=0))
shapet <- rgdal::readOGR("burial_mounds1.shp", "burial_mounds1", verbose=TRUE)
#--0 are tumuli without peaks, while 1 are tumuli with peaks
table(shapet@data$TYPE, shapet@data$peaks1..MAX)
###################################################################
#------local convexity---------------------------------------------
###################################################################
#--local convexity counting method
rsaga.geoprocessor("ta_morphometry", 21, env=myenv,list(					
  DEM=paste(wd,"dem1.asc", sep=""), CONVEXITY=paste(wd,"conv_c1.sgrd", sep=""), 
  KERNEL=1, TYPE=0, EPSILON=0, SCALE=2, METHOD=0, DW_WEIGHTING=0))
#--local convexity resampling method
rsaga.geoprocessor("ta_morphometry", 21, env=myenv,list(					
  DEM=paste(wd,"dem1.asc", sep=""), CONVEXITY=paste(wd,"conv_r1.sgrd", sep=""), 
  KERNEL=1, TYPE=0, EPSILON=0, SCALE=2, METHOD=1, DW_WEIGHTING=0))
###################################################################
#------watershed segmentation--------------------------------------
###################################################################
rsaga.geoprocessor("imagery_segmentation", 0, env=myenv,list(					
  GRID=paste(wd,"conv_c1.sgrd", sep=""), SEGMENTS=paste(wd,"segments_garbage1.sgrd", sep=""), 
  SEEDS=paste(wd,"seeds2.shp", sep=""), OUTPUT=0, DOWN=1, EDGE=0, BBORDERS=0))
rsaga.geoprocessor("imagery_segmentation", 0, env=myenv,list(					
  GRID=paste(wd,"conv_r1.sgrd", sep=""), SEGMENTS=paste(wd,"conv_segments1.sgrd", sep=""), 
  SEEDS=paste(wd,"seeds_garbage1.shp", sep=""), OUTPUT=0, DOWN=1, EDGE=0, BBORDERS=0))
###################################################################
#------seeds as rasters-------------------------------------------
###################################################################
rsaga.geoprocessor("grid_gridding", 0, env=myenv,list(					
  INPUT=paste(wd,"seeds2.shp", sep=""), FIELD="VALUE", OUTPUT=0, MULTIPLE=0, GRID_TYPE=9, 
  TARGET_DEFINITION=1, TARGET_TEMPLATE=paste(wd,"conv_r1.sgrd", sep=""), GRID=paste(wd,"seeds1.sgrd", sep="")))
###################################################################
#------export as ascii---------------------------------------------
###################################################################
rsaga.geoprocessor("io_grid", 0, env=myenv,list(					
  GRID=paste(wd,"seeds1.sgrd", sep=""), FILE=paste(wd,"seeds1.asc", sep=""), FORMAT=1,
  GEOREF=0, PREC=1))
###################################################################
#------segments as polygons----------------------------------------
###################################################################
rsaga.geoprocessor("shapes_grid", 6, env=myenv,list(					
  GRID=paste(wd,"conv_segments1.sgrd", sep=""), POLYGONS=paste(wd,"conv_segments1.shp", sep=""), 
  CLASS_ALL=1, SPLIT=1))
###################################################################
#------compute shape index-----------------------------------------
###################################################################
rsaga.geoprocessor("shapes_polygons", 7, env=myenv,list(					
  SHAPES=paste(wd,"conv_segments1.shp", sep=""), 
  INDEX=paste(wd,"conv_segments1.shp", sep=""),
  GYROS=1, FERET=1, FERET_DIRS=18))
###################################################################
#------convergence index---------------------------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 2, env=myenv,list(					
  ELEVATION=paste(wd,"dem1.asc", sep=""), CONVERGENCE=paste(wd,"ioc1.sgrd", sep=""), 
  RADIUS=5, DISTANCE_WEIGHTING_DW_WEIGHTING=0, SLOPE=1, DIFFERENCE=0))
###################################################################
#------compute negative openess------------------------------------
###################################################################
rsaga.geoprocessor("ta_lighting", 5, env=myenv,list(					
  DEM=paste(wd,"dem1.asc", sep=""), NEG=paste(wd,"nego1.sgrd", sep=""),
  RADIUS=100, METHOD=0, DLEVEL=3, NDIRS=8))
###################################################################
#------compute slope and curvatures--------------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 23, env=myenv,list(					
  DEM=paste(wd,"dem1.asc", sep=""), SLOPE=paste(wd,"slop1.sgrd", sep=""),
  PROFC=paste(wd,"proc1.sgrd", sep=""), PLANC=paste(wd,"plac1.sgrd", sep=""),
  LONGC=paste(wd,"logc1.sgrd", sep=""), CROSC=paste(wd,"croc1.sgrd", sep=""),
  MINIC=paste(wd,"minc1.sgrd", sep=""), MAXIC=paste(wd,"maxc1.sgrd", sep=""),
  SIZE=2, CONSTRAIN=1))
###################################################################
#------compute real area-------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 6, env=myenv,list(					
  DEM=paste(wd,"dem1.asc", sep=""), AREA=paste(wd,"rare1.sgrd", sep="")))
###################################################################
#------compute wind exposition index-------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 27, env=myenv,list(					
  DEM=paste(wd,"dem1.asc", sep=""), EXPOSITION=paste(wd,"wind1.sgrd", sep=""),
  MAXDIST=0.1, STEP=15, OLDVER=0, ACCEL=1.5, PYRAMIDS=0))
###################################################################
#------compute topographic position index-------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 28, env=myenv,list(					
  DEM=paste(wd,"dem1.asc", sep=""), TPI=paste(wd,"tpi1.sgrd", sep=""),
  SCALE_MIN=1, SCALE_MAX=8, SCALE_NUM=8))
###################################################################
#------compute valley depth----------------------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 14, env=myenv,list(					
  DEM=paste(wd,"dem1.asc", sep=""), HU=paste(wd,"vld1.sgrd", sep="")))
###################################################################
#------compute morphometric protection index-----------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 7, env=myenv,list(					
  DEM=paste(wd,"dem1.asc", sep=""), PROTECTION=paste(wd,"mpi1.sgrd", sep=""), RADIUS=100))
###################################################################
#------compute terrain ruggedness index----------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 16, env=myenv,list(					
  DEM=paste(wd,"dem1.asc", sep=""), TRI=paste(wd,"tri1.sgrd", sep=""),
  MODE=1, RADIUS=2))
###################################################################
#------compute vector ruggedness measure---------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 17, env=myenv,list(					
  DEM=paste(wd,"dem1.asc", sep=""), VRM=paste(wd,"vrm1.sgrd", sep=""),
  MODE=1, RADIUS=2))
###################################################################
#------compute terrain surface texture-------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 20, env=myenv,list(					
  DEM=paste(wd,"dem1.asc", sep=""), TEXTURE=paste(wd,"txt1.sgrd", sep=""),
  EPSILON=0, SCALE=2, METHOD=1))
###################################################################
#------compute upslope/downslope-----------------------------------
###################################################################
rsaga.geoprocessor("ta_morphometry", 26, env=myenv,list(					
  DEM=paste(wd,"dem1.asc", sep=""), C_LOCAL=paste(wd,"clo1.sgrd", sep=""), 
  C_UP=paste(wd,"cup1.sgrd", sep=""), C_UP_LOCAL=paste(wd,"clu1.sgrd", sep=""),
  C_DOWN=paste(wd,"cdo1.sgrd", sep=""), C_DOWN_LOCAL=paste(wd,"cdl1.sgrd", sep=""),
  WEIGHTING=0.5))
###################################################################
#------compute flow accumulation-----------------------------------
###################################################################
rsaga.geoprocessor("ta_hydrology", 1, env=myenv,list(					
  ELEVATION=paste(wd,"dem1.asc", sep=""), FLOW=paste(wd,"flo1.sgrd", sep=""),
  FLOW_UNIT=0, METHOD=3))
###################################################################
#------compute flow path length-------------------------
###################################################################
rsaga.geoprocessor("ta_hydrology", 6, env=myenv,list(					
  ELEVATION=paste(wd,"dem1.asc", sep=""), LENGTH=paste(wd,"fpl1.sgrd", sep=""),
  METHOD=1))
###################################################################
#------compute slope length----------------------------------------
###################################################################
rsaga.geoprocessor("ta_hydrology", 7, env=myenv,list(					
  DEM=paste(wd,"dem1.asc", sep=""), LENGTH=paste(wd,"spl1.sgrd", sep="")))
###################################################################
#------compute cell balance----------------------------------------
###################################################################
rsaga.geoprocessor("ta_hydrology", 10, env=myenv,list(					
  DEM=paste(wd,"dem1.asc", sep=""), BALANCE=paste(wd,"cbl1.sgrd", sep=""),
  METHOD=1))
###################################################################
#------compute SAGA Wetness Index-----------------------------------
###################################################################
rsaga.geoprocessor("ta_hydrology", 15, env=myenv,list(					
  DEM=paste(wd,"dem1.asc", sep=""), TWI=paste(wd,"twi1.sgrd", sep="")))
###################################################################
#------geomorphometry statistics-----------------------------------
###################################################################
rsaga.geoprocessor("shapes_grid", 2 ,env=myenv,list(					
  GRIDS=paste(paste(wd,"dem1.asc", sep=""),paste(wd,"ioc1.sgrd", sep=""),
              paste(wd,"conv_r1.sgrd", sep=""),paste(wd,"nego1.sgrd", sep=""),
              paste(wd,"slop1.sgrd", sep=""),paste(wd,"proc1.sgrd", sep=""),
              paste(wd,"plac1.sgrd", sep=""),paste(wd,"logc1.sgrd", sep=""),
              paste(wd,"croc1.sgrd", sep=""),paste(wd,"minc1.sgrd", sep=""),
              paste(wd,"maxc1.sgrd", sep=""),paste(wd,"rare1.sgrd", sep=""),
              paste(wd,"wind1.sgrd", sep=""),paste(wd,"tpi1.sgrd", sep=""),
              paste(wd,"vld1.sgrd", sep=""),paste(wd,"mpi1.sgrd", sep=""),
              paste(wd,"tri1.sgrd", sep=""),paste(wd,"vrm1.sgrd", sep=""),
              paste(wd,"txt1.sgrd", sep=""),paste(wd,"clo1.sgrd", sep=""),
              paste(wd,"cup1.sgrd", sep=""),paste(wd,"clu1.sgrd", sep=""),
              paste(wd,"cdo1.sgrd", sep=""),paste(wd,"cdl1.sgrd", sep=""),
              paste(wd,"flo1.sgrd", sep=""),paste(wd,"fpl1.sgrd", sep=""),
              paste(wd,"spl1.sgrd", sep=""),paste(wd,"cbl1.sgrd", sep=""),
              paste(wd,"twi1.sgrd", sep=""), sep=";"), 
  POLYGONS=paste(wd,"conv_segments1.shp", sep=""), 
  NAMING=1, METHOD=0, RESULT=paste(wd,"conv_segments1.shp", sep=""), 
  COUNT=0, MIN=1, MAX=1, RANGE=1, SUM=1, MEAN=1, VAR=1, STDDEV=1, QUANTILE=5, GINI=0))
################
#--selectie peaks seeds
#--read seed raster
ppt=sp::read.asciigrid("peaks1.asc")
ppt=raster::raster(ppt)
ppt[is.na(ppt[])] <- 0
#--citeste rasterul seeds
sst=sp::read.asciigrid("seeds1.asc")
sst=raster::raster(sst)
#--replace NAs with 0
sst[is.na(sst[])] <- 0
#--select peaks that overlay seeds, or seeds which are in a 3x3 quen case neighborhood
#3x3 focal filters for neighbour pixels
pf1t=raster::focal(sst, w=matrix(c(1,0,0,0,0,0,0,0,0), nc=3, nr=3), fun=max)
pf2t=raster::focal(sst, w=matrix(c(0,1,0,0,0,0,0,0,0), nc=3, nr=3), fun=max)
pf3t=raster::focal(sst, w=matrix(c(0,0,1,0,0,0,0,0,0), nc=3, nr=3), fun=max)
pf4t=raster::focal(sst, w=matrix(c(0,0,0,1,0,0,0,0,0), nc=3, nr=3), fun=max)
pf6t=raster::focal(sst, w=matrix(c(0,0,0,0,0,1,0,0,0), nc=3, nr=3), fun=max)
pf7t=raster::focal(sst, w=matrix(c(0,0,0,0,0,0,1,0,0), nc=3, nr=3), fun=max)
pf8t=raster::focal(sst, w=matrix(c(0,0,0,0,0,0,0,1,0), nc=3, nr=3), fun=max)
pf9t=raster::focal(sst, w=matrix(c(0,0,0,0,0,0,0,0,1), nc=3, nr=3), fun=max)
#--si au aceeasi valoare seed
pksf3t=overlay(ppt,sst,pf1t,pf2t,pf3t,pf4t,pf6t,pf7t,pf8t,pf9t, fun=ft, forcefun=TRUE)
raster::writeRaster(pksf3t, filename="selected_peaks1.asc", overwrite=TRUE)
#--check the tumuli and selected peaks
rsaga.geoprocessor("shapes_grid", 2 ,env=myenv,list(					
  GRIDS=paste(wd,"selected_peaks1.asc", sep=""), POLYGONS=paste(wd,"burial_mounds1.shp", sep=""), 
  NAMING=1, METHOD=0, RESULT=paste(wd,"burial_mounds1.shp", sep=""), 
  COUNT=0, MIN=0, MAX=1, RANGE=0, SUM=0, MEAN=0, VAR=0, STDDEV=0, QUANTILE=0, GINI=0))
shapet <- rgdal::readOGR("burial_mounds1.shp", "burial_mounds1", verbose=TRUE)
table(shapet@data$TYPE, shapet@data$selected_pe)
#--flag the segments with selected peaks
rsaga.geoprocessor("shapes_grid", 2 ,env=myenv,list(					
  GRIDS=paste(wd,"selected_peaks1.asc", sep=""), POLYGONS=paste(wd,"conv_segments1.shp", sep=""), 
  NAMING=1, METHOD=0, RESULT=paste(wd,"conv_segments1.shp", sep=""), 
  COUNT=0, MIN=0, MAX=1, RANGE=0, SUM=0, MEAN=0, VAR=0, STDDEV=0, QUANTILE=0, GINI=0))
###################################################################
#------flag lakes or other things----------------------------------
###################################################################
#--rasterize the layer
rsaga.geoprocessor("grid_gridding", 0, env=myenv,list(					
  INPUT=paste(wd,"lakes.shp", sep=""), FIELD="ID", OUTPUT=0, MULTIPLE=0, GRID_TYPE=9, 
  TARGET_DEFINITION=1, TARGET_TEMPLATE=paste(wd,"conv_r1.sgrd", sep=""), GRID=paste(wd,"lakes1.sgrd", sep="")))
#--transfer lake presence
rsaga.geoprocessor("shapes_grid", 2 ,env=myenv,list(					
  GRIDS=paste(wd,"lakes1.sgrd", sep=""), POLYGONS=paste(wd,"conv_segments1.shp", sep=""), 
  NAMING=1, METHOD=0, RESULT=paste(wd,"conv_segments1.shp", sep=""), 
  COUNT=0, MIN=0, MAX=1, RANGE=0, SUM=0, MEAN=0, VAR=0, STDDEV=0, QUANTILE=0, GINI=0))
#--rasterize the dam layer
rsaga.geoprocessor("grid_gridding", 0, env=myenv,list(					
  INPUT=paste(wd,"dams.shp", sep=""), FIELD="ID", OUTPUT=0, MULTIPLE=0, GRID_TYPE=9, 
  TARGET_DEFINITION=1, TARGET_TEMPLATE=paste(wd,"conv_r1.sgrd", sep=""), GRID=paste(wd,"dams1.sgrd", sep="")))
#--transfer dam presence
rsaga.geoprocessor("shapes_grid", 2 ,env=myenv,list(					
  GRIDS=paste(wd,"dams1.sgrd", sep=""), POLYGONS=paste(wd,"conv_segments1.shp", sep=""), 
  NAMING=1, METHOD=0, RESULT=paste(wd,"conv_segments1.shp", sep=""), 
  COUNT=0, MIN=0, MAX=1, RANGE=0, SUM=0, MEAN=0, VAR=0, STDDEV=0, QUANTILE=0, GINI=0))
#--rasterize the embankment layer
rsaga.geoprocessor("grid_gridding", 0, env=myenv,list(					
  INPUT=paste(wd,"embankments.shp", sep=""), FIELD="ID", OUTPUT=0, MULTIPLE=0, GRID_TYPE=9, 
  TARGET_DEFINITION=1, TARGET_TEMPLATE=paste(wd,"conv_r1.sgrd", sep=""), GRID=paste(wd,"embankments1.sgrd", sep="")))
#--transfer embankment presence
rsaga.geoprocessor("shapes_grid", 2 ,env=myenv,list(					
  GRIDS=paste(wd,"embankments1.sgrd", sep=""), POLYGONS=paste(wd,"conv_segments1.shp", sep=""), 
  NAMING=1, METHOD=0, RESULT=paste(wd,"conv_segments1.shp", sep=""), 
  COUNT=0, MIN=0, MAX=1, RANGE=0, SUM=0, MEAN=0, VAR=0, STDDEV=0, QUANTILE=0, GINI=0))
###################################################################
#------flag the tumuli segments------------------------------------
###################################################################
#--get the tumuli centroids
rsaga.geoprocessor("shapes_polygons", 1, env=myenv,list(					
  POLYGONS=paste(wd,"burial_mounds1.shp", sep=""), CENTROIDS=paste(wd,"burial_mounds_centroids1.shp", sep="")))
#--rasterize the centroids
rsaga.geoprocessor("grid_gridding", 0, env=myenv,list(					
  INPUT=paste(wd,"burial_mounds_centroids1.shp", sep=""), FIELD="ID", OUTPUT=0, MULTIPLE=0, GRID_TYPE=9, 
  TARGET_DEFINITION=1, TARGET_TEMPLATE=paste(wd,"conv_r1.sgrd", sep=""), GRID=paste(wd,"centroids1.sgrd", sep="")))
#--transfer centroid presence
rsaga.geoprocessor("shapes_grid", 2 ,env=myenv,list(					
  GRIDS=paste(wd,"centroids1.sgrd", sep=""), POLYGONS=paste(wd,"conv_segments1.shp", sep=""), 
  NAMING=1, METHOD=0, RESULT=paste(wd,"conv_segments1.shp", sep=""), 
  COUNT=0, MIN=0, MAX=1, RANGE=0, SUM=0, MEAN=0, VAR=0, STDDEV=0, QUANTILE=0, GINI=0))
###################################################################
#------prepare for randomForest-----------------------------------
###################################################################
#--read the segments
#--study area north
segments <- maptools::readShapeSpatial("conv_segments.shp", 
                                       proj4string = CRS("+proj=sterea +lat_0=46 +lon_0=25 +k=0.99975 +x_0=500000 +y_0=500000 +ellps=krass +towgs84=33.4,-146.6,-76.3,-0.359,-0.053,0.844,-0.84 +units=m +no_defs"), 
                                       repair=TRUE, force_ring=T,
                                       verbose=TRUE)
#--study area south
segmentst <- maptools::readShapeSpatial("conv_segments1.shp", 
                                        proj4string = CRS("+proj=sterea +lat_0=46 +lon_0=25 +k=0.99975 +x_0=500000 +y_0=500000 +ellps=krass +towgs84=33.4,-146.6,-76.3,-0.359,-0.053,0.844,-0.84 +units=m +no_defs"), 
                                        repair=TRUE, force_ring=T,
                                        verbose=TRUE)
#--fix the column names
colnamesfix <- names(segments)
names(segmentst@data) <- colnamesfix
#--replace NAs with 0
segments@data[is.na(segments@data)] <- 0
#--replace NAs with 0
segmentst@data[is.na(segmentst@data)] <- 0
#--check segments ID, peak and selected peak
summary(as.factor(segments@data$centroids..))
summary(as.factor(segments@data$selected_pe))
summary(as.factor(segmentst@data$centroids..))
summary(as.factor(segmentst@data$selected_pe))
###################################################################
#------compute ratio between the diameter of the local convexity--- 
#--------watershed segment and the difference in elevation---------
###################################################################
segments@data$dhratio <- (segments@data$Dmax/((segments@data$dem..RANGE.)+0.1))/10
segments@data$compactness <- (sqrt(4*segments@data$A/pi))/segments@data$P
segments@data$formfactor <-  (4*pi*segments@data$A)/(segments@data$P/2)
segments@data$roundness <- (4*segments@data$A)/(pi*segments@data$Fmax)
segments@data$elongation <- segments@data$Fmax/segments@data$Fmin
segments@data$rectfit <- segments@data$Fmax/segments@data$Fmin
#--filter segments by area and lakes
segments <- segments[segments$selected_pe >= 1,]
segments <- segments[segments$A <= 5000 & segments$A >= 100,]
segments <- segments[segments$lakes..MAX. == 0,]
segments <- segments[segments$dams..MAX. == 0,]
segments <- segments[segments$embankments == 0,]
###################################################################
#------compute ratio between the diameter of the local convexity--- 
#--------watershed segment and the difference in elevation---------
###################################################################
segmentst@data$dhratio <- (segmentst@data$Dmax/(segmentst@data$dem..RANGE.+0.1))/10
segmentst@data$compactness <- (sqrt(4*segmentst@data$A/pi))/segmentst@data$P
segmentst@data$formfactor <-  (4*pi*segmentst@data$A)/(segmentst@data$P/2)
segmentst@data$roundness <- (4*segmentst@data$A)/(pi*segmentst@data$Fmax)
segmentst@data$elongation <- segmentst@data$Fmax/segmentst@data$Fmin
segmentst@data$rectfit <- segmentst@data$Fmax/segmentst@data$Fmin
#filter
segmentst <- segmentst[segmentst$selected_pe >= 1,]
segmentst <- segmentst[segmentst$A <= 5000 & segmentst$A >= 100,]
segmentst <- segmentst[segmentst$lakes..MAX. == 0,]
segmentst <- segmentst[segmentst$dams..MAX. == 0,]
segmentst <- segmentst[segmentst$embankments == 0,]
###################################################################
#------Tune, fit and run RANDOM FOREST----------------------------- 
###################################################################
#--select variables: centroids, shape descriptors, dem and ioc
tumuli <- segments@data[,c(780,2:73)]
tumuli$centroids.. <- as.factor(tumuli$centroids..)
tumulit <- segmentst@data[,c(780,2:73)]
tumulit$centroids.. <- as.factor(tumulit$centroids..)
#--only for tuning
# tumuli <- segments@data[,c(780,2:515,517:541,543:567,569:593,595:619,621:645,647:671,673:697,699:723,725:775,781:786)]
# tumuli$centroids.. <- as.factor(tumuli$centroids..)
# tumulit <- segmentst@data[,c(780,2:515,517:541,543:567,569:593,595:619,621:645,647:671,673:697,699:723,725:775,781:786)]
# tumulit$centroids.. <- as.factor(tumulit$centroids..)
###################################################################
#------Latin hypercube sampling------------------------------ -----
###################################################################
# set.seed(4543)
# rowtumuli <- which(tumuli$centroids.. == 1, arr.ind=TRUE)
# set.seed(4543)
# training <- clhs(tumuli, include=rowtumuli, size = 1000, iter = 1000, progress = FALSE)
# set.seed(4543)
# train <- tumuli[training,-1]
# response <- tumuli[training,1]
##################################################################
#------Tuning------------------------------------------------------
##################################################################
#--variables tuning
# result <- replicate(5, rfcv(train, response, cv.fold=10, recursive=TRUE), simplify=FALSE)
# error.cv <- sapply(result, "[[", "error.cv")
# matplot(result[[1]]$n.var, cbind(rowMeans(error.cv), error.cv), type="l",
#         lwd=c(2, rep(1, ncol(error.cv))), col=1, lty=1, log="x",
#         xlab="Number of variables", ylab="CV Error")
# pdf("variables_CVerror.pdf",width=7,height=5)
# matplot(result[[1]]$n.var, cbind(rowMeans(error.cv), error.cv), type="l",
#         lwd=c(2, rep(1, ncol(error.cv))), col=1, lty=1, log="x",
#         xlab="Number of variables", ylab="CV Error")
# dev.off()
#--mtry and nodesize tuning
# set.seed(4543)
# tuneParams <- randomForestSRC::tune(centroids.. ~ ., data=tumuli[training,], mtryStart=1, c(1:9, seq(10, 100, by = 5)),
#                   ntreeTry = 100)
# plot.tune(tuneParams)
#--save the plot
# pdf("mtry_nodesize_tunning.pdf",width=7,height=5)
# plot.tune(tuneParams)
# dev.off()
###################################################################
#------Boruta------------------------------------------------------ 
###################################################################
# set.seed(4543)
# b <- Boruta(train, response)
# print(b)
# final.boruta <- TentativeRoughFix(b)
# boruta.vars <- getSelectedAttributes(final.boruta, withTentative = F)
# varimpb <- paste(boruta.vars,sep=",")
# finaltrainingg <- tumuli[varimpb]
# finaltrainingg$centroid <- tumuli$centroids..
# #--model fit
# set.seed(4543)
# fitb <- randomForest::randomForest(centroid ~ ., data=finaltrainingg[training,], ntree=100, mtry=4, nodesize=1,
#                                   importance=TRUE, replace=F, classwt=c(0.01,0.9), keep.inbag=F)
# print(fitb)
# varImpPlot(fitb)
# set.seed(4543)
# predictionsb <- predict(fitb, tumuli[,-1])
# set.seed(4543)
# predictionstb <- predict(fit, tumulit[,-1])
# table(predictionsb, tumuli$centroids..)
# table(predictionstb, tumulit$centroids..)
###################################################################
#------Importance ordering----------------------------------------- 
###################################################################
# fitimp <- randomForest::randomForest(centroids.. ~ ., data=tumuli[training,], ntree=100, mtry=4, nodesize=1, 
#                                   importance=TRUE, replace=F, classwt=c(0.01,0.9), keep.inbag=F)
# imp <- randomForest::importance(fitimp, type=1)
# dimp <- data.frame(imp)
# dimp$names <- row.names(dimp)
# dimps <- dimp[order(dimp[1]),]
# dimps <- dimps[dimps[1] >= 0,]
# dimps <- dimps[1:200,]
# vardimps <- paste(dimps$names,sep=",")
# finaltrainingd <- tumuli[vardimps]
# finaltrainingd$centroid <- tumuli$centroids..
# set.seed(4543)
# rowtumulii <- which(finaltrainingd$centroids == 1, arr.ind=TRUE)
# set.seed(4543)
# training <- clhs(tumuli, include=rowtumulii[1:48], size = 100, iter = 100, progress = FALSE)
# #x <- c(((100*ntumulis)/(tumulis+ntumulis))/100,((100*tumulis)/(tumulis+ntumulis))/100)
# set.seed(4543)
# fitimp <- randomForest(centroid ~ ., data=finaltrainingd, ntree=100, mtry=4, nodesize=1, 
#                     #importance=TRUE, replace=F)
#                     #importance=TRUE, replace=F, cutoff=x)
#                     importance=TRUE, replace=F, classwt=c(0.01,0.9), keep.inbag=F)
# print(fit)
# set.seed(4543)
# predictionsimp <- predict(fitimp, tumuli[,-1])
# set.seed(4543)
# predictionstimp <- predict(fitimp, tumulit[,-1])
# table(predictionsimp, tumuli$centroids..)
# table(predictionstimp, tumulit$centroids..)
###################################################################
#------Chosen settings--------------------------------------------- 
###################################################################
set.seed(4543)
rowtumuli <- which(tumuli$centroids.. == 1, arr.ind=TRUE)
set.seed(4543)
training <- clhs::clhs(tumuli, include=rowtumuli[1:48], size = 1000, iter = 1000, progress = FALSE)
#--class proportions
#s <- summary(tumuli[training,]$centroids..)
#x <- c(((100*ntumulis)/(tumulis+ntumulis))/100,((100*tumulis)/(tumulis+ntumulis))/100)
set.seed(4543)
fit <- randomForest::randomForest(centroids.. ~ ., data=tumuli[training,], ntree=100, mtry=4, nodesize=1, 
                    #importance=TRUE, replace=F)
                    #importance=TRUE, replace=F, cutoff=x)
                    importance=TRUE, replace=F, classwt=c(0.01,0.9), keep.inbag=F)
print(fit)
set.seed(4543)
predictions <- predict(fit, tumuli[,-1])
set.seed(4543)
predictionst <- predict(fit, tumulit[,-1])
table(predictions, tumuli$centroids..)
table(predictionst, tumulit$centroids..)
#--explain the forest
#-- https://cran.rstudio.com/web/packages/randomForestExplainer/vignettes/randomForestExplainer.html
#--see the forest depth by variable
min_depth_distr <- min_depth_distribution(fit)
plot_min_depth_distribution(min_depth_distr, k=20)
pdf("min_depth_distribution.pdf",width=7,height=5)
plot_min_depth_distribution(min_depth_distr, k=20)
dev.off()
#--see the importance by numbers of node split
importance.data <- randomForestExplainer::measure_importance(fit)
pdf("multi_way_imp.pdf",width=7,height=5)
plot_multi_way_importance(importance.data, x_measure = "accuracy_decrease", 
                          y_measure = "no_of_nodes", 
                          size_measure = "times_a_root", no_of_labels = 20)
dev.off()
# plot variable interactions
vars <- important_variables(fit, k=5, measures=c("mean_min_depth","no_of_trees"))
interactions.data <- min_depth_interactions(fit, vars)
pdf("interactions.pdf",width=7,height=5)
plot_min_depth_interactions(interactions.data)
dev.off()
pdf("predictions_grid1.pdf",width=7,height=5)
plot_predict_interaction(fit, tumuli, "ioc..Q95.", "dem..STDDEV")
dev.off()
pdf("predictions_grid2.pdf",width=7,height=5)
plot_predict_interaction(fit, tumuli, "ioc..Q95.", "ioc..RANGE.")
dev.off()
pdf("predictions_grid3.pdf",width=7,height=5)
plot_predict_interaction(fit, tumuli, "ioc..MAX.", "dem..STDDEV")
dev.off()
#--generate the hmtl report
explain_forest(fit, interactions = TRUE, data = tumuli)
#--segment distribution in the training set
#--https://www.r-bloggers.com/explaining-predictions-random-forest-post-hoc-analysis-randomforestexplainer-package/
pdf("segments_training_set.pdf",width=7,height=5)
ggplot(train, aes(train$ioc..Q95., train$dem..STDDEV, colour=response)) +geom_jitter(size=1.8) + labs(title="Distribution of segments in training set", y="") + theme_minimal() +  scale_color_manual(values=c("blue", "red")) +  theme(legend.position="bottom") + geom_hline(yintercept = 2, linetype="dotted") 
dev.off()
#--segment distribution in the testing set
pdf("segments_testing_set.pdf",width=7,height=5)
ggplot(tumulit, aes(tumulit$ioc..Q95., tumulit$dem..STDDEV, colour=tumulit$centroids..)) +geom_jitter(size=1.8) + labs(title="Distribution of segments in testing set", y="") + theme_minimal() +  scale_color_manual(values=c("blue", "red")) +  theme(legend.position="bottom") + geom_hline(yintercept = 2, linetype="dotted") 
dev.off()
#--save the model for later use
save(fit,file = "tumuliRFmodel.RData")
rf_model <- get(load("tumuliRFmodel.RData"))
#--save the predictions
segments@data$pred <- predictions
writeOGR(segments, layer=wd, 
          dsn="burial_mounds_predicted.shp", driver="ESRI Shapefile", overwrite=TRUE)
segmentst@data$pred <- predictionst
writeOGR(segmentst, layer=wd, 
          dsn="burial_mounds1_predicted.shp", driver="ESRI Shapefile", overwrite=TRUE)