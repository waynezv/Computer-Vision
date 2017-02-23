
%Loading the dictionary, filters and training data
numCores=4;
imageDir = '../images'; %where all images are located
targetDir = '../wordmap';%where we will store visual word outputs 
load('traintest.mat');
load('trainOutput.mat');

% We choose differnt odd k for testing
K = [1,3,5,11,15,21,25];
for i  = 1:7
k=K(i);
layerNum = 3;
conf_size = size(classnames,1);
conf = zeros(conf_size,conf_size);

%test all images
for i=1:length(testImagePaths)
% Get Hist of test image
    testImgFile = fullfile(imageDir,testImagePaths{i});
    testImg = imread(testImgFile);
    testWordMap = getVisualWords(testImg,filterBank,dictionary);
    testHistogram = getImageFeaturesSPM(layerNum, testWordMap, size(dictionary,1));
%Prediction  
   predLabel = knnClassify(testHistogram,trainHistograms,trainImageLabels,k);
    
%update confusion matrix
    conf(testImageLabels(i),predLabel) = conf(testImageLabels(i),predLabel) + 1;

end

%compute accuracy
acc = trace(conf) / sum(conf(:));
k
disp(conf);
disp(acc);
end