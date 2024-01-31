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
  return(img.clip(ROI));
};

var dem = ee.ImageCollection("COPERNICUS/DEM/GLO30")
    .select("DEM")
    .filterBounds(ROI)
    .map(clipper)
    .toBands();
print("dem",dem);

Export.image.toDrive({
  image: dem,
  description: "DSM",
  folder: "Copernicus_DSM",
  fileNamePrefix: 'DSM',
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

### MODIS Sea Surface Temperatures
MODIS SST came from the Ocean Color Level-3 Standard Mapped Image (L3SMI) products provided by NASA Goddard Space Flight Center. Median SST for first 90 days of the year between 2015-2020 was pre-processed in Google Earth Engine using:

```
var clipper = function(img){
  return(img.clip(ROI));
};

var MOD = ee.ImageCollection("NASA/OCEANDATA/MODIS-Aqua/L3SMI")
.filterBounds(ROI)
.select("sst")
.filter(ee.Filter.date("2015-01-01","2020-12-31"))
.filter(ee.Filter.dayOfYear(1,91))
.map(clipper)
.median();

var myCRS = "EPSG:3297";

Export.image.toDrive({
  image:MOD,
  region:ROI,
  description:"MODmed",
  folder:"SpatialWorkshop",
  scale: 4616,
  crs: myCRS
});
```