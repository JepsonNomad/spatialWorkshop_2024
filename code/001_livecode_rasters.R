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
plot(t1)
t1

## assign coords
crs(t1) <- "epsg:4326"
t1
ext(t1) <- c(-180,180,-90,90)
t1

plot(t1)

t1fp = crop(t1, ext(fp))
plot(t1fp)


SST <- rast("data/SST_2019.tif")
SST

SST
SST[[100]]
plot(SST[[100]])

?classify
heatstressPrep <- classify(SST[[100]], rcl = matrix(data = c(0,2900,0), ncol = 3))
plot(heatstressPrep)

plot(SST[[11]])

plot(SST[[11]] - 2900)

SST - 2900



sstex <- project(SST[[11]], "epsg:32706")
sstex
plot(SST[[11]])
plot(sstex)


crss <- rep(c("epsg:4326", "epsg:32707"),20)

for(i in 1:11){
  sstex <- project(sstex, crss[i])
}
SST[[11]]
sstex

plot(sstex)

sstexcrop = crop(sstex, SST[[11]])

plot(SST[[11]])
plot(sstexcrop)
