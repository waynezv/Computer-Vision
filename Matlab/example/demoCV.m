% Several demos of image processing using matlab.
%
% Adopt some codes from "http://ece.cet.ac.in/santhosh/dip/matlab.html"
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 08-26-2013
%   modify  -  Feng Zhou (zhfe99@gmail.com), 08-27-2013

%% reading image
X = imread('mug.jpg');

figure(1); clf;
imshow(X);

%% saving image to file
Y = X;
Y(1 : 10, 1 : 10, :) = 0;
imwrite(Y, 'mug2.jpg');

%% show pixel info
figure(1); clf;
imshow(X);
impixelinfo;

%% converting RGB image to gray image
Y = rgb2gray(X);

figure(1); clf;
subplot(1, 2, 1);
imshow(X);
subplot(1, 2, 2);
imshow(Y);

%% resize
Y = imresize(X, [100, 200]);

figure(1); clf;
subplot(1, 2, 1);
imshow(X);
subplot(1, 2, 2);
imshow(Y);

%% crop
figure(1); clf;
subplot(1, 2, 1);
imshow(X);

rect = getrect;

Y = imcrop(X, rect);

subplot(1, 2, 2);
imshow(Y);

%% rotate
Y = imrotate(X, 45);

figure(1); clf;
subplot(1, 2, 1);
imshow(X);
subplot(1, 2, 2);
imshow(Y);

%% affine transformation
A = [1 0 0; ...
     .5 1 0; ...
     0 0 1];
tform = maketform('affine', A);
Y = imtransform(X, tform);

figure(1); clf;
subplot(1, 2, 1);
imshow(X);
subplot(1, 2, 2);
imshow(Y);

%% Gaussian
XG = im2double(rgb2gray(X));
h = fspecial('gaussian', 10, 3);
Y = filter2(h, XG);

figure(1); clf;
subplot(1, 3, 1);
imagesc(h);
colorbar;

subplot(1, 3, 2);
imshow(X);
subplot(1, 3, 3);
imshow(Y);

%% Laplacian of Gaussian
h = fspecial('log', 5);
Y = filter2(h, XG);

figure(1); clf;
subplot(1, 3, 1);
imagesc(h); colorbar;
subplot(1, 3, 2);
imshow(X);
subplot(1, 3, 3);
imshow(Y);

%% using median filtering to remove salt and pepper noise
Y = imnoise(XG, 'salt & pepper', 0.05);
Z = medfilt2(Y, [3, 3]);
figure(1); clf;
subplot(1, 2, 1);
imshow(Y);
subplot(1, 2, 2);
imshow(Z);

%% edge detection
Y = edge(XG, 'sobel');
Z = edge(XG, 'canny');
figure(1); clf;
subplot(1, 3, 1);
imshow(X);
subplot(1, 3, 2);
imshow(Y);
subplot(1, 3, 3);
imshow(Z);

%% reading and playing movie
hr = VideoReader('walk.avi');
nF = hr.NumberOfFrames;

figure(1); clf;
for iF = 1 : nF
    X = read(hr, iF);
    imshow(X);
    pause(.1);
end

%% saving movie to a file
hr = VideoReader('walk.avi');
nF = hr.NumberOfFrames;

hw = VideoWriter('walk2.avi', 'Motion JPEG AVI');
hw.FrameRate = hr.FrameRate;
open(hw);

for iF = 1 : nF
    X = read(hr, iF);
    
    %% gaussian filtering
    XG = im2double(rgb2gray(X));
    h = fspecial('gaussian', 10, 3);
    Y = filter2(h, XG);
    
    %% save to video
    writeVideo(hw, Y);
end

close(hw);
