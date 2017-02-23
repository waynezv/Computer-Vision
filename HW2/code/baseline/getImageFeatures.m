function [h] = getImageFeatures(wordMap,dictionarySize)
% This function returns the histogram of visual words (bag of words) within
% the given image.
% - INPUTS: * wordMap: an index map of the size(Image) that maps each pixel 
%             response to its closest in the dictionary
%           * dictionarySize: # of visual words in the dictionary
% - OUTPUT: * h: a (dictionarySize*1) histogram
%
% Author: WENBO ZHAO (wzhao1@andrew.cmu.edu)
% Date: Oct 4, 2015
% Log: (v0.1)-(first draft, written all the functions)-(Oct 4, 2015)
%      (v0.2)-(modified: fixed bug: improved: )
%

h = hist(wordMap(:), dictionarySize);
h = (h./sum(h)).'; % normalize, sum(h)=1

end
