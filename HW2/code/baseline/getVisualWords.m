function [wordMap]=getVisualWords(I,filterBank,dictionary)
  % This function map each pixel in the image to its closest word in the
  % dictionary.
  % - INPUTS: * I: image
  %           * filterBank: a bank of filters from FUNC::createFilterBank
  %           * dictionary: a visual words dictionary from FUNC::kmeans
  % - OUTPUT: * wordMat: an index map of the size(I) that maps each pixel
  %             response to its closest in the dictionary
  %
  % Author: WENBO ZHAO (wzhao1@andrew.cmu.edu)
  % Date: Oct 3, 2015
  % Log: (v0.1)-(first draft, written all the functions)-(Oct 3, 2015)
  %      (v0.2)-(modified: fixed bug: improved: )
  %
fprintf('\nMapping the filtered response of each pixel in image to its closest index in the visual word dictionary.\n\n');

% the filtered response for Image
% alpha = 100;
I_response = extractFilterResponses(I, filterBank); % response of (M pixels * N filters)
% compute the distance(ImageResponse, dictionary)
wordMap = zeros(size(I_response, 1),1);
dist = pdist2(I_response, dictionary);
[~, wordMap] = min(dist,[],2);
% for i = 1:size(I_response, 1)
%     dist = pdist2(I_response(i,:), dictionary);
%     [~, wordMap(i)] = min(dist); % find the closest and assign the index
% end
wordMap = reshape(wordMap, [size(I,1), size(I,2)]);

end
