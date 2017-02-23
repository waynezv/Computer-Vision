function [filterBank,dictionary] = getFilterBankAndDictionary(trainFiles)
% This function generates a dictionary given a list of images
% - INPUT: * trainFiles: a cell array of strings containing the full path to all images
% - OUTPUTS: * filterBank: a cell array of filters from FUNC::createFilterBank
%            * dictionary: a visual words dictionary from FUNC::kmeans
% 
% Author: WENBO ZHAO (wzhao1@andrew.cmu.edu)
% Date: Oct 3, 2015
% Log: (v0.1)-(first draft, written all the functions)-(Oct 3, 2015)
%      (v0.2)-(modified: fixed bug: improved: )
%
%%
% debug = 'finished filter response, start k-means'
% debug = 'start filter response';
%% Set directories
% imageDir = '../images/'
% switch debug
%     case 'start filter response'
%% generate filter bank
fprintf('Getting filter bank ... \n');
filterBank = createFilterBank();
fprintf('Done.\n');
%% Generate filter responses
fprintf('Generating filter responses ... \n');
alpha = 200; % [50,150]
for i = 1:length(trainFiles)
    I = imread(trainFiles{i});
    filterResp = extractFilterResponses(I, filterBank);
    randPixels = randperm(size(I(:),1), alpha);
    filterResp = filterResp(randPixels, :);
    filterResponses(i,:) = filterResp(:);
end
filterResponses = reshape(filterResponses, [length(trainFiles)*alpha, 3*size(filterBank,1)]);
fprintf('saving filter responses ... \n');
save('filterResponses', 'filterResponses');
fprintf('Done.\n');

%%     case 'finished filter response, start k-means'
% load filterBank.mat
% load filterResponses.mat
%% Cluster filter response
fprintf('Getting dictionary ... \n');
K = 200; % [100, 300]
[~,dictionary] = kmeans(filterResponses, K, 'EmptyAction', 'drop');
fprintf('Saving dictionary ... \n');
save('dictionary', 'dictionary');
fprintf('Done.\n');
% end

end
