function topTenWords = topTenVisualWords(averagePatches, imageDir, wordMapDir, imagePath)

    %get word map
    imageFile = fullfile(imageDir,imagePath);
    image = imread(imageFile);
    matPath = strrep(imagePath,'.jpg','.mat');
    matFile = fullfile(wordMapDir,matPath);
    obj = load(matFile);
    wordMap = obj.wordMap;

    %count words
    [count, words] = hist(wordMap,unique(wordMap));
    
    %sort 
    [value, indexes] = sort(count,'descend');
    
    %get top 10 words
    topTenWords = words(indexes(1:10));
    
    %top patches
    topPatches = averagePatches(topTenWords);
    
    disp(imagePath);
    
    %plot images
    figure
    imshow(image);
    figure
    imdisp(topPatches,'Size', 5);
    
end