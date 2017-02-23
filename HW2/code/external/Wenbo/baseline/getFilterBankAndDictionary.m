function [filterBank, dictionary] = getFilterBankAndDictionary(imPaths)

%parameters
K = 150;
alpha = 100;

%filter bank
filterBank = createFilterBank();

%size parameters
T = size(imPaths,1);
N = 3 * size(filterBank,1);

%complete set of filter responses
allFilterResponses = zeros(alpha*T, N);

for i = 1:length(imPaths)  
    % extract FilterResponses
    I = imread(imPaths{i});   
    imgResponses = extractFilterResponses(I,filterBank);
    
    %select alpha responses
    Rows = randperm(size(imgResponses,1),alpha);
    selectedResponses = imgResponses(Rows,:);
    Idx_1 = (i-1)*alpha + 1;
    Idx_2 = Idx_1 + alpha - 1;
    allFilterResponses( Idx_1:Idx_2, : ) = selectedResponses;    
end

% k-means
[~, dictionary] = kmeans(allFilterResponses, K, 'EmptyAction', 'drop');

end
