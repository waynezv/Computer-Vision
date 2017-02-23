function [detectionBoxes] = imgdetect(im, model, thresh)
% Wrapper around gdetect.m that computes detections in an image.
%   [ds, bs, trees] = imgdetect(im, model, thresh)
%
% return values
% detectionBoxes: N x 6 array of detection boxes.
%                [xmin ymin xmax ymax mixtureModelNum detectionScore] == each box
% Arguments
%   im        Input image
%   model     Model to use for detection
%   thresh    Detection threshold (scores must be > thresh)
%             If thresh is not supplied, we use the one in the model structure

if(~exist('thresh','var'))
    thresh = model.thresh;
end    
im = color(im);
pyra = featpyramid(im, model);
[ds, bs, trees] = gdetect(pyra, model, thresh);
detectionBoxes = clip_to_image(ds,[1 1 size(im,2) size(im,1)]);
detectionBoxes(:,5) = [];       %%changed by Hanbyul Joo