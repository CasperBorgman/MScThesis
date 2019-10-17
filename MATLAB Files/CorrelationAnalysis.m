%% Casper Borgman 2019 %%
% part of MSc thesis
% https://github.com/CasperBorgman/
%% Warnings
% % MATLAB R2019A or higher is reccommended

% This script requires DBSCAN and OcTree functions available on GitHub
% requirements: saved files of XYZ LiDAR data
% File containing all the plot names
%% Initialisation
clc
clear
close all

%% Initialise X Data variables
FileFolder= 'D:\LidarTiles\NormalizedPlots\XData';
filePattern = fullfile(FileFolder, '*.csv'); % Change to whatever pattern you need.
theFiles = dir(filePattern);

iterations= length(theFiles);
XData= csvread(fullfile(theFiles(1).folder,theFiles(1).name),2,1);
XDataStore=[XData];
%% Storing X Data
for i = 2:iterations

     XData= csvread(fullfile(theFiles(i).folder,theFiles(i).name),2,1);
     size1= size(XDataStore);
     size2= size(XData);
     if size1(1)>size2(1)
         sizeX=size1(1);
     else
         sizeX=size2(1);
     end
     XData(sizeX)= 0;
     XDataStore(sizeX,i)=0;
     XDataStore=[XDataStore, XData];
end

