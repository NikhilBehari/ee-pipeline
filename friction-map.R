library(raster)
library(rgdal)
library(rgeos)
library(RColorBrewer)
library(RStoolbox)

# Read in roads shapefile (LARGE FILE)
roads = readOGR(dsn = "../raster-images/roads/", layer="gis_osm_roads_free_1")

# Constants 
# EXT = extent(47.51871539268088, 47.52892924460959, -18.909938181254358, -18.899869284806574)
EXT = extent(47.444234393272836, 47.597356341515024, -18.979181764634195, -18.84114482366273)
RES = 1000
GRAPH_INC = 10

# Crop and transform roads shapefile
roads_crop = crop(roads, EXT)
roads_utm = spTransform(roads_crop, CRS("+init=epsg:21037"))
roads_base = raster(ext=extent(roads_utm), resolution=RES, crs = projection(roads_utm))

# Determine road presence in each cell 
lengths = sapply(1:ncell(roads_base), function(i) {
  tmp_rst = roads_base
  tmp_rst[i] = 1
  tmp_shp = rasterToPolygons(tmp_rst)
  
  if (gIntersects(roads_utm, tmp_shp)) {
    roads_utm_crp = crop(roads_utm, tmp_shp)
    roads_utm_crp_length = gLength(roads_utm_crp)
    return(roads_utm_crp_length)
  } else {
    return(0)
  }
})
# Invert results to represent friction
roads_base[] = max(lengths) - lengths
# roads_base

# Read in elevation shapefile 
elevation_file = raster("../raster-images/elevation/elevation.tif")
elevation = projectRaster(elevation_file, roads_base, method="bilinear")
# elevation

# Normalize friction surface inputs 
roads_base = normImage(roads_base)
elevation = normImage(elevation)
min_val = minValue(roads_base)
roads_base = calc(roads_base, function(x) x+(-min_val))
elevation = abs(elevation)
elevation = calc(elevation, function(x) x/2)

roads_base
elevation

# Stack friction inputs 
friction_stack <- stack(c(roads_base, elevation))
friction_map <- calc(friction_stack, sum)

# Plot friction surface 
outplot = spplot(friction_map, 
                 scales = list(draw = TRUE),
                 col.regions = colorRampPalette(brewer.pal(9, "BuPu")), 
                 sp.layout = list("sp.lines", roads_utm),
                 at = seq(0, maxValue(roads_base)+0.1, 0.2))

# Plot blurred map
friction_map_blur = disaggregate(friction_map, fact=100, method="bilinear")
friction_map_blur = calc(friction_map_blur, function(x) x/10)
friction_map_blur

outplot = spplot(friction_map_blur, 
                 scales = list(draw = TRUE),
                 col.regions = colorRampPalette(brewer.pal(9, "PRGn")), 
                 sp.layout = list("sp.lines", roads_utm),
                 at = seq(0, maxValue(friction_map_blur)+0.1, 0.025))

outplot

