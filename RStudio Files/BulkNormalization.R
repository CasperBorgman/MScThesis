# Bulk Normalization and ground removal script
# Casper Borgman 2019 

library("lidR", lib.loc="~/R/win-library/3.5")
library("raster")
library("rgdal")
setwd("C:/Users/caspe/Documents/Thesis/LidRprocessing")
ctg = catalog("C:/Users/caspe/Documents/Thesis/LidRprocessing")
files= 106
#plot ids
areaofintfile<-"DutchVegDB_ForestClip.shp"
areaofint=readOGR(dsn=areaofintfile)
IDs= areaofint$PlOID



for (i in seq(from=1, to=106, by=1)) {
  if(i==15) next
  if(i==73) next
  if(i==83) next
  if(i==59) next
workingdirectory="D:/LidarTiles/Plots"
setwd(workingdirectory)  
  print(i)
  #
  PlotNr= areaofint@data$PlOID[i]

las <- readLAS(paste('PlotNr_',PlotNr,'.las', sep=""))
las_gr <-lasground(las,pmf(2.5,0.2))


las_gr_norm<-lasnormalize(las_gr, knnidw(k=20, p=2))

las_gr_norm_veg <- lasfilter(las_gr_norm, Classification==1)

# convert to  xlsand write las
workingdirectory="D:/LidarTiles/NormalizedPlots/"
setwd(workingdirectory)
writeLAS(las_gr_norm_veg,paste("PlotNr_",PlotNr,"_normalized.las"))

workingdirectory="D:/LidarTiles/NormalizedPlots/XData"
setwd(workingdirectory)
write.csv(las_gr_norm_veg$X, paste("PlotNr_",PlotNr,"x_norm_veg.csv"))

workingdirectory="D:/LidarTiles/NormalizedPlots/YData"
setwd(workingdirectory)
write.csv(las_gr_norm_veg$Y, paste("PlotNr_",PlotNr,"y_norm_veg.csv"))

workingdirectory="D:/LidarTiles/NormalizedPlots/ZData"
setwd(workingdirectory)
write.csv(las_gr_norm_veg$Z, paste("PlotNr_",PlotNr,"z_norm_veg.csv"))

}

workingdirectory="D:/LidarTiles/ComputationPlots/"
setwd(workingdirectory)
las <- readLAS('PlotNr_246834_1000.las')
write.csv(las$X, paste("PlotNr_246834_1000.csv"))