%% Initialise Y Data variables
FileFolder= 'D:\LidarTiles\NormalizedPlots\YData';
filePattern = fullfile(FileFolder, '*.csv'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
YData = csvread(fullfile(theFiles(1).folder,theFiles(1).name),2,1);
YDataStore = [YData];
%% Storing Y Data
for i = 2:iterations

     YData= csvread(fullfile(theFiles(i).folder,theFiles(i).name),2,1);
     size1= size(YDataStore);
     size2= size(YData);
     if size1(1)>size2(1)
         sizeY=size1(1);
     else
         sizeY=size2(1);
     end
     YData(sizeY)= 0;
     YDataStore(sizeY,i)=0;
     YDataStore=[YDataStore, YData];
end


%% Initialise Z Data variables
FileFolder= 'D:\LidarTiles\NormalizedPlots\ZData';
filePattern = fullfile(FileFolder, '*.csv'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
ZData = csvread(fullfile(theFiles(1).folder,theFiles(1).name),2,1);
ZDataStore= [ZData];

%% Storing Z Data
for i = 2:iterations

     ZData= csvread(fullfile(theFiles(i).folder,theFiles(i).name),2,1);
     size1= size(ZDataStore);
     size2= size(ZData);
     if size1(1)>size2(1)
         sizeZ=size1(1);
     else
         sizeZ=size2(1);
     end
     ZData(sizeZ)= 0;
     ZDataStore(sizeZ,i)=0;
     ZDataStore=[ZDataStore, ZData];
end


%% running DBSCAN on all plots
Epsilon= 3;
MinPts= 6;
StoreIDX1=[];
StoreCorePts1=[];
for i=1:102
    XYZdata= [XDataStore(:,i), YDataStore(:,i), ZDataStore(:,i)];
     [IDX1, COREPTS1]= DBSCAN3DOcTree(XYZdata, Epsilon, MinPts);
    
    % store results
     size1= size(StoreIDX1);
     size2= size(IDX1);
     if size1(1)>size2(1)
         sizeX=size1(1);
     else
         sizeX=size2(1);
     end
     IDX(sizeX)= 0;
     StoreIDX(sizeX,i)=0;
     StoreIDX1 = [StoreIDX1, IDX1];
    
    
    size1= size(StoreCorePts1);
     size2= size(COREPTS1);
     if size1(1)>size2(1)
         sizeX=size1(1);
     else
         sizeX=size2(1);
     end
     COREPTS1(sizeX)= 0;
     StoreCorePts1(sizeX,i)=0;
    StoreCorePts1= [StoreCorePts1, COREPTS1];
   
end
%% Calculation of statistics
% amount of clusters

%
ClustersAbove=0;
ClustersBelow=0;
StoreTotClusters=[];
StorePPCluster=[];
StoreAbove=[]
StoreBelow=[]
for i= 1:102
    %% point data of the plot
    XDataStore(:,2) = 1;
    YDataStore(:,2) = 1;
    ZDataStore(:,2) = 1;
    XYZdata= [(XDataStore(:,i)), (YDataStore(:,i)), (ZDataStore(:,i))];
    
        
    
    %% total clusters per plot
    TotClusters= length(unique(StoreIDX1(:,i)));
    StoreTotClusters= [StoreTotClusters, TotClusters];
       
    % Remove noise (where corepts ==1)
    Filteredpoints = XYZdata(StoreCorePts1(:,i) == 1); 
    Filter2= ZDataStore(ZDataStore(:,1)==0);
    Remainingpoints= length(XYZdata) - length(Filteredpoints)- length(Filter2);
    % average points per cluster 
    AveragePPCluster= Remainingpoints/(TotClusters-1);
    StorePPCluster= [StorePPCluster, AveragePPCluster];


%%  clusters above / below 50 max height
    % step 1 50% max height
    HalfMaxheight= 0.5 * max(ZDataStore(:,i));
    % loop over a cluster to see whether it is below or above 50% max height
    % Fetch all the unique ids
    UniqueIDs= unique(StoreIDX1(:,i));
    % check for each unique id ( cluster) whether a point inside is below
    % or above the height
    for j = 1:length(UniqueIDs);
        ID = UniqueIDs(j);
        ZData= ZDataStore(:,i);
        Z =  ZData(StoreIDX1(:,i)==ID);
        
        testZ = Z > HalfMaxheight;
        if testZ >= 1;
            ClustersAbove = ClustersAbove+1;
        end
        if testZ < 1;
            ClustersBelow= ClustersBelow+1;
        end
        

    end
    StoreAbove= [StoreAbove, ClustersAbove];
    StoreBelow= [StoreBelow, ClustersBelow];
    ClustersAbove=0;
    ClustersBelow=0;
    end

% average size of clusters
% x is <- -> 
% y is ^v
% z is min max
% first step: middle point = length/2
% second step: out of all the points in the cluster, which is the largest
% euclidian distance away       sqrt(sum((A - B) .^ 2))
StoreDist=[]
StoreAvDist=[]
for i = 1:102
    % Get the points in the cluster
    XYZdata= [XDataStore(:,i), YDataStore(:,i), ZDataStore(:,i)];
    UniqueIDs= unique(StoreIDX(:,i));
    for j = 1:length(UniqueIDs)
        ID = UniqueIDs(j);
        X = (XDataStore(:,i));
        Y= (YDataStore(:,i));
        Z= (ZDataStore(:,i));
        XCluster= [X(StoreIDX1(:,i)== ID)];
        YCluster= [Y(StoreIDX1(:,i)== ID)];
        ZCluster= [Z(StoreIDX1(:,i)== ID)];
        XYZCluster= [XCluster, YCluster, ZCluster];
        ClusterLength= length(XYZCluster);
        CentroidX = sum(XYZCluster(:,1))/ClusterLength;
        CentroidY = sum(XYZCluster(:,2))/ClusterLength;
        CentroidZ = sum(XYZCluster(:,3))/ClusterLength;
        Centroid = [CentroidX, CentroidY, CentroidZ];
        Distance=pdist2(Centroid,XYZCluster,'squaredeuclidean');
        MaxDist= max(Distance);
        % store in this loop for this cluster
        StoreDist= [StoreDist, MaxDist];
    end
     Averagedist= sum(StoreDist)/length(StoreDist);
    StoreAvDist= [StoreAvDist, Averagedist];
    % Reset StoreDist
    StoreDist=[];
   
    
end


%% Loading the vegetation data
% plots to remove (14)(58)(72)(82)
% skip XYZdata(:,2)
PlotID= csvread('PlotID.csv',2);
PlotID([14,58,72,82])= 0;
PlotID= nonzeros(PlotID);

Bedekkingboom = csvread('Bedekkingboom.csv', 2);
Bedekkingboom(Bedekkingboom==0)=0.001;
Bedekkingboom([14,58,72,82])= 0;
Bedekkingboom= nonzeros(Bedekkingboom);

Bedekkingkruid=csvread('BedekkingKruid.csv',2);
Bedekkingkruid(Bedekkingkruid==0)= 0.001;
Bedekkingkruid([14,58,72,82])= 0;
Bedekkingkruid= nonzeros(Bedekkingkruid);

Bedekkingmos=csvread('Bedekkingmos.csv',2);
Bedekkingmos(Bedekkingmos==0)=0.001;
Bedekkingmos([14,58,72,82])= 0
Bedekkingmos= nonzeros(Bedekkingmos);

Bedekkingstruik=csvread('Bedekkingstruik.csv',2);
Bedekkingstruik(Bedekkingstruik==0)=0.001
Bedekkingstruik([14,58,72,82])= 0;
Bedekkingstruik= nonzeros(Bedekkingstruik);

BedekkingTot=csvread('BedekkingTot.csv',2);
BedekkingTot(BedekkingTot==0)=0.001
BedekkingTot([14,58,72,82])= 0;
BedekkingTot= nonzeros(BedekkingTot);

GemHogeKruidlaag=csvread('GemHogeKruidlaag.csv',2);
GemHogeKruidlaag(GemHogeKruidlaag==0)=0.001
GemHogeKruidlaag([14,58,72,82])= 0;
GemHogeKruidlaag= nonzeros(GemHogeKruidlaag);

GemLageKruidlaag=csvread('GemLageKruidlaag.csv',2);
GemLageKruidlaag(GemLageKruidlaag==0)=0.001
GemLageKruidlaag([14,58,72,82])= 0;
GemLageKruidlaag= nonzeros(GemLageKruidlaag);

Hogeboomlaag=csvread('Hogeboomlaag.csv',2);
Hogeboomlaag(Hogeboomlaag==0)=0.01
Hogeboomlaag([14,58,72,82])= 0;
Hogeboomlaag= nonzeros(Hogeboomlaag);

Hogestruiklaag=csvread('Hogestruiklaag.csv',2);
Hogestruiklaag(Hogestruiklaag==0)=0.001
Hogestruiklaag([14,58,72,82])= 0;
Hogestruiklaag= nonzeros(Hogestruiklaag);

Lageboomlaag=csvread('Lageboomlaag.csv',2);
Lageboomlaag(Lageboomlaag==0)=0.001
Lageboomlaag([14,58,72,82])= 0;
Lageboomlaag= nonzeros(Lageboomlaag);

MaxZ=csvread('MaxZ.csv',2);
MaxZ(MaxZ==0)=0.001
MaxZ([14,58,72,82])= 0;
MaxZ= nonzeros(MaxZ);

Incompleteness=csvread('Incompleteness.csv',2);
Incompleteness(Incompleteness==0)=0.001
Incompleteness([14,58,72,82])= 0;
Incompleteness= nonzeros(Incompleteness);

Weirdness=csvread('Weirdness.csv',2);
Weirdness(Weirdness==0)=0.001
Weirdness([14,58,72,82])= 0;
Weirdness= nonzeros(Weirdness);

AllVegData= [Bedekkingboom, Bedekkingkruid,Bedekkingmos, ...
    Bedekkingstruik, BedekkingTot, GemHogeKruidlaag, Weirdness];




%% CORRELATIONS
[Rho3, PVAL3]= corr(StoreAvDist([1,3:102])', AllVegData);

[Rho4, PVAL4]=corr(StoreAbove([1,3:102])', AllVegData);


[Rho5, PVAL5]= corr(StoreBelow([1,3:102])', AllVegData);

[Rho2, PVAL2]= corr(StorePPCluster([1,3:102])', AllVegData);

[Rho, PVAL]= corr(StoreTotClusters([1,3:102])', AllVegData);

RhoMat= [Rho;Rho2;Rho3;Rho4;Rho5]

PVALMat= [PVAL; PVAL2; PVAL3; PVAL4;PVAL5]









