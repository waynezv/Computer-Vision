%% Demo start

im1 = imread('demoimages/demo1.png');
im2 = imread('demoimages/demo2.png'); 

fshowA=figure;
subA1=subplot(2,2,1); imshow(im1);
subA2=subplot(2,2,2); imshow(im2);
movegui(fshowA, 'northwest');

fshowH=figure;
subH1=subplot(2,2,1); imshow(im1);
subH2=subplot(2,2,2); imshow(im2);
movegui(fshowH, 'northeast');

%% sift features
figure(fshowA); figure(fshowH);
[pts1 pts2] = SIFTmatch( im1, im2, 0, true );

%% ransac affine
[im2_TA, best_ptsA] = ransac( pts2, pts1, 'aff_lsq', 3 );
showbestpts(subA2, subA1, best_ptsA);
figure(fshowA);

%% ransac homography
figure(fshowA);
[im2_TH, best_ptsH] = ransac( pts2, pts1, 'proj_svd', 5 );
showbestpts(subH2, subH1, best_ptsH);
figure(fshowH);

%% stitch affine
[im_stitchedA, stitched_maskA, im1TA, im2TA] = stitch(im1, im2, im2_TA);
figure(fshowA);
subplot(2,2,3); imshow(im1TA);
subplot(2,2,4); imshow(im2TA);

fA=figure;
axis off;
movegui(fA, 'west');
imshow(im_stitchedA);

%% stitch homography
[im_stitchedH, stitched_maskH, im1TH, im2TH] = stitch(im1, im2, im2_TH);
figure(fshowH);
subplot(2,2,3); imshow(im1TH);
subplot(2,2,4); imshow(im2TH);

fH=figure;
axis off;
movegui(fH, 'east');
imshow(im_stitchedH);
