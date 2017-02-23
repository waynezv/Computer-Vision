% Make a panorama, capturing one image at a time from cam
% Terminate after 'numFrames' captured
function [ im_stitched ] = perform1by1FromCam( cam1, numFrames )

close all
%transMode = 'aff_lsq'; n_pts = 3; % at least 3 needed
transMode = 'proj_svd'; n_pts = 5; % at least 4 needed

% init first image
[im1 im2] = acquireImages(cam1, 6);

i=1;
while i < numFrames
    
    input('press enter for next image');
    [im1 im2] = acquireImages(cam1, 2, im1);

    f=figure;
    movegui(f, 'northwest');
    subim1=subplot(2,2,1); imshow(im1);
    subim2=subplot(2,2,2); imshow(im2);

    [pts1 pts2] = SIFTmatch( im1, im2 );
    if length(pts1) < n_pts
        disp('too few points matched.. new capture.');
        continue
    else
        i=i+1;
    end
    [im2_T, best_pts] = ransac( pts2, pts1, transMode, n_pts );

    showbestpts(subim2, subim1, best_pts);

    if i==2
        [im_stitched, stitched_mask, im1, im2] = stitch(im1, im2, im2_T);
    else
        [im_stitched, stitched_mask, im1, im2] = stitch(im1, im2, im2_T, stitched_mask);
    end

    figure(f);
    subplot(2,2,3); imshow(im1); 
    subplot(2,2,4); imshow(im2);

    f=figure;
    movegui(f, 'northeast');
    imshow(im_stitched)

    im1=im_stitched;
end