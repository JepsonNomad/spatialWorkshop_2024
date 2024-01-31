## Follow along here.

#### Load pacakges
library(sf)
library(terra)
library(tidyverse)

#### Import data; vector ----
moo = read_sf("data/moorea_outline.shp")
moo
plot(moo)
moo

fieldSites_df = read_csv("data/fieldSiteLocations.csv")

fieldSites_sf =  fieldSites_df %>%
  st_as_sf(coords = c("x", "y"),
           crs = 4326)
fieldSites_sf


#### Import data, raster ----
sst = terra::rast("data/MODmed.tif")
sst
plot(sst)

hill = rast("data/hillshade.tif")
hill
plot(hill)


#### Wrangling ---


