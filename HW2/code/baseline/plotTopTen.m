% This script: looks at the histograms of any 2 images from each class and plot the top 10 pixel
% patches for visual words in the dictionary.
% 
% Author: WENBO ZHAO (wzhao1@andrew.cmu.edu)
% Date: Oct 6, 2015
% Log: (v0.1)-(first draft, written all the functions)-(Oct 6, 2015)
%      (v0.2)-(modified: fixed bug: improved: )
%
% set directories and load useful files
imageDir = '../images'; %where all images are located
wordMapDir = '../wordmap';
load('traintest.mat');
load('dictionary.mat','dictionary', 'filterBank');
load('pixelPatch2.mat');
% set useful variables
numImageEachClass = 2; % number of images for each class
topNum = 10; % top number of visual words of hist
numPixelInPatch = 3;% numPixelInPatch^2 pixels in a patch

% stat the topNum index
topHit = zeros(topNum, numImageEachClass, length(allImagePaths));% store the topNum index to visual words for each numImageEachClass
for i = 415:416
%     for j = randperm(length(allImagePaths,numImageEachClass)
%     for j = 1:numImageEachClass
        topTenWords = topTenVisualWords(averagePatches, imageDir, wordMapDir, allImagePaths{i})
%         image = imread(fullfile(imageDir, allImagePaths{j}));
%         I_map = getVisualWords(image, filterBank, dictionary);
%         I_hist = hist(I_map(:), size(dictionary,1)); % 1*dictionarySize
%         [~,pos] = sort(I_hist);
%         topHit(:,j,i) = pos(1:topNum).';
%     end
end

% fprintf('Saving topHit...\n')
% save('topHit', 'topHit');
% fprintf('Done.\n');

% map index to pixel patch of visual word
count = 1;
for i = 1:size(pixelPatch,3)
    if sum(sum(pixelPatch(:,:,i)))>0
        pixelPatchCell{count} = pixelPatch(:,:,i);
        count = count+1;
    end
end

% topHit = topHit()
% topHitPixelPatch = zeros(numPixelInPatch, numPixelInPatch, 
% for i = 1:size(topHit,3)
%     for j = 1:size(topHit,2)
%         topHitPixelPatch() = pixelPatch(:,:,topHit())
%     
%     
