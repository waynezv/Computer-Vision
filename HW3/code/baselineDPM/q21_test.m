clear all, close all
load('q21_data.mat');

bandwidth = 55  % This is an example. You may need to adjust this value
threshold = bandwidth*0.01; % This is an example. You may need to adjust this value
[clusterCenters,clusterMemberships] = MeanShift(data,bandwidth,threshold);

%% Draw
clusterNum  = size(clusterCenters,1);
figure; hold on; axis equal
set(gcf,'color','w');
cc=hsv(clusterNum);
for cIdx = 1:clusterNum
    tempMembership = find(clusterMemberships == cIdx);
    plot(data(tempMembership,1),data(tempMembership,2),'.','color',cc(cIdx,:));

    tempCenter = clusterCenters(cIdx,:);
    plot(clusterCenters(cIdx,1),clusterCenters(cIdx,2),'k+','MarkerSize',10,'lineWidth',2)      
end
