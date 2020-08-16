library(raster)
library(RStoolbox)
library(virtualspecies)
library(tools)

# CONSTANTS
DIR = "../raster-images/GLW/"
OUT = "../raster-images/"
EXT = extent(47.5207953674-05, 47.5207953674+0.25, -18.9101632941-0.25, -18.9101632941+0.25)

EXT = extent(47.5207953674-6, 47.5207953674+3, -18.9101632941-8, -18.9101632941+7)

RES = 0.083333
CRS = CRS("+init=epsg:4326")


# CHECK: Mosaic images 
# CHECK: small images 

# Get all .tif files 
file_list = list.files(DIR, pattern = "\\.tif$")

# Create base reference raster and initialize empty base
base <- raster(ext=EXT, resolution=c(RES, RES), crs=CRS)
full_stack = base

# Iterate through and stack files 
for(i in file_list){
  print(i)

  # Make cropped raster stack from file
  temp_r = stack(paste(DIR, toString(i), sep=""))

  resamp = projectRaster(temp_r, base, method="bilinear")
  names(resamp) <- toString(file_path_sans_ext(i))
  
  # Add to raster stack
  full_stack = stack(full_stack, resamp)
  

}
labels(full_stack)
# Write to file
# writeRaster(full_stack, filename=paste(OUT, "multilayer_smol.envi", sep=""), overwrite=TRUE)
