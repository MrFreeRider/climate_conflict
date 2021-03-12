#-------------------------------------#
# Cutting and converting raster images 
# from NDVI between 2000 to 2014 monthly
# By: Jose David Lopez
#-------------------------------------#

cat('\f')
rm(list=ls())
options('scipen'=100, 'digits'=4) # Forzar a R a no usar e+
setwd('~/Documents/GitHub/droughts_and_conflict')
getwd()

paquetes = c('tidyverse','rgdal','sf','sp','raster','viridis','gdalUtils')
for ( paquete in paquetes){
  if (length(grep(paquete,installed.packages()[,1])) == 0 ){ install.packages(paquete) ; print(paste0('La libreria ', '"', paquete ,'"', ' ha sido instalada.'))}
  else { print(paste0('La libreria ', '"', paquete ,'"', ' ya está instalada.'))}
  rm(paquete)
}

sapply(paquetes,require,character.only=T) 
rm(paquetes)

## Import raster. From .hdf to tiff 
"Raster from MODIS are in a .hdf package, where one file 
contains different bands each with information. To our purpose,
the band number 1 contains the NDVI."

setwd('~/Documents/GitHub/droughts_and_conflict/data/original/NDVI raster')
files <- dir(pattern = ".hdf")
files

filename <- substr(files,1,6)
filename <- paste0("ndvi", filename, ".tif")
filename

i <- 1
for (i in 1:177){
  sds <- get_subdatasets(files[i])
  gdal_translate(sds[1], dst_dataset = filename[i])
}

## Crop raster images with the district of Marsabit (Kenya) layer
setwd('~/Documents/GitHub/droughts_and_conflict/')
marsabit <- st_read(dsn= 'data/original/marsabit shp/marsabit.shp')
plot(marsabit)

setwd('~/Documents/GitHub/droughts_and_conflict/data/processed/kenya raster ')
files <- dir(pattern = ".tif")
files

filename <- substr(files,5,10)
filename <- paste0("crop", filename, ".tif")
filename

for (i in 1:177){
  ndvi <- raster(files[i])
  ndvi_pr <- raster::projectRaster(ndvi,crs ='EPSG:4326')
  crop <-  crop(ndvi_pr,marsabit,filename = filename[i]) %>% mask(marsabit)
}

## Stack rasters
setwd('~/Documents/GitHub/droughts_and_conflict/data/processed/marsabit crop raster')
files <- dir(pattern = ".tif")
files
predictor <- stack(files) ## Combining multiple raster
names(predictor)
plot(predictor)

writeRaster(predictor, '~/Documents/GitHub/droughts_and_conflict/data/processed/ndvi_kenya_merge.tif',
            overwrite=TRUE) #saving raster


## Marsabit administrative boundaries level 2 to 5
districts <- shapefile('~/Documents/GitHub/droughts_and_conflict/data/original/kenya/district.shp')
st_crs(districts)
proj4string(districts) <- CRS('EPSG:4326')
plot(districts)

divisions <- shapefile('~/Documents/GitHub/droughts_and_conflict/data/original/kenya/division.shp')
st_crs(divisions)
proj4string(divisions) <- CRS('EPSG:4326')
plot(divisions)

locations <- shapefile('~/Documents/GitHub/droughts_and_conflict/data/original/kenya/location.shp')
st_crs(locations)
proj4string(locations) <- CRS('EPSG:4326')
plot(locations)

sublocations <- shapefile('~/Documents/GitHub/droughts_and_conflict/data/original/kenya/sublocations 1999.shp')
st_crs(sublocations)
plot(sublocations)


divisions <- st_as_sf(divisions)
locations <- st_as_sf(locations)
sublocations <- st_as_sf(sublocations)

# find centroids of the different sublocations
centroid_loc  <- st_centroid(locations)
centroid_sloc  <- st_centroid(sublocations)
intersection <- st_intersection(divisions,st_centroid(sublocations)) %>% 
  st_set_geometry(NULL) 

st_geometry(divisions)
class(divisions)

## Extract values of the pixels raster per marsabit Divisions
divisions <- shapefile("~/Documents/GitHub/droughts_and_conflict/data/processed/division_marsabit.shp")
divisions
plot(divisions)

ext_divisions <- extract(predictor, divisions, method='simple', df=TRUE)
summary(ext_divisions)
write.csv(ext_divisions,"~/Documents/GitHub/droughts_and_conflict/data/processed/ndvi_divisions.csv", row.names = FALSE, na="")

## Extract values of the pixels raster per Marsabit Locations
locations <- st_read(dsn= "~/Documents/GitHub/droughts_and_conflict/data/original/kenya/Locations.shp")
locations
st_crs(locations)
plot(locations)

ext_locations <- extract(predictor, locations, method='simple', df=TRUE)
summary(ext_locations)
write.csv(ext_locations,"~/Documents/GitHub/droughts_and_conflict/data/processed/ndvi_locations.csv", row.names = FALSE, na="")


## Extract values of the pixels raster per Marsabit SUBLocations
sublocations <- st_read(dsn= "~/Documents/GitHub/droughts_and_conflict/data/original/kenya/Sublocations 1999.shp")

ext_subloc <- extract(predictor,sublocations, method='simple',df=TRUE)

write.csv(ext_subloc,"~/Documents/GitHub/droughts_and_conflict/data/processed/ndvi_sublocations.csv", 
          row.names = FALSE, na="")

data <- cbind.data.frame(sublocations$DIVISION,sublocations$LOCATION,sublocations$SUBLOCATIO)

write.csv(data,"~/Documents/GitHub/droughts_and_conflict/data/processed/sublocations.csv", 
          row.names = TRUE, na=".")

plot(sublocations)

