% CV Fall 2014 - Provided Code
% Demo car tracker with Lucas-Kanade
%
% Created by Wen-Sheng Chu (Oct-20-2011)
addpaths; 

% init
load('data/car/carSequence'); % load sequence
nFrm = size(sequence, 4);     % number of frames for tracking
rect = [328, 213, 419, 265];  % initial car rectangle

% plot initial frames
drawFrmCar(sequence, rect,1); text(80,100,'Ready?','color','r','fontsize',30); pause(1);
drawFrmCar(sequence, rect,1); text(80,160,'GO!','color','g','fontsize',80); pause(.5);

% Start tracking!
for iFrm = 2:nFrm
	It    = sequence(:,:,:,iFrm-1);   % get previous frame
	It1   = sequence(:,:,:,iFrm);     % get current frame
	[u,v] = LucasKanade(It,It1,rect); % compute the displacement using LK
	rect  = rect + [u,v,u,v];         % move the car rectangle
	hf    = drawFrmCar(sequence, rect, iFrm); % draw frame
end
