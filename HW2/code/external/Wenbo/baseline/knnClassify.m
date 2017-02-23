function [predictedLabel] = knnClassify(wordHist,trainHistograms,trainingLabels,k)

%get distance
histInter = distanceToSet(wordHist, trainHistograms);

%sort and keep indexes
[~, indexes] = sort(histInter,'descend');
% If we use some other dist, we may need smallest one
% [~, indexes] = sort(histInter,'ascend');

topKIndex = trainingLabels(indexes(1:k));
predictedLabel = mode(topKIndex);

end
