library(raster)
library(rgdal)
library(rgeos)
library(RColorBrewer)
library(RStoolbox)

# Constants 
# EXT = extent(47.51871539268088, 47.52892924460959, -18.909938181254358, -18.899869284806574)
EXT = extent(47.444234393272836, 47.597356341515024, -18.979181764634195, -18.84114482366273)
RES = 1000
GRAPH_INC = 10

walk_based <- function(){
  slope = raster(ext=EXT, resolution=RES, crs = CRS("+init=epsg:21037"))
  slope_file = raster("friction-map-inputs/finalslope.tif")
  slope_raster = projectRaster(slope_file, roads_base, method="bilinear")
  
  elevation_file = raster("friction-map-inputs/elevation.tif")
  elevation_raster = projectRaster(elevation_file, roads_base, method="bilinear")
  
  avg_speed = 3.5
  
  elev_factor = 1.016*exp(-0.0001072*elevation_raster)
  slop_factor = 1/5
  
  final_walking = 1 / (elev_factor * slop_factor * (6*exp(-3.5*abs(tan(0.01745*slope_raster) + 0.01))))
  # spplot(final_walking)
  
  friction_map_blur = disaggregate(final_walking, fact=1000, method="bilinear")
  friction_map_blur = calc(friction_map_blur, function(x) x/10)
  friction_map_blur = friction_map_blur / 100
  friction_map_blur
  outplot = spplot(friction_map_blur,
                   scales = list(draw = FALSE),
                   col.regions = colorRampPalette(brewer.pal(9, "BuPu")),
                   sp.layout = list("sp.lines", roads_utm),
                   at = seq(0, maxValue(friction_map_blur), 0.01/100)
  )
  
  outplot
  
}

walk_based()

road_based <- function(){
  # Read in roads shapefile (LARGE FILE)
  roads = readOGR(dsn = "../raster-images/roads/", layer="gis_osm_roads_free_1")
  
  
  
  # Crop and transform roads shapefile
  roads_crop = crop(roads, EXT)
  roads_utm = spTransform(roads_crop, CRS("+init=epsg:21037"))
  roads_base = raster(ext=extent(roads_utm), resolution=RES, crs = projection(roads_utm))
  highway_base = raster(ext=extent(roads_utm), resolution=RES, crs = projection(roads_utm))
  
  
  
  #---------------------------------------------------------------------------------------------------
  # CALCULATE FRICTION LAYERS 
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
  lengths = lengths
  
  highways = sapply(1:ncell(roads_base), function(i) {
    tmp_rst = roads_base
    tmp_rst[i] = 1
    tmp_shp = rasterToPolygons(tmp_rst)
    
    if (gIntersects(roads_utm, tmp_shp)) {
      roads_utm_crp = crop(roads_utm, tmp_shp)
      roads_utm_crp_length = 0
      road_names_all = roads_utm_crp$ref
      if(length(road_names_all[!is.na(road_names_all)]) != 0){
        roads_utm_crp_length = 50
      }
      return(roads_utm_crp_length)
    } else {
      return(0)
    }
  })
  highways = highways
  
  elevation_file = raster("../raster-images/elevation/elevation.tif")
  elevation = projectRaster(elevation_file, roads_base, method="bilinear")
  
  
  #---------------------------------------------------------------------------------------------------
  # Set Spatial DS
  roads_base[] = lengths
  highway_base[] = highways
  
  plot(roads_base)
  plot(highway_base)
  plot(elevation)
  
  #---------------------------------------------------------------------------------------------------
  # Normalize
  road_norm = normImage(roads_base)
  highway_norm = normImage(highway_base)
  elevaton_norm = normImage(elevation)
  
  #---------------------------------------------------------------------------------------------------
  # Transform
  min_road = minValue(road_norm)
  final_road = calc(road_norm, function(x) x+(-min_road))
  
  min_highway = minValue(highway_norm)
  final_highway = calc(highway_norm, function(x) x+(-min_highway))
  
  final_elevation = abs(elevaton_norm)
  
  # plot(final_road)
  # plot(final_elevation)
  # plot(final_highway)
  
  #---------------------------------------------------------------------------------------------------
  #  Stack friction inputs 
  friction_stack <- stack(c(final_road, final_elevation, final_highway))
  
  inv_road = 1-final_road
  min_road = minValue(inv_road)
  max_road = maxValue(inv_road)
  
  inv_road
  
  friction_map <- (inv_road - min_road) / (max_road - min_road)
  # Plot friction surface
  outplot = spplot(friction_map,
                   scales = list(draw = TRUE),
                   col.regions = colorRampPalette(brewer.pal(9, "BuPu")),
                   # sp.layout = list("sp.lines", roads_utm))
                   at = seq(0, 1, 0.1))
  outplot
  # 
  # 
  spplot(friction_map)
  
  
  
  #---------------------------------------------------------------------------------------------------
  # Plot blurred map
  friction_map_blur = disaggregate(friction_map, fact=1000, method="bilinear")
  friction_map_blur = calc(friction_map_blur, function(x) x/10)
  friction_map_blur = friction_map_blur / 100
  
  outplot = spplot(friction_map_blur,
                   scales = list(draw = FALSE),
                   col.regions = colorRampPalette(brewer.pal(9, "BuPu")),
                   sp.layout = list("sp.lines", roads_utm),
                   at = seq(0, maxValue(friction_map_blur)+0.001, 0.01/100)
                   )
  
  outplot
  
  # spplot(friction_map, col.regions = colorRampPalette(brewer.pal(9, "Reds")))
}


