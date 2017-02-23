%Loading the dictionary, filters and training data
numCores=2;
imageDir = '../images'; %where all images are located
targetDir = '../wordmap';%where we will store visual word outputs 
load('traintest.mat');
load('trainOutput.mat');

% Close the pools, if any
% try
%     fprintf('Closing any pools...\n');
%     matlabpool close; 
% catch ME
%     disp(ME.message);
% end
% fprintf('Will process %d files in parallel to compute visual words ...\n',length(trainImagePaths));
% fprintf('Starting a pool of workers with %d cores\n', numCores);
% matlabpool('local',numCores);

% predict
k = 5; % odd number to avoid tie
layerNum = 3;
distance = 'similarity'
% distance = 'euclid'
% distance = 'cosine'
% distance = 'kldivergence'
% distance = 'builtinKnn'
C = zeros(length(unique(trainImageLabels)));
tic
for i = 1:length(testImagePaths)
    image = imread(fullfile(imageDir, testImagePaths{i}));
    wordMap = getVisualWords(image, filterBank, dictionary);
    h = getImageFeaturesSPM( layerNum, wordMap, size(dictionary,1));
    predictedLabel = knnClassify(h, trainHistograms, trainImageLabels, k, distance); 
    fprintf('The %d th image, Label: true: %d, predict: %d \n', i, testImageLabels(i), predictedLabel);
    C(predictedLabel,testImageLabels(i)) = C(predictedLabel,testImageLabels(i)) + 1;
end
toc
% accuracy
fprintf('Confusion matrix:');
C
accuracy = trace(C)/sum(C(:))

