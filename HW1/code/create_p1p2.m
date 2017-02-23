% WENBO ZHAO
% Q 4.2
% 2015
% 
img1 = imread('pnc.jpg');
img2 = imread('pnc_tomap.jpg');

[p1, p2] = cpselect('pnc.jpg','pnc_tomap.jpg','wait',true);

% use cpselect to save 2 sets of point pairs
% ... move to p1 and p2 as required
p1 = p1.';
p2 = p2.';
save('Q4.2.p1p2.mat', 'p1', 'p2') % save it

