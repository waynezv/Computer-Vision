% CV Fall 2014 - Provided Code
% Test SIFT 
%
% Created by Wen-Sheng Chu (Oct-20-2014)

% Add necessary paths
addpaths;
poohpath = 'data/pooh/';

% Read image
imname = fullfile(poohpath,'training','image-0001.jpg');
I = imread(imname);

% Load annotation
ann = load(fullfile(poohpath,'ann')); 

% Compute SIFT
xcord  = ann(1,2:2:end); % x-coordinate
ycord  = ann(1,3:2:end); % y-coordinate
scale  = [7 4 4 10 10];
orient = zeros(1,5);
fc     = [xcord; ycord; scale; orient];

tic; 
d = siftwrapper(I, fc);
fprintf('Computed SIFT in %.2f secs\n', toc);

% Plot SIFT
siftplot(I, fc, d);
title(imname);