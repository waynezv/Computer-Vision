% This script: finds the 9*9 pixel patch in which the center pixel
% corresponds to the index mapping to the visual word in dictionary.
% 
% Author: WENBO ZHAO (wzhao1@andrew.cmu.edu)
% Date: Oct 6, 2015
% Log: (v0.1)-(first draft, written all the functions)-(Oct 6, 2015)
%      (v0.2)-(modified: fixed bug: improved: )
%
% clear all, close all, clc
% 
% set directories
imageDir = '../wordmap';
% set useful variables
load traintest.mat
load('dictionary.mat','dictionary');
numWords = size(dictionary,1); % number of visual words
numPixelInPatch = 9; % numPixelInPatch^2 pixels in a patch
% find the pixel patch of visual words in the training image set
pixelPatch = zeros(numPixelInPatch, numPixelInPatch, numWords);
fprintf('Finding pixel patches for each visual word...\n');
for i = 1:numWords
    count = 0;
    for j = 1:length(trainImagePaths)
        image = load(fullfile(imageDir, [strrep(trainImagePaths{i}, '.jpg','.mat')])); % read each wordMap for training image set
        image = image.wordMap;
        [row, col] = find(image == i); % find the center pixel
        if ~isempty(row) && ~isempty(col)
            for m = 1:length(row)
                if (row(m)-4)>0 && (col(m)-4)>0 && (row(m)+4)<=size(image,1) && (col(m)+4)<=size(image,2)
                    pixelPatch(:,:,i) = pixelPatch(:,:,i)+[image((row(m)-4):(row(m)+4), (col(m)-4):(col(m)+4))];
                    count = count+1;
                end
            end
        end
        row = []; col = [];
    end
pixelPatch(:,:,i) = pixelPatch(:,:,i)./count;
end
% fprintf('Saving pixel patches...\n');
% save('pixelPatch', 'pixelPatch');
% fprintf('Done.\n');
% 
% 
% count = 1;
% for i = 1:size(pixelPatch,3)
%     if sum(sum(pixelPatch(:,:,i)))>0
%         pixelPatchCell{count} = pixelPatch(:,:,i);
%         count = count+1;
%     end
% end
% save('pixelPatchCell', 'pixelPatchCell')
% 
% imdisp(pixelPatchCell, colormap)



 