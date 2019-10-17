%% Casper Borgman 2019 %%
% part of MSc thesis
% https://github.com/CasperBorgman/
%% Script for LiDAR data clustering using DBSCAN

%% Warnings
% MATLAB R2019A or higher is reccommended

% This script requires DBSCAN and OcTree functions available on GitHub
%% Initialisation
clc
clear
close all

% specify whether additional data should be entered into the clustering as
% extra dimension in addition to the XYZ data (3 or 4 dimensions as preset, more possible)
dimension = 3

%% Loading data
% load data in format csv/plain text

%load the x axis points
%load('x.csv')
%load('x.txt')
Xdata = csvread('PlotNr_1_x.csv',2,1);
% enable and change in order to only take a selection of points
% numbers must be the same for X, Y and Z
% Xdata = Xdata(1:50000);

%load the y axis points
%load('x.csv')
%load('x.txt')
Ydata = csvread('PlotNr_1_y.csv',2,1);
%Ydata= Ydata(1:50000);

%load the z axis points
%load('x.csv')
%load('x.txt')
Zdata = csvread('PlotNr_1_z.csv',2,1);
%Zdata= Zdata(1:50000);

% if usingload extra dimension points
if dimension == 4
Vdata= csvread('PlotNr_1_zmean.csv',2,1);
%Vdata=Vdata(1:500000);
% optional: normalize data
% Vdata= ((Vdata-min(Vdata)) / (max(Vdata)-min(Vdata))).*100;
end

% create the data matrix
if dimension == 3
DataMatrix= [Xdata,Ydata,Zdata]; 
elseif dimension ==4
DataMatrix= [Xdata,Ydata,Zdata,Vdata]; 
end


%% DBSCAN
%% Setting the parameters
% dbscan(X, EPSILON, MINPTS) partitions the points in the N-by-P 
%    data matrix X into clusters based on parameters EPSILON 
%    (search radius) and MINPTS (min. amount of points).
% define EPSILON & MINPTS parameters 
EPSILON = 2.2
MINPTS = 6

%% Running DBSCAN
% with Octree optimization
if dimension == 3
[IDX1, COREPTS] = DBSCAN3DOcTree(DataMatrix, EPSILON, MINPTS);
elseif dimension == 4
[IDX1, COREPTS] = DBSCAN4DOcTree(DataMatrix, EPSILON, MINPTS);
end

%original DBSCAN (high RAM usage)
%[IDX2, COREPTS] = DBSCANO(pts, EPSILON, MINPTS);

%low ram usage using squared euclidian, slower speed 
%[IDX3, COREPTS] = DBSCANL(pts, EPSILON, MINPTS);

%% Visualise the point cloud 
% point cloud only
x= DataMatrix(:,1);
y= DataMatrix(:,2);
z= DataMatrix(:,3);
figure(1)
scatter3(x,y,z)

% point cloud with clusters colored
figure;
hold on 
for i=1:max(IDX1)
    ids = find(IDX1==i);
    scatter3(x(ids), y(ids), z(ids),'filled')    
end
hold off


% visualise the octree bins
OT = OcTree3D(DataMatrix,'binCapacity',20);
figure(5)
boxH = OT.plot; 
cols = lines(OT.BinCount); 
doplot3 = @(p,varargin)plot3(p(:,1),p(:,2),p(:,3),varargin{:}); 
for i = 1:OT.BinCount 
set(boxH(i),'Color',cols(i,:),'LineWidth', 1+OT.BinDepths(i)) 
doplot3(DataMatrix(OT.PointBins==i,:),'.','Color',cols(i,:)) 
end 
axis image, view(3)
set(gca,'FontSize',18)
zlabel('Height (m)')
ylabel('Coordinate (m)')



