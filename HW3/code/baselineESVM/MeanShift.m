% Created by zhaowb7 on 2015-10-20.

function [CCenters,CMemberships] = MeanShift(data,bandwidth,stopThresh)
if nargin < 2
    error('Please define bandwidth!\n');
end
if nargin < 3
    stopThresh = 1e-3*bandwidth; % default
end
% initialize useful variables
numPoint = size(data,1);
dimFeat = size(data,2)-1;
CCenters = [];
CMemberships = zeros(numPoint, 1);

% initialize cluster setups
numClus = 0; % initial number of clusters ?? 1 ??
% voteClus = zeros(numClus, numPoint, 'uint16');
voteClus = [];
pointLooked = zeros(numPoint,1); % store points that have been looked
numInitPoint = numPoint;

while numInitPoint
%     initPoint = datasample(1:numInitPoint, 1)); % initialize random point
    initPoint = datasample(find(pointLooked==0),1);
    center = data(initPoint, :); % initial center
    member = []; % points fall into the same cluster
    vote = zeros(numPoint, 1); % store votes for members
% start cluster
while 1
    distCenter2Point = pdist2(center, data); % distance from center to all active data points
    inPoint = find(distCenter2Point<bandwidth); % find data points within bandwidth
    vote(inPoint) = vote(inPoint)+1; % add votes
    oldCenter  = center;
%     center = mean(data(inPoint,:), 1);
    center = sum(bsxfun(@times, data(inPoint, 1:end), data(inPoint, end)), 1)./sum(data(inPoint, end), 1);
    member = [member inPoint];
    pointLooked(member,:) = 1;
    
    %% 
    plotFlag = 1;
    if plotFlag
        if dimFeat == 2
            figure(157),clf,hold on
            plot(data(:, 1),data(:, 2),'.')
            plot(data(member, 1),data(member, 2),'ys')
            plot(center(1),center(2),'go')
            plot(oldCenter(1),oldCenter(2),'rd')
            pause(0.1)
        end
    end
    %% 
    
    if norm((center-oldCenter),2) < stopThresh
        merge = 0; % clusters to merge
        for i = 1:numClus
            dist2NewC  = norm((center-CCenters(i,:)),2); 
            if dist2NewC < bandwidth/2
                merge = i;
                break
            end
        end
        
        if merge>0 % merge clusters if too close
            CCenters(merge,:) = mean((center+CCenters(merge,:)),1);
            voteClus(merge,:) = voteClus(merge,:)+vote';
        else
            numClus = numClus + 1; % found new cluster
            CCenters(numClus,:) = center;
            voteClus(numClus,:) = vote';
        end
        
        break         
    end  
end
numInitPoint = length(find(pointLooked==0));
end
[~, CMemberships] = max(voteClus, [], 1);
CMemberships = CMemberships';
numClus
fprintf('saving CCenters and CMemberships\n');
% save('q21_result', 'CCenters', 'CMemberships');
end
