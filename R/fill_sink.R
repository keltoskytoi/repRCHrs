filled_DTM <- function(dtm, output, tmp, minslope, crs) {
  cat(" ",sep = "\n")
  cat("### filled_DTM starts ###")
  raster::writeRaster(dem, filename=paste0(file.path(tmp),"/dtm.sdat"),overwrite = TRUE, NAflag = 0)
  RSAGA::rsaga.geoprocessor(lib = "ta_preprocessor", module = 4,
                            param = list(ELEV =    paste(tmp,"/dtm.sgrd", sep = ""),
                                         WSHED =   paste(tmp,"/wshed.sgrd", sep = ""),
                                         FDIR =    paste(tmp,"/fdir.sgrd", sep = ""),
                                         FILLED =  paste(tmp,"/filled_dem.sgrd", sep = ""),
                                         MINSLOPE = minslope
                            ),
                            show.output.on.console = TRUE, invisible = TRUE,
                            env = env)
  prjctn <- crs
  filled_dtm <- raster::raster(file.path(tmp, "filled_dtm.sdat"))
  proj4string(filled_dem) <- prjctn
  raster::writeRaster(filled_dem,filename=paste0(file.path(output),"/filled_dtm.tif"),overwrite = TRUE,NAflag = 0)
  cat(" ",sep = "\n")
  cat("### filled_DTM finished ###")
}
