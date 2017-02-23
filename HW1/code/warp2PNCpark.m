% WENBO ZHAO
% Q 4.2
% 2015

function [img_yourname_warped, img_PNCpark_yourname] = warp2PNCpark(img_PNCpark, img_yourname, p1, p2)

% compute Homography
H2to1 = computeH(p1, p2);
% warp image
outSize = size(img_PNCpark);
fillValue = 0;
img_yourname_warped = warpH(img_yourname, H2to1, outSize, fillValue);

% fuse image
% - find region to replace image
region = find(img_yourname_warped(:) ~= 0);
img_PNCpark_yourname = img_PNCpark(:);
img_PNCpark_yourname(region) = 0;
img_PNCpark_yourname = reshape(img_PNCpark_yourname, outSize);
% - fuse
img_PNCpark_yourname = img_PNCpark_yourname + img_yourname_warped;

end