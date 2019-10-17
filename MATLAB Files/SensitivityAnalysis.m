%% Sensitivity analysis %%
% This script is created to cluster data using DBSCAN
% parameter sensitivity analysis
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

%% Loading data
Xdata = csvread('PlotNr_1_x.csv',2,1);
%Xdata = Xdata(1:100000);
Ydata = csvread('PlotNr_1_y.csv',2,1);
%Ydata= Ydata(1:100000);
Zdata = csvread('PlotNr_1_z.csv',2,1);
%Zdata= Zdata(1:100000);
DataMatrix= [Xdata,Ydata,Zdata];



%% Changing Epsilon
% Initial variables
%  As a rule of thumb, minPts = 2?dim can be used
MinPts = 5
epsilon=0.25

EpsRuns= 100;
StartEps= 0.25;
EndEps= 20;
EpsSteps= (EndEps-StartEps)/EpsRuns;

% initiate storing variables;
StoreIDX1=[];
StoreCorePts1=[];
for i= 1:1:EpsRuns
    % set parameters
    
    minpts= MinPts;
    
    % run DBSCAN
    [IDX1, COREPTS1]= DBSCAN3DOcTree(DataMatrix, epsilon, minpts);
    
    % store results
    StoreIDX1 = [StoreIDX1, IDX1];
    StoreCorePts1= [StoreCorePts1, COREPTS1];
    epsilon= epsilon+EpsSteps
end


%% Changing MinPts
MinPtsRuns= 100;
MinPtsSteps= 1;
StartPts= 1;
EndPts=50;
PtsSteps= (EndPts-StartPts)/MinPtsRuns;
%% 
Eps = 2.2;
minpts= StartPts;
% initiate storing variables
StoreIDX2=[];
StoreCorePts2=[];

for i= 1:MinPtsSteps:MinPtsRuns
    minpts = minpts+PtsSteps;
    epsilon = Eps;
    
    [IDX2, COREPTS2]= DBSCAN3DOcTree(DataMatrix, epsilon, minpts);
    
    StoreIDX2 = [StoreIDX2, IDX2];
    StoreCorePts2= [StoreCorePts2, COREPTS2];
    
end



%% Multiple feature sets parameter sweep
%Initialize boundary conditions
% 1 2 2.2 2.5 2.7 3 4 5 
% 4 5 6 7 8
List_initial_conditions = [1,4;1,5;1,6;1,7;1,8; ...
    2,4;2,5;2, 6;2,7;2,8; ...
    2.2,4; 2.2,5; 2.2,6; 2.2,7; 2.2,8;
    2.5,4; 2.5,5; 2.5,6; 2.5,7; 2.5,8;
    2.7,4; 2.7,5; 2.7,6; 2.7,7; 2.5,8;
    3,4;3,5;3,6;3,7;3,8; ...
    4,4;4,5;4,6;4,7;4,8; ...
    5,4;5,5;5,6;5,7;5,8]; 
Length_param_sweep=size(List_initial_conditions,1);

% System Variables
epsilon=zeros(Length_param_sweep);
minpts=zeros(Length_param_sweep);
StoreIDX3=[];
StoreCorePTS3=[];
for ps_i=1:Length_param_sweep    % Setting initial condition    
    epsilon    =   List_initial_conditions(ps_i,1);    
    minpts    =   List_initial_conditions(ps_i,2);    
    
    [IDX3, COREPTS3]= DBSCAN3DOcTree(DataMatrix, epsilon, minpts);
    StoreIDX3 = [StoreIDX3, IDX3];
    StoreCorePTS3= [StoreCorePTS3, COREPTS3];
end

%% visualisation

%% Eps and MinPts runs
% plot with how much noise is identified, 1 for each method
EpsNoise= sum(StoreCorePts1)./1000;
MinPtsNoise=sum(StoreCorePts2)./1000;
SweepNoise= sum(StoreCorePTS3)./1000;

EpsXaxis= StartEps:EpsSteps:EndEps-EpsSteps;
MinPtsXaxis= StartPts:PtsSteps:EndPts;
%
figure(1)
plot(EpsXaxis(1:100),EpsNoise(1:100))
hold on
title('Epsilon noise sensitivity')
xlabel('Epsilon')
ylabel('% noise out of total')
set(gca,'FontSize',18)
hold off
%
figure(2)
plot(MinPtsXaxis(1:100),MinPtsNoise(1:100))
hold on
title(' MinPts noise sensitivity')
xlabel('MinPts')
ylabel('% noise out of total')
set(gca,'FontSize',18)
hold off

%% Parameter Sweep Noise
SweepAxis=({'1,4','1,5','1,6','1,7','1,8', ...
    '2,4','2,5','2, 6','2,7','2,8', ...
    '2.2,4', '2.2,5', '2.2,6', '2.2,7', '2.2,8',...
    '2.5,4', '2.5,5', '2.5,6', '2.5,7', '2.5,8', ...
    '2.7,4', '2.7,5', '2.7,6', '2.7,7', '2.5,8', ...
    '3,4','3,5','3,6','3,7','3,8', ...
    '4,4','4,5','4,6','4,7','4,8', ...
    '5,4','5,5','5,6','5,7','5,8'}); 

