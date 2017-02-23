function F = eightpoint_norm(pts1, pts2, normalizaton_constant)
% Run eight point algorithm to find the Fundamental matrix between points.
% >> pts1, pts2: points, 2-by-N
% >> normalization_constant: the larger dimension of an image
% << F: fundamental matrix
%
% written by: Wenbo Zhao (wzhao1#andrew.cmu.edu)
% log: (v0.1)-(first draft)-(11-27-2015)
%
% Declaration: I lost all my scripts due to matlab crash! No backup!
% No version control! No history command! It drove me mad!
% I have to write them again! I am upset!
% 
% Stay cool... Calm down... A good style is my style... Smile... and
% write
%
% Check dimension
if ~isequal(size(pts1), size(pts2))
    error('Dimensions of input points must match!');
end
N = size(pts1, 2);
if size(pts1, 1)~=3 
    pts1 = [pts1; ones(1,N)];
    pts2 = [pts2; ones(1,N)];
end
% Normalize: using a different scheme, rendering normalization_constant
% useless
[pt1, T1] = normalize_point(pts1);
[pt2, T2] = normalize_point(pts2);
% Construct A
% A = [xx1 yx1 x1 xy1 yy1 y1 x y 1];
x = pt1(1,:); y = pt1(2,:); x1 = pt2(1,:); y1 = pt2(2,:);
A = [x'.*x1'  y'.*x1'  x1'  x'.*y1'  y'.*y1'  y1'  x'  y'  ones(1,N)'];
% SVD(A)
[~,~,V] = svd(A,0);
% Get F
F = reshape(V(:,9), [3, 3]);
[U1, D1, V1] = svd(F);
F = U1 * diag([D1(1,1) D1(2,2) 0]) * V1'; % rank 2
F = T2' * F * T1;
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