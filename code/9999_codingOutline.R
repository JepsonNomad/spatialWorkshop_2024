#### Load packages ----
## sf, terra, and tidyverse
library(sf)
library(terra)
library(tidyverse)


#### Resources ----
## .... The following are some useful web resources ----

# Check out the sf cheatsheet from rstudio github
# https://github.com/rstudio/cheatsheets/blob/main/sf.pdf

# Visit sf and terra documentation
# https://cran.r-project.org/web/packages/sf/sf.pdf
# https://cran.r-project.org/web/packages/terra/terra.pdf



#### Part 0: Data prep ----
## .... Vector data ----
## Note that the Moorea vector data came from the French Polynesia Directorate of Land Affairs
## https://www.data.gouv.fr/fr/datasets/base-de-donnees-cartographique-vectorielle/
# read_sf("/Users/christianjohn/Documents/Burkepile_Lab/Data/France_gov/Vector_data/SHP/Moorea/Moorea_20200512_104135_SHP/Moorea_LOC_ILE.shp") %>%
#   st_simplify(preserveTopology = T, dTolerance = 10) %>%
#   st_write("data/moorea_outline.shp", append = F)

## Create a field site dataset as a data.frame
## Note that these locations are invented and should not be used for MCR analyses!!!
# fieldSites_df = data.frame(x = c(-149.837, -149.803, -149.763, 
#                                  -149.768, -149.864, -149.919),
#                            y = c(-17.480, -17.476, -17.506,
#                                  -17.539, -17.583, -17.514),
#                            site = c("Alpha","Bravo","Charlie","Delta","Echo","Foxtrot"))
# fieldSites_df
# write_csv(fieldSites_df,file="data/fieldSiteLocations.csv")

## .... Raster data ----
## Note that the Moorea hillshade layer came from the Copernicus mapping mission
## Dataset was prepped and exported from Google Earth Engine
## This is a 30-m product
# dem = rast("/Users/christianjohn/Documents/Burkepile_Lab/Data/Copernicus/DSM/DSM.tif")
# writeRaster(dem,"data/dem.tif", overwrite = T)
# dem_slope = terrain(dem, v = "slope", unit="radians")
# dem_aspect = terrain(dem, v = "aspect", unit="radians")
# dem_hillshade = shade(dem_slope, dem_aspect)
# writeRaster(dem_hillshade,"data/hillshade.tif", overwrite = T)



#### Part I: Importing spatial data ----
## .... Raster data ----

## Raster data are pretty much only ever .tif files
## (yes there are exceptions but the following pattern holds generally true)

## Note that the Moorea hillshade layer came from the Copernicus mapping mission
## Dataset was prepped and exported from Google Earth Engine
hill = rast("data/hillshade.tif")
hill
str(hill)
plot(hill)
st_crs(hill)
# "EPSG",4326

dem = rast("data/dem.tif")


## Median sea surface temperature Jan-Mar, 2015-2020 inclusive 
## MODIS Aqua L3SMI from NASA Goddard via Google Earth Engine
sst = rast("data/MODmed.tif")
sst
str(sst)
plot(sst)
st_crs(sst)
# "EPSG",3297



## .... Vector data: Polygons ----

## Two common formats you find vector data:
# -shapefiles
# -csv files with lat/long or other coords

## Note that the Moorea vector data came from the French Polynesia Directorate of Land Affairs
## https://www.data.gouv.fr/fr/datasets/base-de-donnees-cartographique-vectorielle/
moo = read_sf("data/moorea_outline.shp")
moo
plot(moo[1])

## .... Vector data: Points ----
## Walk people through how to make this; starting with data.frame
## And then add coordinates and reference system
## Import field site locations
fieldSites_df = read_csv("data/fieldSiteLocations.csv")
## Convert them into an sf object
## What two things do we need to tell sf? 
fieldSites_sf = fieldSites_df %>%
  st_as_sf(coords = c("x","y"),
           crs = 4326)
plot(fieldSites_sf)


#### Part II: Take a peek under the hood ----
## .... Vector data: polygons ----
## Note that when you look at moo:
## there is a geometry column! This stores the important spatial stuff. Everything else is just summary info
moo
st_crs(moo) # Note that epsg 3297 is UTM 6S
plot(moo)
ggplot() + geom_sf(data = moo)

## .... Vector data: points ----
fieldSites_sf
str(fieldSites_sf)

## .... Raster data ----
hill
st_crs(hill)
plot(hill)
hill_df = as.data.frame(hill, xy = T)
head(hill_df)


