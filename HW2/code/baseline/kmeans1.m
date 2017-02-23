function [unused, dictionary] = kmeans(filterResponses, K)
% This function use k-means clustering to cluster similar filter responses
% - INPUTS: * filterResponses: filter responses from FUNC::extractFilterResponses
%           * K: number of clusters
% - OUTPUTS : * dictionary: return a visual words dictionary with K words
%
% Author: WENBO ZHAO (wzhao1@andrew.cmu.edu)
% Date: Oct 3, 2015
% Log: (v0.1)-(first draft, written all the functions)-(Oct 3, 2015)
%      (v0.2)-(modified: fixed bug: improved: )
%

%% Initial setups
% - initialize values
X = filterResponses;
[m n] = size(X);
max_iters = 10;
plot_progress = true;

% - set default value for plot progress
if ~exist('plot_progress', 'var') || isempty(plot_progress)
    plot_progress = false;
end 

% - plot the data if we are plotting progress
if plot_progress
    figure;
    hold on;
end

% - initialize centroids
initial_centroids = kMeansInitCentroids(X, K);
centroids = initial_centroids;
previous_centroids = centroids;
idx = zeros(m, 1);

%% Run K-Means
for i=1:max_iters
    
    % Output progress
    fprintf('K-Means iteration %d/%d...\n', i, max_iters);
    %% Find closest centroids
    fprintf('Finding closest centroids.\n\n');
    % For each example in X, assign it to the closest centroid
    idx = findClosestCentroids(X, centroids);
    %% Plot progress
    % Optionally, plot progress here
    if plot_progress
        plotProgresskMeans(X, centroids, previous_centroids, idx, K, i);
        previous_centroids = centroids;
%         fprintf('Press enter to continue.\n');
        pause(0.25);
    end
    %% Compute new centroids
    % Given the memberships, compute new centroids
    centroids = computeCentroids(X, idx, K);
end

% Hold off if we are plotting progress
if plot_progress
    hold off;
end

dictionary = centroids;
% ??
unused = 0;
end


function initial_centroids = kMeansInitCentroids(X, K);
% This function initialize the centroids fot k-means

centroids = zeros(K, size(X, 2));
% Initialize the centroids to be random examples
% - randomly reorder the indices of examples
randidx = randperm(size(X, 1));
% randidx = randperm(K);
% Take the first K examples as centroids
initial_centroids = X(randidx(1:K), :);
end


function idx = findClosestCentroids(X, centroids)
% Set K
K = size(centroids, 1);
idx = zeros(size(X,1), 1);

for i = 1 : size(X,1)
    X_dup = repmat( X(i, :), K, 1);
    % compute distance between X_dup and each centoid
    dis = sum((X_dup - centroids) .^ 2, 2);
    % find the index for min(dis)
    [~, I] = min(dis, [], 1);
    idx(i) = I; 
end

end

function centroids = computeCentroids(X, idx, K)
%COMPUTECENTROIDS returs the new centroids by computing the means of the 
%data points assigned to each centroid.
%   centroids = COMPUTECENTROIDS(X, idx, K) returns the new centroids by 
%   computing the means of the data points assigned to each centroid. It is
%   given a dataset X where each row is a single data point, a vector
%   idx of centroid assignments (i.e. each entry in range [1..K]) for each
%   example, and K, the number of centroids. You should return a matrix
%   centroids, where each row of centroids is the mean of the data points
%   assigned to it.
%

% Useful variables
[m n] = size(X);
centroids = zeros(K, n);

for i = 1 : K
centroids(i, :) = sum( X((idx == i), :) ) / sum(idx == i);
end
% Vectorized expression??
% centroids = ?
end

function plotProgresskMeans(X, centroids, previous, idx, K, i)
%PLOTPROGRESSKMEANS is a helper function that displays the progress of 
%k-Means as it is running. It is intended for use only with 2D data.
%   PLOTPROGRESSKMEANS(X, centroids, previous, idx, K, i) plots the data
%   points with colors assigned to each centroid. With the previous
%   centroids, it also plots a line between the previous locations and
%   current locations of the centroids.
%

% Plot the examples
plotDataPoints(X, idx, K);

% Plot the centroids as black x's
plot(centroids(:,1), centroids(:,2), 'x', ...
     'MarkerEdgeColor','k', ...
     'MarkerSize', 10, 'LineWidth', 3);

% Plot the history of the centroids with lines
for j=1:size(centroids,1)
    drawLine(centroids(j, :), previous(j, :));
end

% Title
title(sprintf('Iteration number %d', i))

end

function plotDataPoints(X, idx, K)
%PLOTDATAPOINTS plots data points in X, coloring them so that those with the same
%index assignments in idx have the same color
%   PLOTDATAPOINTS(X, idx, K) plots data points in X, coloring them so that those 
%   with the same index assignments in idx have the same color

% Create palette
palette = hsv(K + 1);
colors = palette(idx, :);

% Plot the data
scatter(X(:,1), X(:,2), 15, colors);

end

function drawLine(p1, p2, varargin)
%DRAWLINE Draws a line from point p1 to point p2
%   DRAWLINE(p1, p2) Draws a line from point p1 to point p2 and holds the
%   current figure

plot([p1(1) p2(1)], [p1(2) p2(2)], varargin{:});

end


