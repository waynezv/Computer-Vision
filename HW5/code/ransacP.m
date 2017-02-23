function [P_para, P_best, inliers_best]  = ransacP(P)
% Run RANSAC to find plane.
% >> P: 3-D points, 3-by-N
% >> P_para: parameters of plane, [a b c d]'
% << P_best: selected 3 points to form the plane
% << inliers_best: best consensus set
%
% written by: Wenbo Zhao (wzhao1#andrew.cmu.edu)
% log: (v0.1)-(first draft)-(11-28-2015)
%

num_pts    = size(P,2); % # of points
threshold  = 0.05; % threshold to reject outliers
sample_pts = 3; % # of points selected each time
max_iter   = 5000; % max # of iterations
d          = 1000000000; % distance
inliers    = [];
P_best     = [];
inliers_best = [];
debug      = 0;
while max_iter
% Sample 
[sample_pt, ~] = datasample(P', sample_pts, 'Replace', false);

% Compute plane
plane = sample_pt';
if numel(plane)~=9
    max_iter = max_iter-1;
    continue
end

% Evaluate distance, add inliers to consensus set, and select best plane
[plane_new, Pn, dd, inliers_new] = selectBestP(plane, P, threshold);
d_new = abs(sum(dd));
if length(inliers_new) < sample_pts % +1)
    max_iter = max_iter-1;
    continue
else
    if(length(inliers_new) >= length(inliers))
        d = abs(d_new);
        inliers = inliers_new;
        P_para  = Pn;
        P_best  = plane_new;
        inliers_best = inliers;
        
        if debug
            fprintf('Consensus set size: %d\n', length(inliers));
            fprintf('Distance of points to plane: %f\n', d);
        end
    end
    % Update count
    max_iter = max_iter-1;
end
end

end


function [plane_new, Pn, d, inliers] = selectBestP(plane, P, threshold)
% Evaluate distance between points and a plane
% return optimal plane parameters
[Pn, d] = distPt2Plane(plane, P);
inliers= find(abs(d) < threshold);
plane_new = plane;
end

function [Pn, d] = distPt2Plane(plane, P)
% Compute point to plane distance
N = size(P,2); % # of points
m = 1;
switch m
    case 1
        plane = [plane' ones(3,1)];
        if size(plane,2)==3
            plane = [plane; zeros(1,4)];
        end
        [U D V] = svd(plane,0);
        Pn = V(:,4); % normal vector to plane, also the plane parameters
    case 2
        Pn = plane\(-1*ones(3,1));
        Pn = [Pn;1];
end
for i=1:N
    d(i) = P(1,i)*Pn(1) + P(2,i)*Pn(2) + P(3,i)*Pn(3) + Pn(4);
end
end