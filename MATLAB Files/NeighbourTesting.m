%% Neighbour testing for correct epsilon values %% 
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

%% loading data
Xdata = csvread('PlotNr_1_x.csv',2,1);
Ydata = csvread('PlotNr_1_y.csv',2,1);
Zdata = csvread('PlotNr_1_z.csv',2,1);

DataMatrix= [Xdata,Ydata,Zdata];

%% Testing Epsilon
Distance=pdist2(DataMatrix,DataMatrix,'squaredeuclidean');
test123=sort(Distance);
DistAsc=sort(Distance(:,4));
Dist2= sort(Distance(:,100));
Dist3=sort(Distance(:,1500));

DistDesc=flipud(DistAsc);
Dist4=flipud(Dist2);
Dist5=flipud(Dist3);
plot(DistDesc)
hold on
plot(Dist4)
plot(Dist5)


testrow=sort(test123(5,:));
testrow1=sort(test123(20,:));
testrow2=sort(test123(500,:));
plot(rot90(testrow),'b');
hold on
title('Neighbour distance graph')
set(gca,'FontSize',18)
ylabel('Euclidian Distance (m)')
xlabel('Neighbour number ()')
xlim([-50,5000])

plot(rot90(testrow1), 'y');
plot(rot90(testrow2), 'g');