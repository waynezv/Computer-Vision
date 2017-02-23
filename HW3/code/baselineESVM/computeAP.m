addpath(genpath('../utils'));
addpath(genpath('../lib/esvm'));
load('../../data/bus_esvm.mat');
load('../../data/bus_data.mat');

% set variables
% - detect
imgDir = '../../data/voc2007';
numTestImg = length(gtImages); % # of test images
detectBoxes = cell(1,numTestImg);
% - AP
IOU_ratio = 0.5;
draw = true
% ap = [];

% detect
params = esvm_get_default_params();
for i = 1:numTestImg
    fprintf('get bounding box for %s\n', gtImages{i});
    image = imread(fullfile(imgDir, gtImages{i}));
    detectBoxes{i} = esvm_detect(image,models,params);
end
fprintf('Save bounding boxes...\n');
% save('detectBoxes', 'detectBoxes');
fprintf('Done.\n');
% evaluate AP
[~,~,ap] = evalAP(gtBoxes, detectBoxes,IOU_ratio,draw);   


