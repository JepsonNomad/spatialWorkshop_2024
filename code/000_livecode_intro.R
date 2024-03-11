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
surveys = read_csv("data/surveys.csv")
surveys


surveys_sf = fieldSites_sf %>%
  left_join(surveys)

ggplot() +
  geom_sf(data = surveys_sf) +
  geom_sf(data = moo)


surveys_summary = surveys_sf %>%
  group_by(site) %>%
  summarize(mostCorals = max(bigcorals))
surveys_summary

ggplot() +
  geom_sf(data = surveys_summary,
          aes(col = mostCorals)) +
  geom_sf(data = moo)


#### Working with rasters ----
hill
hill_df = as.data.frame(hill, xy=T)
head(hill_df)

mycrs = st_crs(hill)

moo_lonlat = moo %>%
  st_transform(crs = mycrs)

moo_lonlat

ggplot() +
  geom_sf(data = moo_lonlat) +
  geom_raster(data = hill_df,
              aes(x = x,
                  y = y,
                  fill = hillshade)) +
  geom_sf(data = moo_lonlat,
          fill = "transparent",
          lwd = 1,
          col = "grey60") +
  geom_sf(data = surveys_summary,
          size = 2,
          col = "black") +
geom_sf(data = surveys_summary,
        aes(col = mostCorals)) +
  scale_color_viridis_c()
surveys_summary


