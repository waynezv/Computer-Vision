clear all, close all
%% setting path and load model
addpath ../export_fig/

addpath(genpath('../utils'));
addpath(genpath('../lib/dpm'));
load('../../data/bus_dpm.mat');

%% Object detection via DPMs
I = imread('q42_test.jpg');
detectionBoxes = imgdetect(I,model);
figure; showboxes(I,  detectionBoxes);      %% show detected bounding boxes.

%% Non-Maximum suppression
bestBBox = nms(detectionBoxes,200,5); % K varies, but still got 1 detection
figure; hold on; image(I); axis ij; hold on;
showboxes(I,  bestBBox);

%% Find buses!
busStation = '../../data/voc2007/';
busNum = dir(fullfile(busStation,'*.jpg'));
ind = datasample(1:length(busNum), 15);
for i = ind
    bus = imread(fullfile(busStation, busNum(i).name))
    detectionBoxes = imgdetect(bus,model);
    bestBBox = nms(detectionBoxes,200,5);
    figure; hold on; image(bus); axis ij; hold on;
    showboxes(bus,  bestBBox);
end
