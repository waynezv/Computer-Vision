% Make a panorama, using images from a folder
% Sort image in a subsequent manner
function [ im_stitched ] = performFolder( folder )

images = dir(fullfile(folder,'*.jpg'));
if size(images, 1) < 2
    disp('Need at least two images :)');
    return
end

im1 = imread(fullfile(folder, images(1).name));

processList=2:size(images, 1);
waitList=[];

%transMode = 'aff_lsq'; n_pts = 3; % at least 3 needed
transMode = 'proj_svd'; n_pts = 5; % at least 4 needed

isFirstStitch=true;
currentListIdx=0;
isMatchedAtLeastOne=false;


while currentListIdx < numel(processList)
    
    currentListIdx = currentListIdx + 1;
 
    disp(sprintf('Stitching part %u of %u', currentListIdx, numel(processList)));
    
    im2 = imread(fullfile(folder, images(processList(currentListIdx)).name));

    [pts1 pts2] = SIFTmatch( im1, im2 );
    if length(pts1) < n_pts * 3
        disp('too few points matched.. skipping file, queued.');
        waitList(end+1)=processList(currentListIdx);
    else
        isMatchedAtLeastOne=true;
        
        [im2_T, best_pts] = ransac( pts2, pts1, transMode, n_pts );

        if isFirstStitch
            [im_stitched, stitched_mask, im1, im2] = stitch(im1, im2, im2_T);
            isFirstStitch=false;
        else
            [im_stitched, stitched_mask, im1, im2] = stitch(im1, im2, im2_T, stitched_mask);
        end

        im1=im_stitched;

        imshow(im1);
    end
    
    if currentListIdx == numel(processList) && isMatchedAtLeastOne;
        isMatchedAtLeastOne=false;
        currentListIdx=0;
        processList=waitList;
        waitList=[];
    else
        if currentListIdx == numel(processList)
            disp(sprintf('%i images dont belong to this panorama:',numel(processList)));
            for i=1:numel(processList), disp(images(processList(i)).name); end
            break
        end
    end
    
end


end
