function F = sevenpoint_norm(p1, p2, normalizaton_constant)
% Run seven point algorithm to find the Fundamental matrix between points.
% >> pts1, pts2: points, 2-by-N
% >> normalization_constant: the larger dimension of an image
% << F: fundamental matrix
%
% written by: Wenbo Zhao (wzhao1#andrew.cmu.edu)
% log: (v0.1)-(first draft)-(11-27-2015)
%
% Check dimension
if ~isequal(size(p1), size(p2))
    error('Dimensions of input points must match!');
end
N = size(p1, 2);
if size(p1, 1)~=3 
    p1 = [p1; ones(1,N)];
    p2 = [p2; ones(1,N)];
end
% Normalize

% --- Construct A
% A = [xx1 yx1 x1 xy1 yy1 y1 x y 1];
% ::Better way getting A
[idx idy] = find(ones(size(p1,1)));
A = (p1(idx,:).*p2(idy,:))';
[~,~,V] = svd(A,0);

% --- Solve det(aF1+(1-a)F2)=0
% A contains 2-D null space with linear basis combination 
% f=af1+(1-a)f2 satisfying Af=0 ==> det(aF1+(1-a)F2)=0
F1 = V(:,end-1); F2 = V(:,end);
[F, a] = solve_det(F1, F2);
% F = T2' * F * T1;
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

function [F, a] = solve_det(F1, F2)
F1 = reshape(F1, [3, 3]);
F2 = reshape(F2, [3, 3]);

% Compose det(aF1+(1-a)F2)
c3 =     -det([F2(:,1) F1(:,2) F1(:,3)]) + det([F1(:,1) F2(:,2) F2(:,3)]) + ...
         det([F1(:,1) F1(:,2) F1(:,3)]) + det([F2(:,1) F2(:,2) F1(:,3)]) + ...
         det([F2(:,1) F1(:,2) F2(:,3)]) - det([F1(:,1) F2(:,2) F1(:,3)]) - ...
         det([F1(:,1) F1(:,2) F2(:,3)]) - det([F2(:,1) F2(:,2) F2(:,3)]);
         
c2 =     det([F1(:,1) F1(:,2) F2(:,3)]) -2*det([F1(:,1) F2(:,2) F2(:,3)])- ...
         2*det([F2(:,1) F1(:,2) F2(:,3)]) + det([F2(:,1) F1(:,2) F1(:,3)])-...
         2*det([F2(:,1) F2(:,2) F1(:,3)]) + det([F1(:,1) F2(:,2) F1(:,3)])+...
         3*det([F2(:,1) F2(:,2) F2(:,3)]);
         
c1 =     det([F2(:,1) F2(:,2) F1(:,3)]) + det([F1(:,1) F2(:,2) F2(:,3)]) + ...
         det([F2(:,1) F1(:,2) F2(:,3)]) -3*det([F2(:,1) F2(:,2) F2(:,3)]);
         
c0 =     det([F2(:,1) F2(:,2) F2(:,3)]);
detF = [c3;c2;c1;c0];
a = roots(detF);

% Get F
F{1} = a(1)*F1+(1-a(1))*F2; 
F{2} = a(2)*F1+(1-a(2))*F2;
F{3} = a(3)*F1+(1-a(3))*F2;

end