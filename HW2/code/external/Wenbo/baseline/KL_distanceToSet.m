function [histInter] = KL_distanceToSet(wordHist, histograms)
if(size(wordHist,1)==1)
    wordHist = wordHist';
end
length = size(histograms,2);
wordHist_long = repmat(wordHist,1,length);
% Compute KL divengence
histInter = sum(wordHist_long.*log(wordHist_long./histograms),1);
end
