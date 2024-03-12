#### Working with vector data
library(sf)
library(tidyverse)
library(terra)

#### Goals:
# Reprojecting
st_transform()

# Changing shapes
st_buffer()
st_crop()

# Coordinates
st_coordinates()
st_drop_geometry()

# Measurements
st_distance()
st_length()
st_area()

# Pulling raster data
terra::vect()
terra::ext()

# ggplot integration

## REMEMBER: HOMEWORK ASSIGNMENT:
## Come with a map tomorrow, one you like or one you don't like or whatever.

#### Import data ----
fieldSites_df = read_csv("data/fieldSiteLocations.csv")
moo = read_sf("data/moorea_outline.shp")

#### Prep data ----
fieldSites_sf = fieldSites_df %>%
  st_as_sf(coords = c("x","y"),
           crs = 4326) %>%
  st_transform(st_crs(moo))

#### Visualize ----
ggplot() +
  geom_sf(data = moo) +
  geom_sf(data = fieldSites_sf)


#### How far are my sites from Mo'orea?
fieldSites_sf$distFromShore = as.numeric(st_distance(fieldSites_sf, moo))

ggplot() +
  geom_sf(data = moo) +
  geom_sf(data = fieldSites_sf,
          col = "black", size = 3) +
  geom_sf(data = fieldSites_sf,
          aes(col = distFromShore),
          size = 2) +
  scale_color_viridis_c("Distance\nfrom\nshore (m)",
                        option = "magma", 
                        direction = -1) +
  theme_void()






