% This script extracts the visual word dictionary (bag of words) using
% feature descriptors, instead of using filter banks.
%
% Author: WENBO ZHAO (wzhao1@andrew.cmu.edu)
% Date: Oct 8, 2015
% Log: (v0.1)-(first draft, written all the functions)-(Oct 8, 2015)
%      (v0.2)-(modified: fixed bug: improved: )
%
clear all, close all, clc
%% Set directories
load('traintest.mat');
imageDir = '../images'; %where all images are located

setDir  = fullfile(imageDir,trainImagePaths);
imgSets = imageSet(setDir);

%% Get bag of words using Matlab CV toolbox builtin function
% SURF features are used to generate the vocabulary features. Vocabulary is quantized 
% using K-means algorithm. 
VocabularySize = 500; % dictionary size
PointSelection = 'Grid'; % using SURF feature
tic
bag = bagOfFeatures(imgSets,'VocabularySize', VocabularySize, 'PointSelection', PointSelection, 'Verbose',true);
toc
%% Map image to dictionary
% can actually use builtin encode, but...
tic;
featureVector = encode(bag,imgSet);
toc;

surfResult.bag = bag;
surfResult.feat = featureVector;
save('surfResult','surfResult');
%% knn classification
% predict
k = 21; % odd number to avoid tie
distance = 'similarity'
% distance = 'euclid'
% distance = 'cosine'
% distance = 'kldivergence'
% distance = 'builtinKnn'
C = zeros(length(unique(trainImageLabels)));
tic
for i = 1:length(testImagePaths)
    image = imread(fullfile(imageDir, testImagePaths{i}));
    h = encode(bag, image);
    predictedLabel = knnClassify(h.', featureVector.', trainImageLabels, k, distance); 
    fprintf('The %d th image, Label: true: %d, predict: %d \n', i, testImageLabels(i), predictedLabel);
    C(predictedLabel,testImageLabels(i)) = C(predictedLabel,testImageLabels(i)) + 1;
end
toc
% accuracy
fprintf('Confusion matrix:');
C
accuracy = trace(C)/sum(C(:))

