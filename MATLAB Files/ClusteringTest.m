%% Script to test DBSCAN and OcTree calculation times and robustness
%% Casper Borgman 2019 %%
% part of MSc thesis
% https://github.com/CasperBorgman/
%% Script for LiDAR data clustering using DBSCAN


%% Warnings
% % MATLAB R2019A or higher is reccommended

% This script requires DBSCAN and OcTree functions available on GitHub
%% Initialisation
clc
clear
close all
%% 
% Created to test runs of DBSCAN with an OcTree script, without an OcTree
% script and a high RAM more direct implementation of DBSCAN 
%% load test data, or use artificial data (creation of artificial data further on)
% Xdata10 = csvread('PlotNr_246834_10.csv',2,1);
% Xdata25 = csvread('PlotNr_246834_25.csv',2,1);
% Xdata50 = csvread('PlotNr_246834_50.csv',2,1);
% Xdata100 = csvread('PlotNr_246834_100.csv',2,1);
% Xdata250 = csvread('PlotNr_246834_250.csv',2,1);
% Xdata1000 = csvread('PlotNr_246834_1000.csv',2,1);

%% Parameters and initial variables
% DBSCAN Input parameters
EPSILON =0.7;
MINPTS= 1;
% Variable storage initialisation
TstoreOT= [];                   % Store the time to run OcTree
TstoreDB=[];                    % Store the time to run DBSCAN
TstoreL= [];                    % Store the time to run RAM intensive DBSCAN
X = [];                         % Store the amount of points that have been considered in the calculation
StoreClustersOT= [];                % Store the amount of clusters made
StoreClustersDB= [];                % Store the amount of clusters made
StoreClustersL = [];                % Store the amount of clusters made


%% Run DBSCAN with Octree
% numpts describes the total amount of points
% making sure the numpts starts at 1
numpts = 1;
% Variable used to determine the amount of points created in the artificial dataset for testing,
% used in later calculation 
ptsin = 600

% for loop that uses numpts and numpts to create an artificial dataset and uses it as input
% runs until ptsin is reached, can be changed manually
for numpts2 = 1:1:ptsin
    
    %% Creating the artificial dataset
    % high resolution
   % numpts = numpts + ceil(numpts2 / 10);
    
    %numpts= numpts +1
    % exponential scaling, lower resolution
    numpts= ceil(2^(numpts2/32));
    %numpts = floor(1.05^(numpts2+50));
    
    % print numpts to see progress
    numpts
    
    size = numpts ^ (1/3);
    pts = size * rand(numpts, 3);
  
    
    %% Running the three methods
    % OcTree
    tic
    [IDX1, COREPTS] = DBSCANOcTree(pts, EPSILON, MINPTS);
    TstoreOT= [TstoreOT, toc];
    
 
    %DBSCAN original, out of ram with 16 GB ram after 32k+ points
    if numpts < 32769
    tic
    [IDX2, COREPTS] = DBSCANOriginal(pts, EPSILON, MINPTS);
    TstoreDB= [TstoreDB, toc]; 
    end
        
    
    %  Low RAM, slower speed
     tic
     [IDX3, COREPTS] = DBSCANLowRAM(pts, EPSILON, MINPTS);
     TstoreL= [TstoreL, toc]; 

    %% Storing Variables
    X = [X, numpts];
    
    ClustersOT= max(IDX1);
    ClustersDB= max(IDX2);
    ClustersL = max(IDX3);
    
    StoreClustersOT= [StoreClustersOT, ClustersOT];                % Store the amount of clusters made
    StoreClustersDB= [StoreClustersDB, ClustersDB];
    StoreClustersL = [StoreClustersL, ClustersL];
end

 %% Visualisation of oscillation in OcTree calculation time
% % Input for curve fitting tool, in order to see expected vs real time
% X2= X(55:end)
% TstoreOT2=TstoreOT(55:end)
% Weight= 1./(X2.*log(X2)).^2
% 
% loglog(X(55:end), TstoreOT(55:end), 'b')
% 
% set(gca,'FontSize',14)
% hold on
% loglog(X(55:end),1.699e-5*X(55:end).*log(X(55:end)), 'r');
% ylabel('Time in seconds')
% xlabel('Number of points')
% legend('DBSCAN with OcTree', 'Expected calculation time')

%% visualisation of calculation speed with real data example
realX= [7969 39333 182882 773723 4640165]
plot(1.699e-5*realX.*log(realX))
title('Calculation speed with AHN 2 forest data')
xlabel('meter')
ylabel('Calculation time (s)')
set(gca,'FontSize',12)
xticklabels({'10','25', '50', '100', '250', '1000'})


loglog(realX,1.699e-5*realX.*log(realX), 'r');



%% Visualisation of calculation times with artificial dataset
% plot(X(1:460), TstoreOT([1:460]), 'b')
% hold on
% ylabel('Time in seconds')
% xlabel('Number of points')
% plot(X([1:460]), TstoreDB([1:460]), 'r')
% plot(X(1:460), TstoreL(1:460), 'g')
% set(gca,'FontSize',14)
% % plot(X, TstoreOT(end) / (X(end) * log(X(end))) * X .* log(X), 'b')
% % plot(X, TstoreDB(end) / X(end)^2 * X.^2, 'r')
% % plot(X, TstoreL(end) / X(end)^2 * X.^2,'y')
% 
% legend('OcTree','Original DBSCAN', 'Low RAM DBSCAN')
% hold off



%% Visualise the point cloud 
% 
% x= pts(:,1);
% y= pts(:,2);
% z= pts(:,3);
% figure(1)
% scatter3(x,y,z)
% 
% 
% figure;
% hold on 
% for i=1:max(IDX)
%     ids = find(IDX==i);
%     scatter3(x(ids), y(ids), z(ids))    
% end
% hold off

%% visualise OcTree
numpts=500;
size = numpts ^ (1/3);
pts = size * rand(numpts, 3);

OT = OcTree3D(pts,'binCapacity',20);
figure(5)
boxH = OT.plot; 
cols = lines(OT.BinCount); 
doplot3 = @(p,varargin)plot3(p(:,1),p(:,2),p(:,3),varargin{:}); 
for i = 1:OT.BinCount 
set(boxH(i),'Color',cols(i,:),'LineWidth', 1+OT.BinDepths(i)) 
doplot3(pts(OT.PointBins==i,:),'.','Color',cols(i,:)) 
end 
axis image, view(3)
set(gca,'FontSize',18)
xlabel('X Direction ()')
zlabel('Z Direction ()')
ylabel('Y Direction ()')

%% Test robustness
numptss = 500
size = numptss ^ (1/3);
ptss = size * rand(numptss, 3);

ot = OcTree3D(ptss, 'binCapacity',20);
D = pdist2(ptss,ptss,'squaredeuclidean');

for i =  1:numptss
    IDX1 = ot.RegionQuery(i, EPSILON);
    IDX2 = find(D(i,:)<EPSILON);
    IDFRACTION12 = sum(sum(sum(IDX1 == IDX2))) / sum(length(IDX1))
end



IDFRACTION12 = sum(sum(IDX1 == IDX2)) / length(IDX1)


result = 1;
for i =1:numptss
   label1 = IDX1(i);
   label2 = IDX2(i);
   
   if sum((IDX2(IDX1 ==label1) == label2)==0) > 0
       result = 0;
       break;
   end   
   if sum((IDX1(IDX2 ==label2) == label1)==0) > 0
       result = 0;
       break;
   end
end
result




for i=1:max(IDX)
    ids = find(IDX==i);
    scatter3(x(IDX1), y(IDX1), z(IDX2))    
end



