# Copyright (c) 2016 Ryan L. Collins <rlcollins@g.harvard.edu>
# Distributed under terms of the MIT license.

# WGD R Companion Library (WGDR) Function

################
# WGD.matrix.postprocess
################
# Subfunction to perform summary statistic collection on a WGD matrix
################
# Returns a four-item list:
#  $mat : matrix of original values
#  $res : matrix of residuals
#  $stat : matrix of per-bin distribution statistics
#  $rstat : matrix of per-bin residual distribution statistics
#  $sstat : matrix of per-sample residual distribution statistics
################

WGD.matrix.postprocess <- function(mat,         #matrix object from which to plot. Must be x$mat object from WGD.readmatrix
                                   allosomes=F  #option to auto-exclude non-numeric contigs
){
  #Ensure library dependencies load
  require(moments)

  #Filter matrix (if specified)
  if(allosomes==F){
    mat$chr <- suppressWarnings(as.numeric(as.character(mat$chr)))
    mat <- mat[which(!(is.na(mat$chr))),]
  }

  #Generate matrix residuals
  mat.res <- cbind(mat[1:3],
                   mat[-c(1:3)]-1)

  #Gather summary stats per bin
  mat.stats <- cbind(mat[1:3],
                     t(apply(mat[,-c(1:3)],1,function(vals){
                       return(summary(as.numeric(as.character(unlist(vals)))))
                     })))
  mat.res.stats <- cbind(mat.res[1:3],
                         t(apply(mat.res[,-c(1:3)],1,function(vals){
                           return(summary(as.numeric(as.character(unlist(vals)))))
                         })))
  names(mat.stats) <- c(names(mat[1:3]),"min","Q1","med","mean","Q3","max")
  names(mat.res.stats) <- c(names(mat[1:3]),"min","Q1","med","mean","Q3","max")

  #Gather summary stats per sample
  mat.samp.stats <- as.data.frame(t(apply(mat.res[,-c(1:3)],2,function(vals){
    sumstat <- summary(vals)
    stdev <- sd(vals)
    medabs <- mad(vals)
    skew <- skewness(vals)
    kurt <- kurtosis(vals)
    return(c(sumstat,stdev,medabs,skew,kurt))
  })))
  colnames(mat.samp.stats) <- c("min","Q1","med","mean","Q3","max","sd","mad","skewness","kurtosis")

  #Return data
  return(list("mat"=mat,
              "res"=mat.res,
              "stat"=mat.stats,
              "rstat"=mat.res.stats,
              "sstat"=mat.samp.stats))
}