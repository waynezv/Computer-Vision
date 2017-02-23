function [h] = getImageFeatures(wordMap,dictionarySize)

h = zeros(1,dictionarySize);

%count clusters
[count,clusters]=hist(wordMap,unique(wordMap));
count_sum = sum(count,2);
h(clusters) = count_sum;

%normalization
h = h / numel(wordMap);

end