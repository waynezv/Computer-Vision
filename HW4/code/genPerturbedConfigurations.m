function perturbedConfigurations = genPerturbedConfigurations(singleFrameAnnotation, meanShape, n, scalesToPerturb)
% 
% singleFrameAnnotation 5-by-2 ground truth
% meanShape 5-by-2 
% n number of perturbation
% perturbedConfigurations 4-by-(n*5)

ann = reshape(singleFrameAnnotation(2:end), [2, 5]).';
% init meanShape at center and scale to fit annotation
scale_MS_Ann = findscale(ann, meanShape); % N-by-2 -> 1
meanShape    = meanShape./scale_MS_Ann; % scaling
diff_center  = mean(ann, 1) - mean(meanShape, 1);
meanShape    = meanShape + repmat(diff_center, [size(meanShape,1),1]); % move to center

% perturb
perturbed_MS = cell(n,1);
scaled_MS    = cell(n,1);
tranl_MS     = cell(n,1);
scale_perturbedMS_Ann = cell(n,1);
for i = 1:n
    %
    [scaled_MS{i}, scale_perturbedMS_Ann{i}] = scaleMeanShape(meanShape, scalesToPerturb);
    %!!!!!! scale 1st or tranl 1st !!!!
    %     perturbed_MS{i} = scaleMeanShape(tranl_MS{i}, scalesToPerturb); % scale first or translation?
%     scale_perturbedMS_Ann{i} = findscale(ann, scaled_MS{i});
    perturbed_MS{i} = translMeanShape(scaled_MS{i}); % scale first or translation?
    
end

% tune SIFT scale
TA_scale = [7 4 4 10 10]; % TA's scale
sift_scale = cell(n,1);
for i = 1:n
    % !!! product or divide !!!
    sift_scale{i} = TA_scale ./ (scale_MS_Ann * scale_perturbedMS_Ann{i}); % scale TA_scale
end
sift_scale_mat   = cell2mat(sift_scale.'); % 1-by-(n*5)
perturbed_MS_mat = (cell2mat(perturbed_MS)).'; % 2-by-(n*5)
perturbedConfigurations = [perturbed_MS_mat; sift_scale_mat; zeros(size(sift_scale_mat))];
end

function [scaled_MS, scale] = scaleMeanShape(meanShape, scalesToPerturb)
% perturb meanShape by random scaling
% -----------------------------------
% record center and scale with center in case of large scale
center = mean(meanShape, 1);

nScale = numel(scalesToPerturb);
scale  = scalesToPerturb(randperm(nScale, 1)); % randomly select one scale
meanShape = meanShape./scale;

center_after_scale = mean(meanShape, 1);
diff_center  = center_after_scale - center;
scaled_MS    = meanShape + repmat(diff_center, [size(meanShape,1),1]); %
end

function tranl_MS = translMeanShape(meanShape)
% perturb meanShape by random translation
% ---------------------------------------
% !!!! translation pixels !!!!
tranl    = 5.*rand(1, size(meanShape,2)); % + or -
tranl_MS = meanShape + repmat(tranl, [size(meanShape,1), 1]);
end