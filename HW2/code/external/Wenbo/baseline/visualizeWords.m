imageDir = '../images'; %where all images are located
wordMapDir = '../images';%where we will store visual word outputs
load('traintest.mat');
load('dictionary.mat');

%parameters
totalImages = length(trainImagePaths);
patchSize = 2*4 + 1;
dicSize = size(dictionary,1);


%initialize patches
averagePatches = cell(1,dicSize);
for i=1:dicSize
    averagePatches{i} = zeros(patchSize,patchSize,3);
end
visualWordCount = zeros(1,dicSize);


%sample train images
sampleRate = 0.1;
selectedImages = datasample(1:totalImages,int16(sampleRate*totalImages));

%loop over train images
for img_idx=sort(selectedImages)
    
    %get image and word map
    imagePath = trainImagePaths{img_idx};
    imageFile = fullfile(imageDir,imagePath);
    image = imread(imageFile);
    matPath = strrep(imagePath,'.jpg','.mat');
    matFile = fullfile(wordMapDir,matPath);
    obj = load(matFile);
    wordMap = obj.wordMap;
    
    %image dimensions
    imgHeight = size(wordMap,1);
    imgWidth = size(wordMap,2);
    
    %if image is too small
    if imgHeight<patchSize || imgWidth<patchSize
        continue
    end
    
    %go through pixels and get patch
    for i=(4+1):(imgHeight-4)
        for j=(4+1):(imgWidth-4)
            patch = image( (i-4):(i+4), (j-4):(j+4), : );
            idx = wordMap(i,j);
            averagePatches{idx} = averagePatches{idx} + double(patch);
            visualWordCount(idx) = visualWordCount(idx) + 1;
        end
    end
    
    disp(img_idx);
end
%normalize patches
for i=1:dicSize
    if visualWordCount(i)>0
        averagePatches{i} = uint8(averagePatches{i} / visualWordCount(i));
    end
end

%display visual word average patches
imdisp(averagePatches,'Size', 20);
