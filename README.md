## ee-pipeline 
This respository contains files used to download and stack raster and satellite images from Google Earth Engine. 

### ee-download
Used to download images from Google Earth Engine. Available in both **Python** and **Python Notebook** file formats. The **Python Notebook** format has the advantage that the authentication does not need to be completed every run, and instead can be run once as a separate cell. 

Google Earth Engine datasets are either in the form of a collection (raster stack) or single image. Each of these has different methods for downloading, which can be done using the functions *download_collection* and *download_image* respectivley. Both function calls accept the same parameters:  

```
download_collection(datasets, timerange, coordinates, outputFolder, scale, testRun)
```

An example of a function call is included at the end of each code files.

### raster-pipeline 
These files are used to stack a repository of downloaded Google Earth Engine files into a single raster stack. This code is available in both **R** and **Python Notebook** format. The **Python** file contains a detailed description of each method and the required function call inputs. The required parameters are: 

> INPUT_DIR: Accepts a folder name with input tifs

> INTER_DIR: A temporary directory used for processing. Should be separate from other directories

> OUTPUT_DIR: Output folder directory

> TARGET_EXT: Extent box desired for raster stack 

> TARGET_RES: The resolution (in lat, long) desired for raster stack


### raster-analysis
Used to run various statistical analyses on a raster stack or data input. Also used to output analyses visualizations. Only available in **R** file format, as the visualizations are made particularly easy in **R**. 
