library(terra)
library(sf)
library(tidyverse)

#### Import data ----
## Raster
## NOAA SST data level 4 gap filled gridded
## https://coralreefwatch.noaa.gov/product/5km/index.php
myPaths = list.files("~/Downloads", pattern = "coraltemp", full.names = T)
myPaths

## Vector: just need for an ROI
fp = rnaturalearth::ne_countries(scale = 10, returnclass = "sf",
                                 country = "French Polynesia")
plot(fp[1])

#### Data wrangling ----
## Create ROI
frenchPolyExt = ext(fp)

#### A function to import, project, and crop a raster layer ----
prepLayer = function(x, ROI = frenchPolyExt){
  t1 = terra::rast(x, "//analysed_sst")
  # t1
  # plot(t1)
  ## t1 is missing spatial info
  ## Seems to be a known issue
  ## https://github.com/rspatial/terra/issues/314
  ## Entity_Type_Label: Grid Intersection
  ## Entity_Type_Definition:
  ##  There are 7200 grid intersections in each row (at a pre-defined latitude) and 3600 grid intersections in each column (at a pre-defined longitude). Each grid is 0.05 degrees latitude by 0.05 degrees longitude in size, centered at latitudes from 89.975S northward to 89.975N and at longitudes from 179.975W eastward to 179.975E.
  ## Entity_Type_Definition_Source: https://coralreefwatch.noaa.gov/product/5km/index.php
  crs(t1) <- "epsg:4326"
  ## can also do 
  ## crs(t1) <- st_crs(4326)$proj4string
  ## Note that the peripheral grid cells are *centered* on -179.975 and 179.975, but that means the actual extent of the data layer (i.e. edge of grid cells) is -180 to 180
  ext(t1) <- c(-180,180,-90,90)
  # plot(t1)
  ## Crop to ROI
  ## Note that the netcdf dataset gets imported upside down but terra has a function to overcome, `flip()`
  tc = t1 %>%
    flip(direction="vertical") %>%
    crop(ROI)
  plot(tc, main = x)
  return(tc)
}

## Apply the function across all layers
rastList = lapply(myPaths,
                  FUN = prepLayer)

#### Create a final rast object
SST = rast(rastList)
SST
myDates = seq.Date(from = as.Date("2019-01-01"), to = as.Date("2019-05-05"),
                   by = "1 day")
myDates
names(SST) <- myDates
SST
writeRaster(SST, filename = "data/SST_2019.tif")