#### Part 3: Spatial data tinkering ----
#### Part 3a: Working within data types ----
## .... Vector data ----
## .... Spatialize field data with left_join ----
surveys = read_csv("data/surveys.csv")
fieldSites_sf

## Note, sided joins will repeat the contents of the right data.frame
## for each row in the left data.frame where the "by" columns match
surveys %>%
  left_join(fieldSites_sf)
fieldSites_sf %>%
  right_join(surveys)
## Which one do we want?
surveys_sf = fieldSites_sf %>%
  right_join(surveys)

## Let's plot it out
ggplot() +
  geom_sf(data = moo) +
  geom_sf(data = surveys_sf)

## Note: Normal tidyverse operations now apply!
## Demonstrate with filter()
surveys_sf %>%
  filter(year > 2018)

## Let's do a group_by() and summarize()
surveys_sf %>%
  group_by(site) %>%
  summarize(cots = mean(cots)) %>%
  ggplot() +
  geom_sf(data = moo) +
  geom_sf(data = surveys_sf,
          aes(col = cots)) +
  scale_color_viridis_c()

## .... Raster data ----
## First, some raster algebra
dem
dem*2 # Note, same resolution, extent, dimension. But VALUES changed
plot(dem)
plot(dem*2)

## Next, generate summary statistics
?global
# General summary values
global(dem, fun = "min", na.rm = T)
global(dem, fun = "mean", na.rm = T)
global(dem, fun = "max", na.rm = T)
# or custom functions
global(dem, fun = function(x){quantile(x,0.2,na.rm=T)})
lowEls = global(dem, fun = function(x){sum(x<200,na.rm=T)})
highEls = global(dem, fun = function(x){sum(x>=200,na.rm=T)})
lowEls/(lowEls+highEls)
## 61% of island is below 200m


## .... Challenge: Raster math with the sst data ----
## Can you convert the sst raster from Celcius to Farenheit?
## Plot the result.
## If you have time, find the minimum, maximum, and 
## mean sea surface temperatures in the greater Moorea area


#### Part 3b: Interoperability ----
## Convert sf objects with vect() to work with rasters
## Convert terra objects with as.data.frame() to work with ggplot
## Always remember to pay attention to crs at this critical step

# e.g. to pull out sst by site, we need to turn fieldSites_sf into a terra object
st_crs(sst)
st_crs(fieldSites_sf)
fieldSites_vect = fieldSites_sf %>%
  st_transform(crs = st_crs(sst)) %>%
  vect()
fieldSites_vect

fieldSites_temps = terra::extract(x = sst,
                                  y = fieldSites_vect)
fieldSites_sf %>%
  mutate(sst = fieldSites_temps$sst) %>%
  ggplot() +
  geom_point(aes(x = site, y = sst))

#### Part 4: Putting it all together: Make a map! ----
## .... Discussion: what makes a good map? ----

## Simple!!!
## Aesthetic
## Emphasizes the data you want to show
## North arrow? Scale bar? Know thy audience


## .... Get everything into the same crs ----
moo_latlon = moo %>%
  st_transform(st_crs(hill))

sst_latlon = sst %>%
  project(crs(hill), method = "bilinear")
sst_latlon
plot(sst_latlon)
sst_latlon_df = sst_latlon %>%
  as.data.frame(xy = T) %>%
  tibble()

## .... Let people loose! ----
## See what kinds of maps folks come up with
ggplot() +
  geom_raster(data = sst_latlon_df,
              aes(x = x, y = y, fill = sst)) +
  scale_fill_viridis_c(option="A") +
  ggnewscale::new_scale_fill() +
  geom_raster(data = hill_df,
              aes(x = x, y = y, fill = hillshade),
              show.legend = FALSE) +
  scale_fill_distiller(type = "seq",
                       direction = -1,
                       palette = "Greys") +
  geom_sf(data = moo_latlon,
          fill = "transparent",
          col = "grey60",
          linewidth = 0.5) +
  geom_sf(data = fieldSites_sf, col = "white") +
  geom_label(data = fieldSites_sf %>% 
               mutate(x = st_coordinates(.)[,1],
                      y = st_coordinates(.)[,2] - 0.0125),
             aes(x = x,
                 y = y,
                 label = site),
             col = "white",
             fill = "transparent") +
  theme_void()

## Discussion: What do we learn from the data by plotting everything together?
## How could we improve these maps?

#### Conclusion ----
## What would you like to see out of future spatial workshops? 
## Specific spatial tasks? e.g. data wrangling, finding distances, linking related datasets using spatial descriptors, etc?


