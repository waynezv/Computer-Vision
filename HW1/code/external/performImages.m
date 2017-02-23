% Make a panorama given two input images in RGB
function [ im_stitched ] = performImages( im1, im2 )

%transMode = 'aff_lsq'; n_pts = 3; % at least 3 needed
transMode = 'proj_svd'; n_pts = 5; % at least 4 needed

f=figure;
movegui(f, 'northwest');
subim1=subplot(2,2,1); imshow(im1);
subim2=subplot(2,2,2); imshow(im2);

[pts1 pts2] = SIFTmatch( im1, im2 );
if length(pts1) < n_pts
    disp('too few points matched.. stitching not possible.');
else

    [im2_T, best_pts] = ransac( pts2, pts1, transMode, n_pts );

    showbestpts(subim2, subim1, best_pts);

    [im_stitched, stitched_mask, im1, im2] = stitch(im1, im2, im2_T);

    figure(f);
    subplot(2,2,3); imshow(im1); 
    subplot(2,2,4); imshow(im2);

    f=figure;
    movegui(f, 'northeast');
    imshow(im_stitched)
end
    
end
