% clc,clear all;
load('traintest.mat');
imageDir = '..\images';
computeDictionary(trainImagePaths,imageDir);
targetDir = '..\images';
[filterBank] = createFilterBank();
load('dictionary.mat');
% %  numCores = 4;
%  % batchToVisualWords(trainImagePaths,classnames,filterBank,dictionary,imageDir,targetDir,numCores);
dictionarySize = 150;
imagePaths = trainImagePaths;
wordMapDir = '..\images';
outputHistograms = createHistograms(dictionarySize,imagePaths,wordMapDir);
 trainHistograms = outputHistograms;
 save('trainOutput.mat','filterBank','dictionary','trainHistograms','trainImageLabels','classnames');

 
% wordHist = [0.5,0.2,0.3]';
% wordHist_long = repmat(wordHist,1,4);
% histograms = [0.5,0.2,0.3;0.2,0.4,0.4;0.3,0.1,0.6;0.3,0.1,0.6]';
% trainingLabels = [1,2,3,3];
% histInter = sum(wordHist_long.*log(wordHist_long./histograms),1);
% % 
% % %sort and keep indexes
%  [~, indexes] = sort(histInter,'ascend');
% % 
% % %top k labels
%  topLabels = trainingLabels(indexes(1:1));
% % 
% % %return most common label
%  predictedLabel = mode(topLabels);