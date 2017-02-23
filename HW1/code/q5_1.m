% WENBO ZHAO
% Q 5.1
% 2015

function [H2to1,warpedImg,panoImg]= q5_1(im1,im2,pts)

% compute homography
p1 = pts(1:2,:); 
p2 = pts(3:4,:);

H2to1 = computeH(p1, p2);
fprintf('saving H2to1 to q5_1.mat...\n');
save('q5_1.mat', 'H2to1');

% compute the transformed feature points of taj1 by H2to1
P2 = [p2; repmat(1, [1 size(p2,2)])];
P1 = H2to1 * P2;  
for count = 1:size(P2,2)
    P1(:,count) = P1(:,count) ./ P1(3,count);
end
P1 = P1(1:2,:);
fprintf('saving P1 to q5_1_warpedFeatures.mat...\n');
save('q5_1_warpedFeatures.mat', 'P1');

% error: RMSE = sqrt(MSE)
SE = (P1 - pts(1:2,:)).^2;
MSE = sum((SE(1,:)+SE(2,:)))./size(P1,2);
RMSE = sqrt(MSE)

% warp
outSize = [size(im1,1), 3000];
warpedImg = warpH(im2, H2to1, outSize);
fprintf('saving warped image to q5_1.jpg...\n')
imwrite(warpedImg, 'q5_1.jpg');

% pano
panoImg = [im1 warpedImg(:, size(im1,2):end,:)];
fprintf('saving pano image to q5_1_pan.jpg...\n')
imwrite(panoImg, 'q5_1_pan.jpg');

end


