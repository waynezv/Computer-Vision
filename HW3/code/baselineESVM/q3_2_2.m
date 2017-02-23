% Created by zhaowb7 on 2015-10-23.

% Q3.2.2
close all, clear all
%% Set path
addpath(genpath('../utils'));
addpath(genpath('../lib/esvm'));
load('../../data/bus_esvm.mat');
load('../../data/bus_data.mat');

%% get bounding boxes from all images 
% params = esvm_get_default_params();
% boundingBoxes = batchDetectImageESVM(modelImageNames, models, params);

%% set variables
% - detect
imgDir = '../../data/voc2007';
numTestImg = length(gtImages); % # of test images
% - AP
IOU_ratio = 0.5;
draw = true

%% Detect and compute AP
% - detect
params = esvm_get_default_params();
lpo = [3 5 10];
detectBoxes = cell(length(lpo),numTestImg);
ap = zeros(1,length(lpo));
for i = 1:length(lpo)
    params.detect_levels_per_octave = lpo(i)
    for j = 1:numTestImg
        fprintf('get bounding box for %s\n', gtImages{j});
        image = imread(fullfile(imgDir, gtImages{j}));
        detectBoxes{i,j} = esvm_detect(image,models,params);
    end
% - evaluate AP
[~,~,ap(i)] = evalAP(gtBoxes, detectBoxes(i,:),IOU_ratio,draw);   
end
fprintf('Save bounding boxes...\n');
% save('detectBoxes', 'detectBoxes');
fprintf('Done.\n');

%% Plot
% ap = [0.3598    0.3167    0.3276]
figure
plot(lpo, ap, 'bo');
hold on, plot(lpo, ap, 'k-');
title('AP vs. LPO')
xlabel('LPO'), ylabel('AP')

% addpath ../export_fig
% export_fig('AP_LPO', '-jpg')
