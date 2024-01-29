library(sf)
library(terra)
library(ggplot2)

#### Part 0: Data prep ----
## > Vector data ----
## Note that the Moorea vector data came from the French Polynesia Directorate of Land Affairs
## https://www.data.gouv.fr/fr/datasets/base-de-donnees-cartographique-vectorielle/
# read_sf("/Users/christianjohn/Documents/Burkepile_Lab/Data/France_gov/Vector_data/SHP/Moorea/Moorea_20200512_104135_SHP/Moorea_LOC_ILE.shp") %>%
#   st_simplify(preserveTopology = T, dTolerance = 10) %>%
#   st_write("data/moorea_outline.shp", append = F)

## MCR sites: Walk people through how to make this
## Note that these locations are approximate and should not be used for MCR analyses!!!
mcr = data.frame(x = c(-149.837, -149.803, -149.763, 
                       -149.768, -149.864, -149.919),
                 y = c(-17.480, -17.476, -17.506,
                       -17.539, -17.583, -17.514),
                 site = paste0("LTER 0", c(1:6))) %>%
  st_as_sf(coords = c("x","y"),
           crs = 4326)
plot(mcr)

## > Raster data ----
## Note that the Moorea hillshade layer came from the Copernicus mapping mission
## Dataset was prepped and exported from Google Earth Engine
## This is a 30-m product
# dem = rast("/Users/christianjohn/Documents/Burkepile_Lab/Data/Copernicus/DSM/DSM.tif")
# dem_slope = terrain(dem, v = "slope", unit="radians")
# dem_aspect = terrain(dem, v = "aspect", unit="radians")
# dem_hillshade = shade(dem_slope, dem_aspect)
# writeRaster(dem_hillshade,"data/hillshade.tif", overwrite = T)



#### Part I: Importing spatial data ----
## > Vector data ----
## Note that the Moorea vector data came from the French Polynesia Directorate of Land Affairs
## https://www.data.gouv.fr/fr/datasets/base-de-donnees-cartographique-vectorielle/
moo = read_sf("data/moorea_outline.shp")
moo


## > Raster data ----
## Note that the Moorea hillshade layer came from the Copernicus mapping mission
## Dataset was prepped and exported from Google Earth Engine
hill = rast("data/hillshade.tif")
hill


#### Part II: Take a peek under the hood ----
## > Vector data ----
## Note that when you look at moo:
## there is a geometry column! This stores the important spatial stuff. Everything else is just summary info
moo
st_crs(moo) # Note that epsg 3297 is UTM 6S
plot(moo)
ggplot() + geom_sf(data = moo)

## > Raster data ----
hill
st_crs(hill)
plot(hill)
hill_df = as.data.frame(hill, xy = T)
head(hill_df)




#### Putting it all together: Make a map! ----
## > Get everything into the same crs ----
moo_latlon = moo %>%
  st_transform(st_crs(hill))

ggplot() +
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
  geom_sf(data = mcr) +
  geom_label(data = mcr %>% mutate(x = st_coordinates(.)[,1],
                                   y = st_coordinates(.)[,2]),
             aes(x = x,
                 y = y,
                 label = site)) +
  theme_void()



