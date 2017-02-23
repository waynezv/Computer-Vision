imageDir = '../images'; %where all images are located
wordMapDir = '../wordmap';%where we will store visual word outputs 
load('traintest.mat');
load('dictionary.mat');

%parameters
totalImages = length(trainImagePaths);
patchHalfSide = 4;
patchSize = 2*patchHalfSide + 1;
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
    for i=(patchHalfSide+1):(imgHeight-patchHalfSide)
        for j=(patchHalfSide+1):(imgWidth-patchHalfSide)
            patch = image( (i-patchHalfSide):(i+patchHalfSide), (j-patchHalfSide):(j+patchHalfSide), : );
            visualWordIndex = wordMap(i,j);
            averagePatches{visualWordIndex} = averagePatches{visualWordIndex} + double(patch);
            visualWordCount(visualWordIndex) = visualWordCount(visualWordIndex) + 1;
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

save('pixelPatch2', 'averagePatches');

addpath ./export_fig
export_fig('visualwords', '-pdf')