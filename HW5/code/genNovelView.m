function genNovelView
addpath(genpath('.'));
load('data/K.mat'); %intrinsic parameters K
i1 = imread('data/i1.jpg');
i2 = imread('data/i2.jpg');
load ./data/noisy_correspondences.mat

% Find F
fprintf('Finding fundamental matrix...\n');
normalization_constant = max(size(i1));
[p1, T1] = normalize_point(pts1);
[p2, T2] = normalize_point(pts2);
[F, inliers]  = ransacF(p1, p2, normalization_constant);
F = T2' * F * T1

% Find P
K1 = K; K2 = K;
M2 = camera2(F, K1, K2, pts1, pts2);
M1 = K1*eye(3,4);
P = triangulate(M1, pts1, M2, pts2);

% Find plane with ransac
tic
fprintf('\nFinding plane 1...\n');
[P_para_1, P_best, inliers_best]  = ransacP(P);
P2 = P(:, setdiff([1:1:size(P,2)], inliers_best));
fprintf('\nFinding plane 2...\n');
[P_para_2, ~, ~]  = ransacP(P2);
toc

% Plot novel view
smith_south_plane = P_para_1
smith_west_plane  = P_para_2
fprintf('Draw novel view.\n');
frame = drawNovelView(smith_south_plane, smith_west_plane, M2);
figure, imshow(frame)

t = pi/6;
M3 = K1*[1      0       0  1;
         0  cos(t) -sin(t) 2;
         0  sin(t)  cos(t) 1];
frame2 = drawNovelView(smith_south_plane, smith_west_plane, M3);     
figure, imshow(frame2)
end

function [p, T] = normalize_point(pt)
% Normalize to zero mean and unit variance
% Ref: 1. the attached pdf file in http://www.researchgate.net/post/Calculating_the_fundamental_matrix_using_the_eight_point_algorithm2
%      2. http://ece631web.groups.et.byu.net/Lectures/ECEn631%2013%20-%208%20Point%20Algorithm.pdf
% Make homo
N = size(pt, 2);
if size(pt,1)~=3
    pt = [pt; ones(1,N)];
end
% Find center
center  = mean(pt(1:2,:), 2);
% Displacement to center
dist = pt(1:2,:) - repmat(center, [1, N]);
d = sqrt(dist(1,:).^2 + dist(2,:).^2);
% Scale
s = sqrt(2)/mean(d);
% Transform matrix
T = [s 0 -s*center(1); 0 s -s*center(2); 0 0 1];
p = T*pt;
end
