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
