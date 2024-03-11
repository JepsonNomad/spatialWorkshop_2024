library(terra)
library(sf)
library(tidyverse)

#### Import data ----
fp = rnaturalearth::ne_countries(scale = 10, returnclass = "sf",
                                 country = "French Polynesia")## %>%
# st_make_valid() %>%
# st_crop(ROIsf)
plot(fp[1])

## Consider creating a custom extent
ROI = c(-155,-135,-28,-8)
ROI

## https://coralreefwatch.noaa.gov/product/5km/tutorial/welcome.php
## https://coralreefwatch.noaa.gov/product/5km/tutorial/crw04b_data_delivery.php
## https://coralreefwatch.noaa.gov/product/5km/tutorial/crw10a_dhw_product.php
## https://www.coris.noaa.gov/metadata/records/html/crw_v3.1_5km_suite_xml_20180813.html
t1 = terra::rast("data/ct5km_dhw_v3.1_20190409.nc", "//degree_heating_week")
t1
plot(t1)
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
plot(t1)
## Crop to ROI
tc = t1 %>%
  crop(ROI)
t1
tc
plot(tc)

tcdf = as.data.frame(tc, xy=T)
head(tcdf)

ggplot() +
  geom_raster(data = tcdf,
              aes(x = x, y = y, 
                  fill = degree_heating_week)) +
  geom_sf(data = fp %>% st_transform(st_crs(tc)),
          col = "black",
          fill = "grey90") +
  scale_fill_viridis_c("DHW",option="magma",direction = -1) +
  coord_sf(expand = F) +
  xlab("") + ylab("")


#### Working with rasters ----
SST = rast("data/SST_2019.tif")
SST
SST_rcl = classify(SST, rcl = matrix(data = c(0,2900,0),
                                     ncol = 3,
                                     byrow = T))
plot(SST[[1]])
plot(SST_rcl[[1]])
## Show this again with NA

## Suppose we want to know how many days there were heat stress
SST_rcl2 = classify(SST, rcl = matrix(data = c(0,2900,0,
                                               2900.000001, 40000, 1),
                                     ncol = 3,
                                     byrow = T))
plot(SST_rcl2[[1]])
SST_sum = app(SST_rcl2, sum)
plot(SST_sum)

#### Reprojecting rasters ----
## Bilinear interpolation viz
## https://en.wikipedia.org/wiki/Bilinear_interpolation#/media/File:Bilinear_interpolation_visualisation.svg
crsOptions = paste0("epsg:",c(4326, 32706))
crsOptions
crsLongList = rep(crsOptions,10)
crsLongList

crs(tc)
tc2 = project(tc, crsOptions[2])
tc3 = project(tc2, crsOptions[1])
plot(tc)
plot(tc2)
plot(tc3)
plot(tc2)
tc4 = crop(tc3, tc)
plot(tc)
plot(tc4)

tcTester = tc
for(i in 1:11){
  tcTester = project(tcTester,crsLongList[i])
}
tc
tcTester
plot(tc)
plot(crop(tcTester, tc))

hist(tc)
hist(tcTester)
