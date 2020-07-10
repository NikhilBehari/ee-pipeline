import ee
import time
import datetime
import sys

def download_data(datasets, dates, coordinates, outputFolder, report=False):
    # dem = ee.Image('USGS/SRTMGL1_003')
    # xy = ee.Geometry.Point([86.9250, 27.9881])
    # elev = dem.sample(xy, 30).first().get('elevation').getInfo()
    # print('Mount Everest elevation (m):', elev)
    for ids,d in enumerate(datasets):
        collection = (ee.ImageCollection(d)
                .filterDate(dates[0], dates[1])
                .filterBounds(coordinates))

        collectionList = collection.toList(collection.size())
        collectionSize = collectionList.size().getInfo()
        print(collectionSize)


    
        # print('starting export')
        # # print(int(collection.size()), ee.Image(collection.toList(collection.size()).get(0)), list(collection.toList(collection.size()).getInfo))
        # sys.exit(1)
        # for imid,im in enumerate(collection):
        #     if imid > 2:
        #         sys.exit(1)
        for i,im in enumerate(range(2)):#collectionSize)):
            # if i > 2:
            #     sys.exit(1)
            # ee.batch.Export.image.toDrive(
            #     image = ee.Image(collectionList.get(i)).clip(rectangle), 
            #     fileNamePrefix = 'foo' + str(i + 1), 
            #     dimensions = '128x128').start()
            image = ee.Image(collectionList.get(i))
            image = image.select(['B4', 'B3', 'B2'])
            task = ee.batch.Export.image.toDrive(image=image#ee.Image(collectionList.get(i))
                                                 ).start()
                                                #  folder=outputFolder,
                                                #  description='imageDriveExample',
                                                #  crs='EPSG:4326',
                                                #  region=coordinates,
                                                # fileNamePrefix = d + '_' + str(i), 
                                                #  scale=30
            # task = ee.batch.Export.image.toDrive(image=im,
            #                                 #region=my_geometry.getInfo()['coordinates'],
            #                                 description=d+'_'+str(imid),
            #                                 folder=outputFolder,
            #                                 fileNamePrefix='_'.join(datasets),
            #                                 scale=my_scale,
            #                                 crs=my_crs)
            #print('start')
            #task.start()
            #print('done')
            #print(task.status())
    # if report:
    #     while task.status() == False:
    #         time.sleep(10)
    #         print(task.status())

if __name__ == "__main__":
    ee.Authenticate()
    ee.Initialize()
    datasets = ['LANDSAT/LE07/C01/T1_TOA']
    dates = [datetime.datetime(2002, 11, 1), datetime.datetime(2002, 12, 1)]
    polygon = ee.Geometry.Polygon([[
        [-109.05, 37.0], [-102.05, 37.0], [-102.05, 41.0],   # colorado
        [-109.05, 41.0], [-111.05, 41.0], [-111.05, 42.0],   # utah
        [-114.05, 42.0], [-114.05, 37.0], [-109.05, 37.0]]])
    download_data(datasets, dates, polygon, 'testing_ee')

