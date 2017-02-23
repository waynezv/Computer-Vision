% test: distanceToSet
% addpath ../wordmaps/kitchen/
% addpath ../wordmaps/dam/
% load sun_acxkpeoqbwcxfvip.mat
% sun1  =  wordMap;
% load sun_aczchqarcsdhjfsg.mat
% sun2 = wordMap;
% load sun_aduijakaszcpfpqv.mat
% sun3 = wordMap;
% load sun_afmrwmnclcjhjeus.mat
% test1 = wordMap;
% load sun_dvfzcskjvmzptsfm.mat
% test2 = wordMap;
% 
% layerNum = 3;
% dictionarySize = 100;
% htest1 = getImageFeaturesSPM(layerNum, test1, dictionarySize);
% htest2 = getImageFeaturesSPM(layerNum, test2, dictionarySize);
% 
% figure, subplot(131), hist(htest1);
%         subplot(132), hist(htest2);
% htrain = [getImageFeaturesSPM(layerNum, sun1, dictionarySize) getImageFeaturesSPM(layerNum, sun2, dictionarySize) getImageFeaturesSPM(layerNum, sun3, dictionarySize)];
%         subplot(133), hist(htrain);
% histInter1 = distanceToSet(htest1, htrain)
% histInter2 = distanceToSet(htest2, htrain)

% test: createHistograms
% load('traintest.mat');
% imageDir = '../images'; %where all images are located
% targetDir = '../wordmap';%where we will store visual word outputs 
% 
% %%now compute histograms for all training images using visual word files
% trainingHistogramsFile = fullfile(targetDir,'trainingHistograms.mat');
% dictionarySize = 100;
% fprintf('Computing histograms ... ');
% trainHistograms = createHistograms(dictionarySize,smallTestImagePaths,targetDir);
% fprintf('done\n');
% save(trainingHistogramsFile,'trainHistograms');

% test: guessImage
tic
guessImage('../images/bamboo_forest/sun_aaegrbxogokacwmz.jpg')
toc
disp('YES! passed!');

