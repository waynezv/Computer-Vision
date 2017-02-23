function batchToVisualWords(trainImagePaths,classnames,filterBank,dictionary,imageDir,targetDir,numCores)
% Ishan Misra
% CV Fall 2014 - Provided Code
% Does parallel computation of the visual words 
%
% Input:
%   numCores - number of cores to use (default 2)

if nargin < 1
    %default to 2 cores
    numCores = 2;
end

% Close the pools, if any
try
    fprintf('Closing any pools...\n');
    matlabpool close; 
catch ME
    disp(ME.message);
end

fprintf('Will process %d files in parallel to compute visual words ...\n',length(trainImagePaths));
fprintf('Starting a pool of workers with %d cores\n', numCores);
matlabpool('local',numCores);

%load the files and texton dictionary
load('dictionary.mat','filterBank','dictionary');

if ~exist(targetDir,'dir')
    mkdir(targetDir);
end

for c = 1:length(classnames)
    if ~exist(fullfile(targetDir,classnames{c}),'dir')
        mkdir(fullfile(targetDir,classnames{c}));
    end
end

%This is a peculiarity of loading inside of a function with parfor. We need to 
%tell MATLAB that these variables exist and should be passed to worker pools.
filterBank = filterBank;
dictionary = dictionary;

%matlab can't save/load inside parfor; accumulate
%them and then do batch save
l = length(trainImagePaths);

wordRepresentation = cell(l,1);
parfor i=1:l
    fprintf('Converting to visual words %s\n', trainImagePaths{i});
    image = imread(fullfile(imageDir, trainImagePaths{i}));
    wordRepresentation{i} = getVisualWords(image, filterBank, dictionary);
end

%dump the files
fprintf('Dumping the files\n');
for i=1:l
    wordMap = wordRepresentation{i};
    save(fullfile(targetDir, [strrep(trainImagePaths{i},'.jpg','.mat')]),'wordMap');
end

%close the pool
fprintf('Closing the pool\n');
matlabpool close

end
