library(RStoolbox)
library(virtualspecies)
library(ggplot2)
library(reshape2)
library(raster)
library(usdm)

# CONSTANTS
FILE = "../raster-images/basic.tif"

calculatePCA <- function(tif_file){
  raster_stack = stack(tif_file)
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
  raster_stack = stack(f1, bands=bands)
  
  ## Pairwise correlation
  # raster_stack <- addLayer(raster_stack, other_raster_stack)
  # jnk = layerStats(raster_stack, 'pearson', na.rm=T)
  # corr_matrix = jnk$'pearson correlation coefficient'
  # corr_matrix
  
  return (removeCollinearity(
    raster.stack = raster_stack,
    multicollinearity.cutoff = 0.7,
    select.variables = TRUE,
    sample.points = FALSE,
    plot = TRUE,
    method = "pearson"
  ))
}

calculateVIF <- function(f1){
  raster_stack = stack(f1, bands=NULL)
  # narrowed = calculateMC(FILE)
  # raster_stack = subset(raster_stack, narrowed)
  return (vif(raster_stack))
}

temp = calculateVIF(FILE)
df <- data.frame(temp)
df
write.csv(df, "vif_out.csv", row.names=FALSE)
