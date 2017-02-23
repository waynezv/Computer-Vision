function computeDictionary(trainImagePaths,imageDir)
% Ishan Misra
% CV Fall 2014 - Provided Code
% Does computation of the filter bank and dictionary, and saves
% it in dictionary.mat
%

% give the absolute path
trainImagePaths = cellfun(@(x)(fullfile(imageDir,x)),trainImagePaths,'uniformoutput',false);

%call the function and save output
[filterBank,dictionary] = getFilterBankAndDictionary(trainImagePaths);
save('dictionary.mat','filterBank','dictionary');
