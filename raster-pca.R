library(RStoolbox)
library(virtualspecies)
library(ggplot2)
library(reshape2)
library(raster)


calculatePCA <- function(tif_file){
  raster_stack = stack(tif_file, bands=c(1,3))
  raster_stack
  
  ## Run PCA
  set.seed(25)
  rpc <- rasterPCA(raster_stack, spca=TRUE)
  pca_obj = rpc$model
  pca_layers = rpc$map
  
  pca_obj
  # pca_layers
}

calculateMC <- function(f1, bands=NULL){
  raster_stack = stack(tif_file, bands=bands)
  # raster_stack <- addLayer(raster_stack, other_raster_stack)
  # jnk = layerStats(raster_stack, 'pearson', na.rm=T)
  # corr_matrix = jnk$'pearson correlation coefficient'
  # corr_matrix
  
  return (removeCollinearity(
    raster.stack = raster_stack,
    multicollinearity.cutoff = 0.9,
    select.variables = FALSE,
    sample.points = FALSE,
    plot = TRUE,
    method = "pearson"
  ))
  
}

stackLayers <- function(f1, f2){
  r1 = stack(f1)
  r2 = stack(f2)
  r2resamp <- projectRaster(r2, r1, res=0.03, method="bilinear")
  temp <- stack(r1, r2resamp)
  # plot(temp)
  writeRaster(temp, filename="multilayer.tif", options="INTERLEAVE=BAND", overwrite=TRUE)
}

stackLayers("basic.tif", "spam2017.tif")