function [histInter] = distanceToSet(wordHist, histograms)
% This function returns the histogram intersection similarity between
% wordHist and histograms.
% - INPUTS: * wordHist: a (K(4^(L+1)-1)/3 * 1) histogram
%           * histogram: a (K(4^(L+1)-1)/3 * T) histogram from T training
%             samples
% - OUTPUT: histInter: a (1*T) vector of similarity
%
% Author: WENBO ZHAO (wzhao1@andrew.cmu.edu)
% Date: Oct 4, 2015
% Log: (v0.1)-(first draft, written all the functions)-(Oct 4, 2015)
%      (v0.2)-(modified: fixed bug: improved: )
%
histInter = sum( bsxfun(@min, wordHist, histograms) ); % check dimensions
% must be (K(4^(L+1)-1)/3 * 1) and (K(4^(L+1)-1)/3 * T), histInter is (1*T)

end
