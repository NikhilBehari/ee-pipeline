library(RStoolbox)
library(virtualspecies)
library(ggplot2)
library(reshape2)
library(raster)
library(usdm)

# CONSTANTS
DIR = "../raster-images/"
EXT = extent(43, 51, -26, -11)
OUT = "../raster-images/output/"
RES = c(0.083333, 0.083333)

# Get all .tif files 
file_list = list.files(DIR, pattern = "\\.tif$")


# Set base raster in Madagascar
base <- raster(ext=EXT, resolution=RES)
full_stack = base

# Iterate through and stack files 
for(i in file_list){
  
  # Make cropped raster stack from file 
  temp_r = stack(paste(DIR, toString(i), sep=""))
  resamp = projectRaster(temp_r, base, method="bilinear")
  
  # Add to raster stack
  full_stack = stack(full_stack, resamp)
}

# Write to file
writeRaster(full_stack, filename=paste(OUT, "multilayer.tif", sep=""), options="INTERLEAVE=BAND", overwrite=TRUE)
