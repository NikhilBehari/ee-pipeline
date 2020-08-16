library(raster)
library(rgdal)
library(rgeos)
library(RColorBrewer)
library(RStoolbox)

fricComp = raster("../raster-images/friction-comp/img.tif")
# Plot comparison surface 
fricComp = projectRaster(fricComp, roads_base)
fricComp[is.na(values(fricComp))] <- 0

# Scale 
comp_fric <- scale(values(fricComp), center = TRUE, scale = TRUE)
roads_fric <- scale(values(friction_map), center = TRUE, scale = TRUE)


# Root mean squared function 
RMSE <- function(x, y) { sqrt(mean((x - y)^2)) }
RMSE(comp_fric, roads_fric)


roads
# Plot friction surface 
plot(fricComp)
friction_map_blur = disaggregate(fricComp, fact=100, method="bilinear")
friction_map_blur = friction_map_blur

outplot = spplot(friction_map_blur, 
                 # scales = list(draw = TRUE),
                 col.regions = colorRampPalette(brewer.pal(9, "BuPu")), 
                 sp.layout = list("sp.lines", roads_utm),
                 at = seq(0, maxValue(friction_map_blur)+0.001, 0.0001))
outplot

# writeRaster(full_stack, filename=paste(OUT, "multilayer.tif", sep=""), options="INTERLEAVE=BAND", overwrite=TRUE)

