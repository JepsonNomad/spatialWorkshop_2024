# Data provenance

### Moorea outline
Moorea vector data came from the French Polynesia Directorate of Land Affairs ([link](https://www.data.gouv.fr/fr/datasets/base-de-donnees-cartographique-vectorielle/)) and was prepared using:
```
read_sf("/Users/christianjohn/Documents/Burkepile_Lab/Data/France_gov/Vector_data/SHP/Moorea/Moorea_20200512_104135_SHP/Moorea_LOC_ILE.shp") %>%
 st_simplify(preserveTopology = T, dTolerance = 10) %>%
 st_write("data/moorea_outline.shp", append = F)
```

### Moorea hillshade
Moorea hillshade data came from the Copernicus mapping mission. This 30m dataset was prepped and exported from Google Earth Engine using:
```
var clipper = function(img){
  return(img.clip(ROI2));
};

var dem = ee.ImageCollection("COPERNICUS/DEM/GLO30")
.select("DEM")
.filterBounds(ROI2)
.map(clipper)
.toBands();
print("dem",dem);

Map.centerObject(ROI, 14);
Map.addLayer(dem,{min:0,max:1200},"dem_clip");

Export.image.toDrive({
  image: dem,
  description: "DSM",
  folder: "Copernicus_DSM",
  fileNamePrefix: 'DSM_buffered',
  maxPixels: 1e13,
  scale: 30,
  region: ROI
});
```

and wrangled in R using:
```
dem = rast("/Users/christianjohn/Documents/Burkepile_Lab/Data/Copernicus/DSM/DSM.tif")
dem_slope = terrain(dem, v = "slope", unit="radians")
dem_aspect = terrain(dem, v = "aspect", unit="radians")
dem_hillshade = shade(dem_slope, dem_aspect)
writeRaster(dem_hillshade,"data/hillshade.tif", overwrite = T)
```