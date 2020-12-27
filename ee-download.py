import ee
import ee.mapclient
import time
import datetime
import sys

# Authenticate GEE account 
ee.Authenticate()
ee.Initialize()


# Method to generate polygons from center points and grid sizes
def generate_polygons(coordinates, boxSize):
  polygons = []
  for c in coordinates:
    bw = boxSize[0]/2
    bh = boxSize[1]/2
    wc = c[0]
    hc = c[1]

    polygon = ee.Geometry.Polygon([
      [[wc-bw, hc-bh],
      [wc+bw, hc-bh],
      [wc+bw, hc+bh],
      [wc-bw, hc+bh],
      [wc-bw, hc-bh]
      ]
    ])

    polygons.append(polygon)
  return polygons

# Special function for processing Sentinel-2 dataset
def process_sentinel(dataset, time_range, area):

    # remove clouds from images with masking
    def maskclouds(image):
        band_qa = image.select('QA60')
        cloud_m = ee.Number(2).pow(10).int()
        cirrus_m = ee.Number(2).pow(11).int()
        mask = band_qa.bitwiseAnd(cloud_m).eq(0) and(
            band_qa.bitwiseAnd(cirrus_m).eq(0))
        return image.updateMask(mask).divide(10000)

    # produce filtered image using median
    filter_image = (ee.ImageCollection(dataset).
                         filterBounds(area).
                         filterDate(time_range[0], time_range[1]).
                         filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 20)).
                         map(maskclouds))

    sentinel_median = filter_image.median()
    # image_band = sentinel_median.select(['B4','B3','B2'])
    return sentinel_median

# Download image collection (stacked rasters)
def download_collection(datasets, timerange, coordinates, outputFolder, scale, report=False, testRun=True):
      
  print("Exporing Image Collection to " + outputFolder + " Folder")

  for d_i,d in enumerate(datasets):
    
    print("\nProcessing " + d + "...")
    
    for c_i, c in enumerate(coordinates):

      if d == "COPERNICUS/S2" or d == "COPERNICUS/S2_SR":
        image = process_sentinel(d, timerange, c)
      else:
        collection = (ee.ImageCollection(d)
                .filterDate(timerange[0], timerange[1])
                .filterBounds(c)
                )
        image = collection.first().clip(c)

      if testRun:
        print("Dataset: " + str(d_i) + ", Coordinates: " + str(c_i))
      else:
        print("Sending img_"+ str(d_i) + "_" + str(c_i)+" to GEE...", end=" ")
        task = ee.batch.Export.image.toDrive(
            image=image,
            description="img_" + str(d_i) + "_" + str(c_i),
            folder=outputFolder,
            region=c,
            scale=30
        )
        task.start()
        print("\x1b[32mComplete\x1b[0m")

    print("Complete")

# Download single image rather than image collection 
def download_image(dataset, timerange, coordinates, outputFolder, scale, report=False, testRun=True):
  
  print("Exporing Image Collection to " + outputFolder + " Folder")
  
  for d_i, d in enumerate(dataset):
    for ind, coordinate in enumerate(coordinates): 
      image = (ee.Image(d))
      image = image.clip(coordinate)

      task = ee.batch.Export.image.toDrive(
              image=image,
              description="image" + str(d) + str(ind),
              folder=outputFolder,
              scale=1,
          )
      task.start()

    print("Complete")

# Example of calling download_collection function 
# Uncomment below for a test example 

# datasets = ['CIESIN/GPWv411/GPW_Basic_Demographic_Characteristics', 
#             'NASA/FLDAS/NOAH01/C/GL/M/V001', 
#             'NASA/GLDAS/V021/NOAH/G025/T3H'
#             ]
# centers = [[ 48.299830, -21.245750],[43.6696600, -23.3541730]]
# box = [1.5, 1.5]
# dates = [datetime.datetime(2010, 1, 1), datetime.datetime(2019, 5, 1)]
# download_collection(datasets=datasets, timerange=dates, coordinates=generate_polygons(centers, box) , outputFolder='testing_ee', scale=1, testRun=False)