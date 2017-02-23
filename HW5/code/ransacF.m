function [F_best, inliers_best]  = ransacF(pts1, pts2, normalization_constant)
% Run RANSAC with seven point algorithm to find the fundamental matrix.
% >> pts1, pts2: points, 2-by-N
% >> normalization_constant: the larger dimension of an image
% << F_best: best fundamental matrix
% << inliers_best: best consensus set: indices of inliers of F, 1-by-a
%
% written by: Wenbo Zhao (wzhao1#andrew.cmu.edu)
% log: (v0.1)-(first draft)-(11-28-2015)
%
% Check inputs and set variables
if ~isequal(size(pts1), size(pts2))
    error('Dimensions of input points must match!');
end
num_pts    = size(pts1,2); % # of points
threshold  = 0.0005; % threshold to reject outliers
sample_pts = 7; % # of points selected each time
max_iter   = 5000; % max # of iterations
d          = 1000000000; % distance
inliers    = [];
F_best     = [];
inliers_best = [];
debug      = 0;
while max_iter
% Sample 
[sample_pt1, ind] = datasample(pts1', sample_pts, 'Replace', false);
sample_pt2        = pts2(:,ind)';

% Compute F
F = sevenpoint_norm(sample_pt1', sample_pt2', normalization_constant);

% Evaluate distance, add inliers to consensus set, and select best F
[F_new, dd, ~, inliers_new] = selectBestF(F, pts1, pts2, threshold, sample_pts);
d_new = abs(sum(dd));
if length(inliers_new) < sample_pts % +1)
    max_iter = max_iter-1;
    continue
else
    if(length(inliers_new) >= length(inliers))
        d = abs(d_new);
        inliers = inliers_new;
        F_best = F_new;
        inliers_best = inliers;
        
        if debug
            fprintf('Consensus set size: %d\n', length(inliers));
            fprintf('Distance of points to epipolar line: %f\n', d);
        end
    end
    % Update count
    max_iter = max_iter-1;
end
% Update F with selected inliers

end
end


function [FF, dd, ninliers, inliers] = selectBestF(F, p1, p2, threshold, sample_pts)
% Evaluate distance between point x2 and the epipolar line Fx1
% return F with most inliers that satisfy x2'Fx1<threshold

% Check dimension
if ~isequal(size(p1), size(p2))
    error('Dimensions of input points must match!');
end
N = size(p1, 2);
if size(p1, 1)~=3 
    p1 = [p1; ones(1,N)];
    p2 = [p2; ones(1,N)];
end

flag     = 0; % indicates if enough inliers in consensus set selected
ninliers = 0; % # of inliers
if iscell(F)
    for i = 1:length(F) 
        d = distPt2EpiLine(F{i}, p1, p2); % compute distance
        ind   = find(abs(d) < threshold); % find inliers
        count = length(ind);
        if (count >= ninliers) % && (count >= sample_pts+1) % make sure at least 7+1 inliers
            ninliers = count;
            inliers  = ind;
            dd = d;
            FF = F{i}; % selected F
        else 
            continue
        end 
    end
    
    
else
    d = distPt2EpiLine(F, p1, p2);
    ind = find(abs(d) < threshold);
    count = length(ind);
    if (count > ninliers) % && (count >= sample_pts+1)
        ninliers = count;
        inliers  = ind;
        dd = d;
        FF = F; % selected F
    end  
end
end

function d = distPt2EpiLine(F, p1, p2)
% Compute point to epipolar line distance
if ~isequal(size(p1), size(p2))
    error('Dimensions of input points must match!');
end
N = size(p1, 2);
if size(p1, 1)~=3 
    p1 = [p1; ones(1,N)];
    p2 = [p2; ones(1,N)];
end

for j = 1:N
    dist(j) = p2(:,j)'*F*p1(:,j);
end

d = [F*p1; F'*p2];
d = dist.^2 ./ sum(d([1 2 4 5], :).^2);
end