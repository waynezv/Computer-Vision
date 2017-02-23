% ----- 16720J CV HW4: LK-SDM-Tracker -----
% THIS script implements Lucas-Kanade pooh component-based tracker
%
% Author: Wenbo Zhao (wzhao1#andrew.cmu.edu)
% Log: 
% 
clear all, close all
% Set paths & load data & init
addpaths; % ./lib
addpath ./data/pooh/;
testPooPa = './data/pooh/testing';

load rects_frm992.mat % rect_nose, rect_leye, rect_reye, rect_lear, rect_rear
initRect = [rect_nose; rect_leye; rect_reye; rect_lear; rect_rear];
[nRec, rSize] = size(initRect);
% Read image
imgName = dir(testPooPa); % get all image names
fprintf('images range: %s to %s \n', imgName(3).name, imgName(end).name);

% Open video for writing	
vidout = VideoWriter('pooh_lk.avi');
vidout.FrameRate = 20;
open(vidout);
    
for i = 1:length(imgName)
    if i==1 || i== 2
        continue % skip fisrt two, not image
    end
    if i==3
        img = imread(fullfile(testPooPa,imgName(i).name));
        drawPoo(img, initRect, i-2);
        text(80,100,'Ready?','color','r','fontsize',30); pause(1);
        hf = drawPoo(img, initRect, i-2);
        text(80,160,'GO!','color','g','fontsize',80); pause(.5);
        imgPre  = img;
        rectPre = initRect;
    else
        img  = imread(fullfile(testPooPa,imgName(i).name));
        rect = rectPre;
        for j = 1:nRec
            [u,v] = LucasKanade(imgPre,img,rect(j,:)); % compute the displacement using LK
            rect(j,:) = rect(j,:) + [u,v,u,v]; % move rectangle
        end
        hf      = drawPoo(img, rect, i-2); % draw frame
        imgPre  = img;
        rectPre = rect;
    end     
%resized so that video will not be too big
frm = getframe;
writeVideo(vidout, imresize(frm.cdata, 0.5));
end
	
% close vidobj
close(vidout);
fprintf('Video saved to %s\n', vidname);
