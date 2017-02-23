% CV Fall 2014 - Provided Code
% Make a sample video
%
% Created by Wen-Sheng Chu (Oct-20-2014)
function runMakeVideo
poohpath = 'data/pooh';

% Open video writer
vidname = 'sample_output.avi';
vidout  = VideoWriter(vidname);
vidout.FrameRate = 10;
open(vidout);

% Add frames to video
for iFrm = 992:1050
	
	% Read image
	I = imread(fullfile(poohpath, 'testing', sprintf('image-%04d.jpg',iFrm)));
	
	% Display to figure
	figure(1); 
	if ~exist('hh','var'), hh = imshow(I); hold on; 
	else set(hh,'cdata',I);
	end
	if ~exist('hFrmNum', 'var'), hFrmNum = text(30, 30, ['Frame: ',num2str(iFrm)], 'fontsize', 40, 'color', 'r');
	else set(hFrmNum, 'string', ['Frame: ',num2str(iFrm)]);
	end
	drawnow;
	
	% Write a frame to video, resized so that video will not be too big
	frm = getframe;
	writeVideo(vidout, imresize(frm.cdata, 0.5));
end

% Close video writer
close(vidout);
close(1);
fprintf('Video saved to %s\n', vidname);
