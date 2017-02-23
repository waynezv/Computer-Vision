function [histInter] = distanceToSet(wordHist, histograms)

if(size(wordHist,1)==1)
    wordHist = wordHist';
end
% intersection distance
histInter = sum(bsxfun(@min,wordHist,histograms));
end
