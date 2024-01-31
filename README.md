# 2024 Spatial Workshop

This is a home page for the January 2024 Pile Lab Spatial Bonanza! Consider using the directory structure of this workshop folder to keep track of your data and code. I'd recommend using R Studio and making an R project. Please note: you will need recent installations of `sf`, `terra`, and `tidyverse`.

[Follow along with the live code here](https://github.com/JepsonNomad/spatialWorkshop_2024/blob/main/code/000_livecode.R)

-----

## Workshop goals:

In this workshop, we will:
- Get acquainted "spatial data": What is spatial data? What isn't spatial data?
- Differentiate raster and vector data structures
- Get ahold of some spatial data
- Inspect spatial datasets
- Plot spatial data (i.e. make a map!)

-----

## Timeline (total 60 min):
### Intro (15 min)
3 min get situated. Does everyone have packages installed?

10 min slideshow on:
- Spatial data
- Raster vs vector
- Reference systems
- Where can I get data from?

2 min for questions

### Import data (5 min)
`terra::rast()` and `sf::read_sf()`... sometimes additional import functions such as in `rnaturalearth::ne_countries()`.

### Inspect data structure; iterative process (10 min)
#### Explore data structure
`str()`, `print()`, `st_crs()`
#### Plot data 
Combining with the tidyverse and `ggplot()`, can do this with pipes if we're feeling up to it. Remember to ask: Do the reference systems of the two objects correspond?

### Tinkering with datasets (20 min)
Vector data:
- Spatializing field notes with `dplyr::left_join()`
- Subsetting datasets using `dplyr::filter()`
- Possibility: `st_intersection()`

Raster data:
- Raster algebra
- Summary statistics using `terra::global()`


### Combine different data types (map) (10 min)
- `st_transform()` - recall the CRS discrepancy earlier!
- Use `ggplot()` to lay the base
- Combine calls to `geom_sf()` and `geom_raster()`
- Consider experimenting with `ggplot2::theme_*()`
