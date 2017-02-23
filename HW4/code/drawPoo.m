function hf = drawPoo(img, rect, iFrm)
% CV Fall 2014 - Provided Code
% draw a frame for car tracker

hf = figure(1); clf; hold on;
imshow(img);
[nRec, rSize] = size(rect);
if rSize~=4
    error('Rectangle must be 1 by 4!\n');
else
for i = 1:nRec
    drawRect([rect(i,1:2),rect(i,3:4)-rect(i,1:2)],'r',3);
end
text(80,50,['frame ',num2str(iFrm)],'color','y','fontsize',30);
hold off;
title('Pooh Bear tracker with Lucas-Kanade Tracker');
drawnow;
end