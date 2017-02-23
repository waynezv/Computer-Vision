% Get two images for matching.
% mode: 0 capture two (initial) images from cam
%       1 use two last images
%       2 feedback mode: pass through one supplied image and capture a new
%       5 video (not working yet)
%       6 capture single image
function [im1,im2] = acquireImages(cam, mode, oldimage)

if nargin == 1
    mode = 0;
end

switch mode
    case 0
        % default mode: capture two images
        disp('capturing first image...')
        im1 = getsnapshot(cam);
        disp('image captured.');
        
        input('press enter to capture next image')
        disp('capturing second image...')
        im2 = getsnapshot(cam);
        disp('image captured.');
    case 1
        disp('using previous images')
        im1=imread('input1.png');
        im2=imread('input2.png');
    case 2
        im1 = oldimage;        
        disp('capturing image...')
        im2 = getsnapshot(cam);
        disp('image captured.')
    case 6
        disp('capturing image..')
        im1 = getsnapshot(cam);
        disp('image captured.');
        im2=im1;
end
fprintf('\n');
if mode ~= 1
    % save input images
    imwrite(im1,'input1.png');
    imwrite(im2,'input2.png');
end

end
