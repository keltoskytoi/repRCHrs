filtR <- function(Rstfile, filtRs="all", sizes, NArm=TRUE){

  ### set default
  if(any(filtRs=="all")){
    filtRs <-c("sum", "min","max","sd","mean","sobel")
  }else{filtRs==filtRs}

  #check for wrong sizes input
  if(any(sizes %% 2 == 0)){
    stop("sizes contain even values (use odd values only)")
  }

  filterstk <-lapply(filtRs, function(item){

    # sum filter
    if (item=="sum"){
      cat(" ",sep = "\n")
      cat("processing sum filter",sep = "\n")
      lapply(sizes, function(f){
        cat(paste0("#starting sum  ", as.factor(f),"*", as.factor(f), sep = "\n"))
        sumfR <- raster::focal(Rstfile,w=matrix(1/(f*f),nrow=f,ncol=f),fun=sum,na.rm=NArm)
        names(sumfR) <- paste0(names(Rstfile),"_sum" ,as.factor(f))
        stack(sumfR)
        return(sumfR)
      })
    }#end

    # min filter
    else if (item=="min"){
      cat(" ",sep = "\n")
      cat("processing minimum filter", sep = "\n")
      lapply(sizes, function(f){
        cat(paste0("#starting min  ", as.factor(f), "*", as.factor(f), sep = "\n"))
        minfR <- raster::focal(Rstfile, w=matrix(1/(f*f), nrow=f,ncol=f), fun=min, na.rm=NArm)
        names(minfR) <- paste0(names(Rstfile),"_min", as.factor(f))
        return(minfR)
      })
    }#end

    # max filter
    else if (item=="max"){
      cat(" ",sep = "\n")
      cat("processing maximum filter", sep = "\n")
      lapply(sizes, function(f){
        cat(paste0("### starting max  ", as.factor(f),"*", as.factor(f), sep = "\n"))
        maxfR <- raster::focal(Rstfile, w=matrix(1/(f*f), nrow=f, ncol=f), fun=max, na.rm=NArm)
        names(maxfR) <- paste0(names(Rstfile),"_max", as.factor(f))
        return(maxfR)
      })
    }#end

    # sd filter
    else if (item=="sd"){
      cat(" ",sep = "\n")
      cat("processing standard deviation filter", sep = "\n")
      lapply(sizes, function(f){
        cat(paste0("#starting sd   ",as.factor(f), "*", as.factor(f), sep = "\n"))
        sdfR <- raster::focal(Rstfile, w=matrix(1/(f*f), nrow=f, ncol=f),fun=sd, na.rm=NArm)
        names(sdfR) <- paste0(names(Rstfile),"_sd", as.factor(f))
        return(sdfR)
      })
    }#end

    # mean filter
    else if (item=="mean"){
      cat(" ",sep = "\n")
      cat("processing mean filter", sep = "\n")
      lapply(sizes, function(f){
        cat(paste0("#starting mean  ", as.factor(f), "*", as.factor(f), sep = "\n"))
        meanfR <- raster::focal(Rstfile, w=matrix(1/(f*f), nrow=f, ncol=f), fun=mean, na.rm=NArm)
        names(meanfR) <- paste0(names(Rstfile),"_mean", as.factor(f))
        return(meanfR)
      })
    }#end

    #sobel filter
    else if (item=="sobel"){
      cat(" ",sep = "\n")
      cat("processing sobel filter", sep = "\n")
      lapply(sizes, function(f){
        cat(paste0("#starting sobel  " , as.factor(f), "*", as.factor(f), sep = "\n"))
        range = f/2
        mx = matrix(nrow = f, ncol = f)
        my = mx

        for(i in seq(-floor(range), floor(range))){
          for(j in seq(-floor(range), floor(range))){
            mx[i+ceiling(range),j+ceiling(range)] = i / (i*i + j*j)
            my[i+ceiling(range),j+ceiling(range)] = j / (i*i + j*j)
          }
        }

        mx[is.na(mx)] = 0
        my[is.na(my)] = 0

        sobelfR <- sqrt(raster::focal(Rstfile, mx, fun=sum, na.rm=NArm)**2+
                        raster::focal(Rstfile, my, fun=sum, na.rm=NArm)**2)
        names(sobelfR) <- paste0(names(Rstfile),"_sobel" ,as.factor(f))
        return(sobelfR)
      })
    }#end

  })#end main lapply

  #########################################
  #handle output format
  unLS <- unlist(filterstk)
  cat(" ",sep = "\n")
  cat("###########################",sep = "\n")
  cat("Filters are calculated",sep = "\n")
  return(raster::stack(unLS))

} # end fun
