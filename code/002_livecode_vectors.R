#### Load packages ----
library(tidyverse)
library(sf)
library(terra)

#### Load data ----
moo = read_sf("data/moorea_outline.shp")
fieldSites_df = read_csv("data/fieldSiteLocations.csv")

moo
moo$geometry
plot(moo[1])

#### Make me spatial!
fieldSites_df
fieldSites_sf <- fieldSites_df %>%
  st_as_sf(coords = c("x","y"),
           crs = 4326) %>%
  st_transform(crs = st_crs(moo))
fieldSites_sf


#### Tangent ----
fieldSites_sf
### For getting just the df
st_drop_geometry(fieldSites_sf)
### Can be useful for grabbing coords
st_coordinates(fieldSites_sf)



#### Visualize ----
ggplot() +
  geom_sf(data = moo) +
  geom_sf(data = fieldSites_sf,
          aes(col = site))

?st_distance()

#### Measure distance from coast using st_distance
fieldSites_sf$distFromCoast = st_distance(fieldSites_sf, moo)
fieldSites_sf
#### Apparently this works too:
st_distance(moo, fieldSites_sf)

units::set_units(st_area(moo), km^2)


#### Buffering
moo_buff = moo %>%
  st_buffer(dist = 5000)

ggplot() +
  geom_sf(data = moo_buff) +
  geom_sf(data = moo)

#### Import rast
sst = rast("data/SST_2019.tif")
sst

moo_lonlat = moo %>%
  st_transform(st_crs(sst))
moo_lonlat

fieldSites_lonlat = fieldSites_sf %>%
  st_transform(st_crs(sst))
fieldSites_lonlat

sst
sst[[100]]

fieldSites_lonlat
fieldSites_vect = vect(fieldSites_lonlat)
fieldSites_vect

?extract
extract(sst[[100]], fieldSites_vect)
plot(sst[[100]])

plot(crop(sst[[100]], ext(fieldSites_vect)))
lines(moo_lonlat)

fieldSites_vect
temp_ext = extract(sst[[100]], fieldSites_vect)
temp_ext

fieldSites_sf$temp = temp_ext$`2019-04-10`
fieldSites_sf
points(fieldSites_lonlat)


