library(RStoolbox)
library(virtualspecies)
library(ggplot2)
library(reshape2)
library(raster)
library(usdm)
library(ENMTools)
library(corrplot)
library(RColorBrewer)
library(infotheo)

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
  
  return (removeCollinearity(
    raster.stack = raster_stack,
    multicollinearity.cutoff = 0.7,
    select.variables = TRUE,
    sample.points = FALSE,
    plot = TRUE,
    method = "pearson"
  ))
}

calculateVIF <- function(stack){
  return (vif(stack))
}

calculateCOR <- function(stack, visualize=FALSE){
  cor_out = cor(sampleRandom(stack, size=5000, method="pearson"))
  
  if(visualize){
    corrplot(samp_out, tl.col = "black", tl.srt = 90, method="color",sig.level = c(.001, .01, .05), pch.cex = .9, type="lower", col=brewer.pal(n=8, name="BuPu"))
    
    col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
    corrplot(samp_out, method = "color", col = col(200),
             type = "lower", order = "hclust", number.cex = .7,
             # addCoef.col = "black", # Add coefficient of correlation
             tl.col = "black", tl.srt = 90, tl.cex=0.3, # Text label color and rotation
             # Combine with significance 
             # insig = "blank", 
             # hide correlation coefficient on the principal diagonal
             diag = FALSE)
  }
  
  return(cor_out)
}

calculateMI <- function(stack, visualize=FALSE){
  matrix_stack = as.data.frame(stack)
  matrix_stack = discretize(matrix_stack)
  mi_grid = mutinformation(matrix_stack)
  
  if(visualize){
    corrplot(mi_grid, is.corr=FALSE)
  }
  
  return(mi_grid)
}

full_stack = stack("input/basic.tif")
grid = calculateMI(full_stack, visualize=TRUE)
