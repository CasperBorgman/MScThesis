# Original
#@author: Zsofia Koma, UvA
#Aim: Extract area of interest from AHN2 data

# adapted by Casper Borgman 2019

#load libraries
library("lidR")
library("rgdal")

# Set working dirctory
workingdirectory="C:/Users/caspe/Documents/Thesis/LidRprocessing"
setwd(workingdirectory)

# set global variables
cores=8
chunksize=2000
buffer=2.5
resolution=2.5
rasterOptions(maxmemory = 14000000000)

radius = 10

#Import shapefile for intersecting lidar
areaofintfile<-"DutchVegDB_RDNew_Clip.shp"
areaofint=readOGR(dsn=areaofintfile)

las <- readLAS("test.las")
ctg <- catalog(workingdirectory)

# Set filenames and dwnload and unzip the required dataset
req_tile=list("33dz2")

for (tile in req_tile){
  #download.file(paste("http://geodata.nationaalgeoregister.nl/ahn2/extract/ahn2_","gefilterd/g",tile,".laz.zip",sep=""),
  #              paste("g",tile,".laz.zip",sep=""))
  download.file(paste("http://geodata.nationaalgeoregister.nl/ahn2/extract/ahn2_","uitgefilterd/u",tile,".laz.zip",sep=""),
                paste("u",tile,".laz.zip",sep=""))
  
  #unzip(paste("g",tile,".laz.zip",sep=""))
  unzip(paste("u",tile,".laz.zip",sep=""))
}

zipped <- dir(path=workingdirectory, pattern=".laz.zip")
file.remove(zipped)

# create a catalog from the downloaded files
ctg = catalog(workingdirectory)
opt_chunk_buffer(las) <- buffer
opt_chunk_size(las) <- chunksize
opt_cores(las) <- cores


for (i in seq(from=min(areaofint$PlOID),to=max(areaofint$PlOID))){ 
  print(i)
  
  subset = lasclip(ctg, areaofint,radius=10)
  
  if (subset@header@PHB[["Number of point records"]]>0) {
    writeLAS(subset,paste("GenID_",i,".laz",sep=""))
  }
  
}


