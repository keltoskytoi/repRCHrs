#############################################################################################
###--- Setup Environment -------------------------------------------------------------------#
                                  ###############################################           #
# require libs for setup          #EEEE n   n v       v rrrr    m     m   ttttt #           #                  
require(raster)                   #E    nn  n  v     v  r   r  m m   m m    t   #           #         
require(envimaR)                  #EE   n n n   v   v   rrrr   m m   m m    t   #           #                
require(link2GI)                  #E    n  nn    v v    r  r  m   m m   m   t   #           #             
# define needed libs              #EEEE n   n     v     r   r m    m    m   t   #           #
#                                 ###############################################           #
libs = c("link2GI","lidR","uavRst","mapview") 
pathdir = "mpg-envinfosys-teams-2018-envimaster_rs_18/src/"
#set root folder for uniPC or laptop                                                        #
root_folder = alternativeEnvi(root_folder = "~/edu/mpg-envinsys-plygrnd",                   #
                              alt_env_id = "COMPUTERNAME",                                  #
                              alt_env_value = "PCRZP",                                      #
                              alt_env_root_folder = "F:/edu/mpg-envinsys-plygrnd")          #
#source environment script                                                                  #
source(file.path(root_folder, paste0(pathdir,"001_setup_envrmt.R")))                                                              
###---------------------------------------------------------------------------------------###
#############################################################################################

#prepare (colorpal and projection)
pal = mapview::mapviewPalette("mapviewTopoColors")
proj4 = "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"

# list las files (in folder)
las_files = list.files(path =envrmt$path_example,
                       pattern = glob2rx("*.las"),
                       full.names = TRUE)

las_files
##- check the extent of the las file
uavRst::llas2llv0(las_files,envrmt$path_las)

### take a look !!! high performance needed!!!
las = readLAS(las_files[1])
las = lasnormalize(las, tin())
#lidR::plot(las,color="Z",colorPalette = pal(100),backend="pcv")

# create catalog
mof_snip<- uavRst::make_lidr_catalog(path = envrmt$path_example, 
                                     chunksize = 100, 
                                     chunkbuffer = 10, 
                                     proj4=proj4, cores = 4)
# now we add output options for the ground classification files we want to create 
lidR::opt_output_files(mof_snip)<-paste0(envrmt$path_example,"{ID}_csf")
# analyze ground points
mof_snip_ground_csf<- lidR::lasground(mof_snip, csf())

# add an output option FOR THE dsmtin algorithm
lidR::opt_output_files(mof_snip_ground_csf)<-paste0(envrmt$path_example,"{ID}_tin_csf")
lidR::opt_progress(mof_snip_ground_csf)<-FALSE
dsm_tin <- lidR::grid_canopy(mof_snip_ground_csf, res = 0.5, 
                                 lidR::dsmtin(0.5))


# add an output option FOR THE  pitfree algorithm
lidR::opt_output_files(mof_snip_ground_csf)<-paste0(envrmt$path_example,"{ID}_pitfree_csf")
dsm_pit <- lidR::grid_canopy(mof_snip_ground_csf, res = 0.5, 
                                     lidR::pitfree(c(0,2,5,10,15), c(0, 0.5)))


# add an output option FOR THE  p2r algorithm
lidR::opt_output_files(mof_snip_ground_csf)<-paste0(envrmt$path_example,"{ID}_p2r_csf")
dsm_p2r<- lidR::grid_canopy(mof_snip_ground_csf, res = 0.5, 
                                lidR::p2r(0.2,na.fill = knnidw()))
#plot dsms
raster::plot(dsm_tin,col=pal(32),main="csf dsmtin 0.5 DSM")
raster::plot(dsm_pit,col=pal(32),main="csf dsmtin 0.5 DSM")
raster::plot(dsm_p2r,col=pal(32),main="csf dsmtin 0.5 DSM")

# reclass spurious negative values
dsm_tin[dsm_tin<minValue(dsm_tin)]<-minValue(dsm_tin)
dsm_pit[dsm_pit<minValue(dsm_pit)]<-minValue(dsm_pit)
dsm_p2r[dsm_p2r<minValue(dsm_p2r)]<-minValue(dsm_p2r)

#### test what reclass does and if it is necessary ?

lidR::opt_output_files(mof_snip_ground_csf)<-paste0(envrmt$path_example,"{ID}_pit_un_csf")
pit_un <- lidR::grid_canopy(mof_snip_ground_csf, res = 0.5, 
                             lidR::pitfree(c(0,2,5,10,15), c(0, 0.5)))

lidR::opt_output_files(mof_snip_ground_csf)<-paste0(envrmt$path_example,"{ID}_pit_ca_csf")
pit_cor <- lidR::grid_canopy(mof_snip_ground_csf, res = 0.5, 
                             lidR::pitfree(c(0,2,5,10,15), c(0, 0.5)))

pit_cor[pit_cor<minValue(pit_cor)]<-minValue(pit_cor)
plot(pit_un-pit_cor)

### DTM

#knn
lidR::opt_output_files(mof_snip_ground_csf)<-paste0(envrmt$path_example,"{ID}_knn_csf")
dtm_knn = lidR::grid_terrain(mof_snip_ground_csf, res=0.5,  algorithm = lidR::knnidw(k=50, p=3))

#tin
lidR::opt_output_files(mof_snip_ground_csf)<-paste0(envrmt$path_example,"{ID}_gtin_csf")
dtm_tin = lidR::grid_terrain(mof_snip_ground_csf, res=0.5,  algorithm = lidR::tin())

#plot dtms
raster::plot(dtm_tin,col=pal(32),main="csf knnidw terrain model")
raster::plot(dtm_knn,col=pal(32),main="csf knnidw terrain model")

#compare dtms
plot(dtm_knn - dtm_tin)

### CHM

plot(dsm_p2r - dtm_knn)
plot(dsm_pit - dtm_knn)
plot(dsm_tin - dtm_knn)

chmp2rk <- dsm_p2r - dtm_knn
chmpitk <- dsm_pit - dtm_knn
chmtink <- dsm_tin - dtm_knn

class(chmpitk)
writeRaster(chmpitk,filename=paste0(envrmt$path_processed,"CHM_example_nouav.tif"),format="GTiff",overwrite=TRUE) 
rst <- raster::raster(file.path(envrmt$path_lidar, "processedCHM_example.tif"))

#used code without uavrst step to see difference
#rst2 <- raster::raster(file.path(envrmt$path_lidar, "processedCHM_example_nouav.tif"))
plot(rst)

plot(rst-rst2)

# general problem with path and naming
# what ever the folder path is, the output is put into a higher folder and the 
# names have in the beginning and or ending the names of the folders

# p2r in comprae single dsm or for chm seems to have different extends than the others ?

### end of script ------------------------------------------------------------------------###