figure(3)
plot(SweepNoise(1:20), '.', 'MarkerSize', 18)
set(gca, 'XTick', 1:length(SweepNoise(1:20)), 'XTickLabel', SweepAxis)
set(gca,'FontSize',16)
title('Noise sensitivity')
xlabel('Epsilon, MinPts')
ylabel('% noise out of total')


figure(4)
plot(SweepNoise(21:40), '.', 'MarkerSize', 18)
set(gca, 'XTick', 1:length(SweepNoise(21:40)), 'XTickLabel', SweepAxis(21:40))
set(gca,'FontSize',18)
title('Noise sensitivity')
xlabel('Epsilon, MinPts')
ylabel('% noise out of total')



%% plot with the amount of clusters, 1 for each method
StoreEpsClusters=[];
StoreMinPtsClusters=[];
StoreSweepClusters=[];
for i = 1:1:100
    EpsClusters= max(unique(StoreIDX1(:,i)));
    MinPtsClusters=max(unique(StoreIDX2(:,i)));
    
    StoreEpsClusters=[StoreEpsClusters, EpsClusters];
    StoreMinPtsClusters=[StoreMinPtsClusters, MinPtsClusters];
    
    if i<41
    SweepClusters=max(unique(StoreIDX3(:,i)));
    StoreSweepClusters=[StoreSweepClusters, SweepClusters];
    end
end

figure(5)
plot(EpsXaxis(1:100),StoreEpsClusters(1:100))
hold on
title('Amount of unique clusters')
xlabel('Epsilon')
ylabel('number of clusters')
set(gca,'FontSize',18)
hold off

figure(6)
plot(MinPtsXaxis(1:100),StoreMinPtsClusters(1:100))
hold on
title('Amount of unique clusters')
xlabel('MinPts')
ylabel('number of clusters')
set(gca,'FontSize',18)
hold off

figure(7)

plot(StoreSweepClusters(1:20), '.','MarkerSize', 18)
set(gca, 'XTick', 1:length(StoreSweepClusters), 'XTickLabel', SweepAxis)
hold on
title('Amount of unique clusters')
xlabel('Epsilon, MinPts')
ylabel('number of clusters')
set(gca,'FontSize',18)
hold off

figure(8)
plot(StoreSweepClusters(21:40), '.','MarkerSize', 18)
set(gca, 'XTick', 1:length(StoreSweepClusters(21:40)), 'XTickLabel', SweepAxis(21:40))
hold on
title('Amount of unique clusters')
xlabel('Epsilon, MinPts')
ylabel('number of clusters')
set(gca,'FontSize',18)
hold off




%% Visualisation of examples 
% visualise 2.2 ,5 
% Sweep 13 = 2.2,6
% 3 = 1.6
% 8 = 2.6
% IDX 
IDXSweep13= StoreIDX3(:,3);
figure;
hold on 
for i=1:max(IDXSweep13(1:75000))
    ids = find(IDXSweep13(1:75000)==i);
    scatter3(Xdata(ids), Ydata(ids), Zdata(ids),10,'filled') 
    xlim([1.9580*10^5, 1.9600*10^5])
end
hold off

figure(5);
scatter3(Xdata(1:100000),Ydata(1:100000),Zdata(1:75000),11)
xlim([1.9580*10^5, 1.9600*10^5])
% visualise 1.5 , 6
% Eps 7
IDXEps7 = StoreIDX1(:,7);

% visualise 3, 6 
% sweep 28
IDXSweep28= StoreIDX3(:,28)
figure;
hold on 
for i=1:max(IDXSweep28(1:25000))
    ids = find(IDXPts50==i);
    scatter3(Xdata(ids), Ydata(ids), Zdata(ids), 'filled')    
end
hold off
% visualise, 2.2, 4
% sweep 11
IDXSweep11= StoreIDX3(:,11);
figure;
hold on 
for i=1:max(IDXPts50)
    ids = find(IDXPts50==i);
    scatter3(Xdata(ids), Ydata(ids), Zdata(ids), 'filled')    
end
hold off
% visualise 2.2, 8
% sweep 15 
IDXSweep15=StoreIDX3(:,15)
figure;
hold on 
for i=1:max(IDXPts50)
    ids = find(IDXPts50==i);
    scatter3(Xdata(ids), Ydata(ids), Zdata(ids), 'filled')    
end
hold off

% visualise 2.2, 25
% minpts 50
IDXPts50= StoreIDX2(:,50);

figure;
hold on 
for i=1:max(IDXPts50(1:25000))
    ids = find(IDXPts50(1:25000)==i);
    scatter3(Xdata(ids), Ydata(ids), Zdata(ids),7,'filled')    
end
hold off


