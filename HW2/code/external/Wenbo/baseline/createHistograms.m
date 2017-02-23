
function outputHistograms = createHistograms(dictionarySize,imagePaths,wordMapDir)
%code to compute histograms of all images from the visual words
%imagePaths: a cell array containing paths of the images
%wordMapDir: directory name which contains all the wordmaps

%Parameter
totalLayers = 3;
histSize = dictionarySize * ( 4^totalLayers - 1) / 3;
outputHistograms = zeros(histSize,length(imagePaths));

for i = 1:length(imagePaths)
   imagePath = imagePaths{i};
   matPath = strrep(imagePath,'.jpg','.mat');
   %load mat file
   matFile = fullfile(wordMapDir,matPath);
   obj = load(matFile);
   outputHistograms(:,i) = getImageFeaturesSPM(totalLayers, obj.wordMap, dictionarySize);
end
                      
 end
