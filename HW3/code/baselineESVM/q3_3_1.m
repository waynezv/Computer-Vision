% This script takes the output bounding boxes from E-SVM detector, filters
% images with filter banks, and clusters their box-responses using k-means.
% Then K selected E-SVM detectors are used to detect on test set. AP is
% returned.
%
% - E-SVM detector @esvm_detect
% - filter banks @createFilterBank
% - box-responses @extractFilterResponses
%
% Author: WENBO ZHAO (wzhao1@andrew.cmu.edu)
% Date: Oct 23, 2015
% Log: (v0.1)-(first draft, written all the functions)-(Oct 23, 2015)
%      (v0.2)-(modified: fixed bug: improved: )
%
close all, clear all
%% set path
addpath(genpath('../utils'));
addpath(genpath('../lib/esvm'));
load('../../data/bus_esvm.mat');
load('../../data/bus_data.mat');
imgDir = '../../data/voc2007';
%% get bounding boxes from all images 
params = esvm_get_default_params();
% boundingBoxes = batchDetectImageESVM(modelImageNames, models, params);

%% get bounded images
imageBox = cell(1,length(modelBoxes));
for i = 1:length(modelBoxes)
    fprintf('get bounded image for %s\n', modelImageNames{i});
    image = imread(fullfile(imgDir, modelImageNames{i}));
    boxes = modelBoxes{i};
    imageBox{i} = image(boxes(2):boxes(4), boxes(1):boxes(3), :);
    imshow(imageBox{i})
end
%% get box-filtered-responses
% filter banks
fprintf('Getting filter bank ... \n');
% filterBank = createFilterBank();
% fprintf('Done.\n');
% filter responses
fprintf('Generating filter responses ... \n');
% ======= alpha:sample ====== need tweak ======
alpha = 500; % image size roughly ...
% =============================================
% for i = 1:length(imageBox)
%     filterResp = extractFilterResponses(imageBox{i}, filterBank);
%     randPixels = randperm(size(filterResp,1), alpha); % randomly select alpha pixels
%     filterResp = filterResp(randPixels, :);
%     boxResponse(i,:) = filterResp(:);
% end
% boxResponse = reshape(boxResponse, [length(imageBox)*alpha, 3*size(filterBank,1)]);
% fprintf('saving filtered box responses ... \n');
% % save('boxResponse', 'boxResponse');
% fprintf('Done.\n');

load boxResponse.mat
%% Cluster and find K examplars
% k-means cluster
fprintf('kmeans clustering ... \n');
% ===== K ===== need tweak ======
K = 65; 
% ===============================
[label,centerBox, inClusP2Cdist, P2Cdist] = kmeans(boxResponse, K, 'EmptyAction', 'drop');
% find examplars close to K clusters and average them by
% stating the number of pixels belonging to each cluster in each sampled image
clusMap = zeros(length(imageBox), K);
for i = 1:K
    for j = 1:length(imageBox)
        temp = label( (j-1)*alpha+1 : j*alpha );
        clusMap(j, i) = length(find(temp == i));
    end
end
imgInClus = cell(K,1); % store image index in each cluster
for i = 1:K
    ind = clusMap(:,i); % label accumulation of each pixel for each cluster: belongingness to cluster
    ind_s = sort(clusMap(:,i),'descend'); 
    s = [];
    % ===== top 3 ===== need tweak =====
    for t=1:3
    % ==================================
        tt = find(ind==ind_s(t));
        s = [s; tt];
    end
    imgInClus{i} = s;
end
%% E-SVM detect with k-detectors and compute AP
% + set variables
%  - detect
numTestImg = length(gtImages); % # of test images
%  - AP
IOU_ratio = 0.5;
draw = true
% + Detect and compute AP
%  - detect
params = esvm_get_default_params();
detectBoxes = cell(1, numTestImg);
% find K nearest images
knImgInd = zeros(1,K);
knImg = cell(1,K);
newModel = cell(1,K); % and select K models
for i = 1:K
    knImgInd(i) = imgInClus{i}(1);
    knImg{i} = imread(fullfile(imgDir, modelImageNames{knImgInd(i)}));
    newModel{i} = models{knImgInd(i)};
end
for j = 1:numTestImg
    fprintf('get bounding box for %s\n', gtImages{j});
    image = imread(fullfile(imgDir, gtImages{j}));
    detectBoxes{j} = esvm_detect(image,newModel,params);
end
%  - evaluate AP
[~,~,ap] = evalAP(gtBoxes, detectBoxes,IOU_ratio,draw)  

fprintf('Save bounding boxes...\n');
% save('detectBoxes', 'detectBoxes');
fprintf('Done.\n');

%% Visualize
% ---- AP vs. k ----
k = [1 5 15 30 50 60 70];
ap = [0.0909 0.0196 0.1990 0.0654 0.3522 0.4182  0.3540];
figure
plot(k, ap, 'bo');
hold on, plot(k, ap, 'k-');
title('AP vs. K')
xlabel('K'), ylabel('AP')

% ---- average images of k-bounding boxes ----
aveImBox = cell(1, K);
reSize = 100; % 100*100
for i = 1:K
    temp = zeros(reSize, reSize,3, 'double');
    imgInClusTemp = imgInClus{i};
    for j = 1:length(imgInClusTemp)
        imTemp = im2double(imageBox{imgInClusTemp(j)}); % im2double!!
        imTemp = imresize(imTemp, [reSize, reSize]);
        temp = temp+imTemp;
    end
    aveImBox{i} = temp./length(imgInClusTemp);
end
fprintf('saving average boxes ... \n');
% save('aveImBox', 'aveImBox');
fprintf('Done.\n');
imdisp(aveImBox);

% addpath ../export_fig
% export_fig('average_img_k=50', '-jpg')
