% This script takes the output bounding boxes from E-SVM detector, extract 
% features from VLFEAT toolbox, and cluster their box-feature-responses using k-means.
% Then K selected E-SVM detectors are used to detect on test set. AP is
% returned.
%
% - E-SVM detector @esvm_detect
% - feature banks @vlfeat toolbox (www.vlfeat.org/
%                                  https://github.com/vlfeat/)
% - box-responses @extractFilterResponses
%
% Author: WENBO ZHAO (wzhao1@andrew.cmu.edu)
% Date: Oct 25, 2015
% Log: (v0.1)-(first draft, written all the functions)-(Oct 25, 2015)
% (v0.2)-(modified: fixed bug: improved: )
%
close all, clear all
%% set path
addpath(genpath('../utils'));
addpath(genpath('../lib/esvm'));
% addpath(genpath('./external/vlfeat-0.9.20/'));
% compile vlfeat toolbox
% run ./external/vlfeat-0.9.20/toolbox/vl_setup.m

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
    imageBox{i} = single((rgb2gray(image(boxes(2):boxes(4), boxes(1):boxes(3), :))));
%     imshow(imageBox{i})
end
%% get box-feature-responses using different features
% method = 'HOG'
% method = 'SIFT'
method = 'dSIFT'
switch lower(method)
    case 'hog'
        fprintf('Extracting %s features ... \n', method);
        % =================================
        cellSize = 8 ;
        alpha = 12; % randomness
        % =================================
        hogFeat = [];
        for i = 1:length(imageBox)
            hogFeatTemp = vl_hog(imageBox{i}, cellSize, 'verbose') ;
            %  ---- plot ----
            plot = 1;
            if plot
            imhog = vl_hog('render', hogFeatTemp, 'verbose') ;
            imagesc(imhog) ; colormap gray ;
            end
            % ---------------
            hogFeatTemp = reshape(hogFeatTemp,[size(hogFeatTemp,1)*size(hogFeatTemp,2), 31]);
            randSel = randperm(size(hogFeatTemp,1), alpha);
            hogFeat = [hogFeat; hogFeatTemp(randSel, :)];
        end
        fprintf('saving box-feature-responses ... \n');
        save('hogFeat', 'hogFeat');
        fprintf('Done.\n');
        feat = hogFeat;
    case 'sift'
        % ==========================
        alpha = 2;
        % ==========================
        siftFeat = [];
         for i = 1:length(imageBox)
             [f,d] = vl_sift(imageBox{i}) ;
             % ----------- plot ---------
             plot = 0;
             if plot
             perm = randperm(size(f,2)) ;
             sel = perm(1:5) ;
             h1 = vl_plotframe(f(:,sel)) ;
             h2 = vl_plotframe(f(:,sel)) ;
             h3 = vl_plotsiftdescriptor(d(:,sel),f(:,sel)) ;
             end
             % --------------------------
             d = d';
            randSel = randperm(size(d,1), alpha);
            siftFeat = [siftFeat; d(randSel, :)];
        end
        feat = siftFeat;
        
    case 'dsift'
        % ============================
        binSize = 8 ;
        magnif = 3 ;
        alpha = 20;
        % ============================
        dsiftFeat = [];
        for i = 1:length(imageBox)
            Is = vl_imsmooth(imageBox{i}, sqrt((binSize/magnif)^2 - .25)) ;
            [f, d] = vl_dsift(Is, 'size', binSize) ;
            f(3,:) = binSize/magnif ;
            f(4,:) = 0 ;
            [f_, d_] = vl_sift(imageBox{i}, 'frames', f) ;
             % ----------- plot ---------
             plot = 0;
             if plot
             perm = randperm(size(f_,2)) ;
             sel = perm(1:5) ;
             h1 = vl_plotframe(f_(:,sel)) ;
             h2 = vl_plotframe(f_(:,sel)) ;
             h3 = vl_plotsiftdescriptor(d_(:,sel),f_(:,sel)) ;
             end
             % --------------------------
            d_ = d_';
            randSel = randperm(size(d_,1), alpha);
            dsiftFeat = [dsiftFeat; d_(randSel, :)];
        end
        feat = dsiftFeat;
    otherwise
        disp('no defined method!\n');
end

% load boxResponse.mat
%% Cluster and find K examplars
% k-means cluster
fprintf('kmeans clustering ... \n');
% ===== K ===== need tweak ======
K = 60; 
% ===============================
[label,centerBox, inClusP2Cdist, P2Cdist] = kmeans(feat, K, 'EmptyAction', 'drop');
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
% k = [1 35 60];
% ap = [0.0909 0.1519 0.1766];
% figure
% plot(k, ap, 'bo');
% hold on, plot(k, ap, 'k-');
% title('AP vs. K')
% xlable('K'), ylabel('AP')

% ---- average images of k-bounding boxes ----
aveImBox = cell(1, K);
reSize = 100; % 100*100
for i = 1:K
    temp = zeros(reSize, reSize, 'double');
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
% export_fig('hog_average_img_k=35', '-jpg')
