% Created by zhaowb7 on 2015-10-23.

function [boundingBoxes] = batchDetectImageESVM(imageNames, models, params)
%% Set par pool
% if nargin < 4
%     %default to 2 cores
%     numCores = 2;
% end
% % Close the pools, if any
% try
%     fprintf('Closing any pools...\n');
% %     matlabpool close
%     delete(gcp('nocreate'))
% catch ME
%     disp(ME.message);
% end
% fprintf('Will process %d files in parallel to compute visual words ...\n',length(imageNames));
% fprintf('Starting a pool of workers with %d cores\n', numCores);
% myPool = parpool(numCores);

%% Get bounding boxes
fprintf('Start taking in images and models, return their bounding boxes.\n ');
numImg = length(imageNames);
boundingBoxes = cell(1,numImg);
imgDir = '../../data/voc2007'; % image directory
for i = 1:numImg
    fprintf('get bounding box for %s\n', imageNames{i});
    image = imread(fullfile(imgDir, imageNames{i}));
    boundingBoxes{i} = esvm_detect(image,models,params);
end
% save boundingBoxes
fprintf('Save bounding boxes...\n');
% save('boundingBoxes', 'boundingBoxes');
fprintf('Done.\n');

%close the pool
% fprintf('Closing the pool.\n');
% delete(myPool)

end
