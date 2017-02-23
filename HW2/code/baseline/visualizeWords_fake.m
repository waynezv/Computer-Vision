% This script: 1. createFilterBank() and use it to extractFilterResponses() from 
% images, and then 2. use kmeans() to cluster the responses to visual words
% dictionary. Both 1 and 2 are achieved with getFilterBankAndDictionary().
% 3. map image to the closest word in the dictionary: getVisualWords()
% 3 is done with batchToVisualWords to speed up.
% 
% Author: WENBO ZHAO (wzhao1@andrew.cmu.edu)
% Date: Oct 3, 2015
% Log: (v0.1)-(first draft, written all the functions)-(Oct 3, 2015)
%      (v0.2)-(modified: fixed bug: improved: )
%
clear all, close all, clc
% Initialization
% - init directories
addpath ./
addpath ../images
imageDir = '../images/';
targetDir = '../wordmaps/';
% - load files
load traintest.mat
TestImagePath = smallTestImagePaths;
TestImageLabels = smallTestImageLabels;
TrainImagePath = smallTrainImagePaths;
TrainImageLabels = smallTrainImageLabels;
classnames = classnames;
% Select mode
mode = 'debug'
switch lower(mode)
    case 'debug'
% Get filter bank and dictionary
computeDictionary(TestImagePath,imageDir);

% Get visual words BATCHly
numCores = 2; % number of processors
load dictionary.mat
filterBank = filterBank;
dictionary = dictionary;
batchToVisualWords(TestImagePath,classnames,filterBank,dictionary,imageDir,targetDir,numCores);

    case 'train'
% Get filter bank and dictionary
[filterBank,dictionary] = getFilterBankAndDictionary(TrainImagePath);

% Get visual words BATCHly
numCores = 2; % number of processors
batchToVisualWords(TrainImagePath,classnames,filterBank,dictionary,imageDir,targetDir,numCores);
        
otherwise
    disp('Unknown method.')

end

