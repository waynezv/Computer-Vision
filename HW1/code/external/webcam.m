function out = webcam(i)
% see "Image Acquisition Toolbox"
% useful command: 
% % >> imaqtool
% % look up your cam settings in a gui
% % (can generate a m-file which sets up the cam)

if nargin < 1, i = 1;end

% Device Properties.
adaptorName = 'winvideo';
%vidFormat = 'I420_320x240';
vidFormat = 'YUY2_640x480';

vidObj1= videoinput(adaptorName, i, vidFormat);
set(vidObj1, 'ReturnedColorSpace', 'rgb');
set(vidObj1, 'FramesPerTrigger', inf);

out = vidObj1 ;
