# Script to bulk clip LiDAR data to vegetation plots
# Casper Borgman 2019

# load libraries
library("lidR")
library("rgdal")

# Set working dirctory
workingdirectory="C:/Users/caspe/Documents/Thesis/LidRprocessing/"
setwd(workingdirectory)

# set global variables
cores=8
chunksize=2000
buffer=2.5
resolution=2.5
rasterOptions(maxmemory = 14000000000)

#Import shapefile for intersecting lidar
areaofintfile<-"DutchVegDB_ForestClip.shp"

areaofint=readOGR(dsn=areaofintfile)
GetPlotID=areaofint@data$PlOID
GetLength=areaofint@data$Ln____
GetWidth= areaofint@data$Br____
GetPlotSize= 1
# we need to filter the plot, the circle with which we clip needs to encompass the plot as tightly as possible
for(i in seq(from=1, to =length(areaofint))){
  
  if(areaofint@data$Ln____[i] == areaofint@data$Br____[i]){
    
  GetPlotSize[i]= GetLength[i] }
  else{
    GetPlotSize[i]= GetWidth[i]
  }
  
  
  }


areaofint@data$PlotSize= GetPlotSize

#import the catalog to clip with and set options for the catalog
#ctg <- catalog("C:/Users/caspe/Documents/Thesis/LidRprocessing/Lasfiles")
ctg <- catalog("D:/LidarTiles")
opt_chunk_buffer(ctg) <- buffer
opt_chunk_size(ctg) <- chunksize
opt_cores(ctg) <- cores

# create a subset of las data with lasclip and the areaofinterest

# set saving directory (equal to workingdirectory)
workingdirectory="D:/LidarTiles/Plots"
setwd(workingdirectory)

for(i in seq(from=1, to=length(areaofint))){
  LasSubset = lasclipCircle(ctg, areaofint@coords[i],areaofint@coords[i,2],radius=areaofint$PlotSize[i])
  PlotNr= areaofint@data$PlOID[i]
  
  if (LasSubset@header@PHB[["Number of point records"]]>0) {
    writeLAS(LasSubset,paste("PlotNr_",PlotNr,".las",sep=""))
    print(i)
  }
}


