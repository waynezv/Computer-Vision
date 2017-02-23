function [predictedLabel] = knnClassify(wordHist,trainHistograms,trainingLabels,K, choiceDistance)
%This function 
% - INPUTS: * wordHist: a (K(4^(L+1)-1)/3 * 1) histogram
%           * trainHistograms: a (K(4^(L+1)-1)/3 * T) histogram from T
%           training samples
%           * trainingLabels: a T*1 labels for training set
%           * K: (K) nearest neighbors
% - OUTPUT: * predictedLabel: predicted label for new wordHist
%
% Author: WENBO ZHAO (wzhao1@andrew.cmu.edu)
% Date: Oct 5, 2015
% Log: (v0.1)-(first draft, written all the functions)-(Oct 5, 2015)
%      (v0.2)-(modified: fixed bug: improved: )
%
%% find the K nearest neighbors of wordHist in trainHistograms
% if ~exist(choiceDistance)
%     choiceDistance = 'similarity';
% end
disp(choiceDistance);
% choiceDistance = 'similarity' % might want use PARSE??
[~, neighbor] = topKNeighbor(wordHist,trainHistograms, trainingLabels, K, choiceDistance);
%% predict the label for wordHist
predictedLabel = mode(neighbor);
% predictedLabel = predictLabel(neighbor, max(trainingLabels));

end

function [distance, neighbor] = topKNeighbor(testSet, trainSet, trainLabel, K, choiceDistance)
% This function returns the top K distance of testSet to trainSet and their
% labels.
%
%% choice of distance
% default choice
% if ~exist(choiceDistance)
%     choiceDistance = 'similarity';
% end

switch lower(choiceDistance)
    case 'similarity'
        % - similarity
        dist = distanceToSet(testSet, trainSet); % similarity in this case
        [dist_sort, pos]= sort(dist, 'descend'); % sort the distance in descending order and mark the position
        distance = dist_sort(1:K); % find the top K distances...
        neighbor = trainLabel(pos(1:K)); % and their corresponding labels in trainSet
    case 'euclid'
        % - Euclid distance
        dist = pdist2(testSet.', trainSet.', 'euclid');
        [dist_sort, pos]= sort(dist, 'ascend');
        distance = dist_sort(1:K);
        neighbor = trainLabel(pos(1:K));
    case 'cosine'
        % - Cosine distance
        dist = pdist2(testSet.', trainSet.', 'cosine');
        [dist_sort, pos]= sort(dist, 'ascend');
        distance = dist_sort(1:K);
        neighbor = trainLabel(pos(1:K));
    case 'kldivergence'
        % - K-L divergence
        KL = @(X, Y)(sum(bsxfun(@times, X, bsxfun(@minus, log2(X),log2(Y)))));
        dist = pdist2(testSet,trainSet, @(testSet,trainSet) KL(testSet,trainSet));
        [dist_sort, pos]= sort(dist, 'ascend');
        distance = dist_sort(1:K);
        neighbor = trainLabel(pos(1:K));
    case 'builtinknn'
        [idx, dist] = knnsearch(trainSet.',testSet.', 'dist','euclid','k',K);
        distance = dist;
        neighbor = trainLabel(idx);
    otherwise
        disp('Undefined distance!\n');
end
end