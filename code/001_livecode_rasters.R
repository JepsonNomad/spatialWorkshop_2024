## Live code for raster workshop

## Today: 
## Loading rasters, inspecting raster contents and structure
## Dealing with annoyances
## 

#### Load packages -----
library(terra)
library(sf)
library(tidyverse)

#### load data ----
fp = read_sf("data/FrenchPoly.shp")
fp

t1 = terra::rast("data/ct5km_dhw_v3.1_20190409.nc", "//degree_heating_week")