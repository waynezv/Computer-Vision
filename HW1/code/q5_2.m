% WENBO ZHAO
% Q 5.2
% 2015

function [H2to1,panoImg]= q5_2(im1,im2,pts)

%% compute homography
p1 = pts(1:2,:); 
p2 = pts(3:4,:);
H2to1 = computeH(p1, p2);

%% find M that performs scaling and translation, and outSize 
corner1Homo = [0 size(im1,2) size(im1,2) 0;
      0 0 size(im1,1) size(im1,1);
      1 1 1 1]; % the homogeneous matrix of the corner points of im1
corner2Homo = [0 size(im2,2) size(im2,2) 0;
      0 0 size(im2,1) size(im2,1);
      1 1 1 1]; % the homogeneous matrix of the corner points of im2
corner1Warped = corner1Homo;
corner2Warped = H2to1*corner2Homo; % apply Homography
for count = 1:size(corner1Warped, 2)
    corner2Warped(:,count) = corner2Warped(:,count)./corner2Warped(3,count); 
end
corner1Warped = round(corner1Warped); % round the size
corner2Warped = round(corner2Warped);
% find the size that fits the warped images both
outSize = [max([corner1Warped(2,:) corner2Warped(2,:)]) - min([corner1Warped(2,:) corner2Warped(2,:)]),...
           max([corner1Warped(1,:) corner2Warped(1,:)]) - min([corner1Warped(1,:) corner2Warped(1,:)])];
       
m = 1280/outSize(2); % scale
M = [m 0 -m*min([corner1Warped(1,:),corner2Warped(1,:)]); 
     0 m -m*min([corner1Warped(2,:),corner2Warped(2,:)]);
     0 0 1];
outSize = round(m*outSize);

%% warp im1 and im2
fillValue = 0;
warp_im1 = warpH(im1, M, outSize, fillValue);
warp_im2 = warpH(im2, M*H2to1, outSize, fillValue);

%% fuse image
% - find region to replace image
region = find(warp_im2(:) ~= 0);
panoImg = warp_im1(:);
panoImg(region) = 0;
panoImg = reshape(panoImg, size(warp_im1));
% - fuse
panoImg = panoImg + warp_im2;

end