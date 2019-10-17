"
@original author: Zsofia Koma, UvA
@alteration to load and filter forests
@by: Casper Borgman, UvA, 2019
Aim: Creating shapefile with Dutch vegetation database plots
"

# call the required libraries
library("stringr")
library("sp")
library("rgdal")
library("raster")
library("dplyr")

# set global variables
setwd("C:/Users/caspe/Documents/Thesis/Vegetationdata") # working directory

min_year=2002
max_year=2014
max_uncertainity=5

radius_m=5

# import data file name, header TRUE/FALSE, separator
VegDB_header<-read.csv(file="Forest_NL_header.csv",header=TRUE,sep="\t")
VegDB_species=read.csv(file="Forest_NL_species.csv",header=TRUE,sep="\t")


# introduce filter based on years 
VegDB_header$year=as.numeric(str_sub(VegDB_header$Datum.van.opname,-4,-1)) # define a numeric year attribute
VegDB_header_filtered=VegDB_header[ which(VegDB_header$year>min_year &VegDB_header$year<max_year & VegDB_header$Location.uncertainty..m.<max_uncertainity),]

#introduce filter based on location uncertainty in meters
VegDB_header_filtered$Location.uncertainty..m.= as.numeric(VegDB_header_filtered$Location.uncertainty..m.)
VegDB_header_filtered2 <- VegDB_header_filtered[which(VegDB_header_filtered$Location.uncertainty..m.<5 & VegDB_header_filtered$Location.uncertainty..m. >0),]

# filter out useful variables 
VegDB_header_filtered3 <- VegDB_header_filtered2 %>% select(-Opnamenummer, -PlotID, -Literatuur.referentie,-Bedekkingsschaal,-Project,-Auteur,-X.Coordinaat..m.,-Y.Coordinaat..m.,-Bloknummer,-Syntaxon.Schamin√.e,-Expositie...NWZOVX..,-Inclinatie..graden.,-Mossen.geidentificeerd,-Permanent.Quadraat,-Associa..1.,-Dataset,-Opmerking,-Transect)
  


# join with species or choose not to
#VegDB <- left_join(VegDB_header_filtered3, VegDB_species, by = 'PlotObservationID')
VegDB <- VegDB_header_filtered3

# Export the point data
coordinates(VegDB)=~Longitude+Latitude

proj4string(VegDB)<- CRS("+proj=longlat +datum=WGS84")
CRS.new <- CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +units=m +no_defs")
VegDB_RDNew <- spTransform(VegDB, CRS.new)

#EXPORT AS RASTER AND CSV to new workingdirectory for further processing
workingdirectory="C:/Users/caspe/Documents/Thesis/LidRprocessing"
setwd(workingdirectory)

raster::shapefile(VegDB_RDNew, "DutchVegDB_RDNew_points.shp",overwrite=TRUE)
write.csv(VegDB_RDNew, file = "VegDB_RDNew.csv")

