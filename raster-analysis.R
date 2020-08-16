library(RStoolbox)
library(virtualspecies)
library(ggplot2)
library(reshape2)
library(raster)
library(usdm)
library(ENMTools)
library(corrplot)
library(RColorBrewer)

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
  # raster_stack = subset(raster_stack)
  return (vif(raster_stack))
}

calculateCOR <- function(f1){
  raster_stack = stack(f1, bands=NULL)
  
  return(layerStats(raster_stack, stat='pearson'))
}

full_stack = stack("../raster-images/basic.tif")

vif(full_stack)

samp_out = cor(sampleRandom(full_stack, size=50000, method="pearson"))

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

samp_out
write.csv(samp_out, file="test.csv")

# calculateVIF("../raster-images/")
# 
# cor_frame = calculateCOR("../raster-images/multilayer.tif")
# cor_frame
# 
# 
# raster_stack = stack("../raster-images/multilayer.tif", bands=NULL)
# samp_out = cor(sampleRandom(raster_stack, size=50000, method="pearson"))
# corrplot(samp_out, type="upper")
# 
# 
# samp_out 
# test_out_samp <- samp_out
# colnames(test_out_samp) <- c("Chickens", "Cows", "Ducks", "Goats", "Horses", "Pigs", "Sheep")
# rownames(test_out_samp) <- c("Chickens", "Cows", "Ducks", "Goats", "Horses", "Pigs", "Sheep")
# 
# corrplot(test_out_samp, tl.col = "black", tl.srt = 90, method="color",sig.level = c(.001, .01, .05), pch.cex = .9, type="upper", col=brewer.pal(n=8, name="BuPu"))
