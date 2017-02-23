function addpaths
% CV Fall 2014 - Provided Code
% add necessary paths 
% 
% Created by Wen-Sheng Chu (wschu@cmu.edu)

addpath('lib');
if ismac
	if strcmpi(computer,'maci64')
		addpath('lib/mex/mexmaci64');
	else
		addpath('lib/mex/mexmaci32');
	end
elseif isunix
	if strcmpi(computer,'glnxa64')
		addpath('lib/mex/mexa64');
	else
		addpath('lib/mex/mexglx');
	end
elseif ispc
	if strcmpi(computer,'pcwin64')
		addpath('lib/mex/mexw64');
	else
		addpath('lib/mex/mexw32');
	end
end