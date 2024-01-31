## Follow along here.

#### Load pacakges
library(sf)
library(terra)
library(tidyverse)

#### Import data
moo = read_sf("data/moorea_outline.shp")
moo
plot(moo)
moo

fieldSites_df = read_csv("data/fieldSiteLocations.csv")