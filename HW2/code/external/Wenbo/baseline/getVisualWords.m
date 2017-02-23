function [wordMap]=getVisualWords(I,filterBank,dictionary)
  
imgResponses = extractFilterResponses(I,filterBank);

%compute distance and wordMap
distances = pdist2(imgResponses,dictionary);
[~,index] = min(distances,[],2);
wordMap = reshape(index,[size(I,1) size(I,2)]);

end

