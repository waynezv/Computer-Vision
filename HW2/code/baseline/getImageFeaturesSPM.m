function [h] = getImageFeaturesSPM(layerNum, wordMap, dictionarySize)
% This function forms a multi-resolution representation of the given image
% - INPUTS: * layreNum: # of layers, L+1, [0 1 2 ... L]
%           * wordMap: an index map of the size(Image) that maps each pixel 
%             response to its closest in the dictionary
%           * dictionarySize: # of visual words in the dictionary, K
%             clusters
% - OUTPUT: * h: a ( (K(4^(L+1)-1)/3 * 1) histogram
%
% Author: WENBO ZHAO (wzhao1@andrew.cmu.edu)
% Date: Oct 4, 2015
% Log: (v0.1)-(first draft, written all the functions)-(Oct 4, 2015)
%      (v0.2)-(modified: fixed bug: improved: )
%

wordMap = wordMap(:);
%% number of cells for each layer
numCell = ones(layerNum,1);
for i = 1:layerNum
    numCell(i) = (2^(i-1))^2; 
end 
%% index into each cell of the wordMap in each layer 
index = [];
% for i = 1:layerNum
%     index(:,i)= [0:length(wordMap)./numCell(i):length(wordMap)]; % e.g. 
%     % [0 19200 38400 57600 76800] for length(wordMap)=76800 and numCell=4
% end
index = [0:length(wordMap)./numCell(layerNum):length(wordMap)];
%% start from histing the finest layer (L+1)
h_2 = []; 
for j = 1:numCell(layerNum)
    ind = [floor(index(j)+1) : 1 : floor(index(j+1))]; % index for the jth cell
%     h_2 = [h_2; hist(wordMap(ind), dictionarySize).']; % h of size(numCell(layerNum) * dictionarySize)
    h_2 = [h_2; (getImageFeatures(wordMap(ind), dictionarySize)).'];
end
%% A temporal solution for coarser layers
h_2 = reshape(h_2, [numCell(layerNum), dictionarySize]);
h_1 = [sum(h_2(1:4,:), 1); sum(h_2(5:8,:), 1); sum(h_2(9:12,:), 1); sum(h_2(13:16,:), 1)];
h_1 = bsxfun(@rdivide, h_1, sum(h_1,2)); %
h_0 = [sum(h_2(:,:), 1)];
h_0 = h_0./sum(h_0); %
%% 
%% weight
weight = 1/2.*ones(layerNum,1);
weight(1) = 2^(-(layerNum-1));
weight(2) = 2^(-(layerNum-1));
for i = 3:layerNum
    weight(i) = 2^((i-1)-(layerNum-1)-1);
end
%% sum the weighted hist and normalize
h = [weight(1).*h_0; weight(2).*h_1; weight(3).*h_2];
h = h(:);
h = sqrt(h); %
h = h./norm(h,1);

end