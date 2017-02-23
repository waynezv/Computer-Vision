% Created by zhaowb7 on 2015-10-20.

function [refinedBBoxes] = nms(bboxes, bandwidth,K)
% set useful variables
numBox = size(bboxes,1);
dimFeat = size(bboxes, 2)-1;
stopThres = bandwidth*0.01; 
% feat = bboxes(:,1:dimFeat); % 4-D boxes as features

% positive scores
bboxes(:,end) = bboxes(:,end)+1; % ?? normalize
% bboxes(:,end) = abs(bboxes(:,end));
% refine boxes via Non-Maximum Suppression using mean-shift cluster
[refinedBBoxes, boxTags] = MeanShift(bboxes, bandwidth, stopThres);
refinedBBoxes = refinedBBoxes(:,1:dimFeat);
end
