function SIFT(image_file_names,interest_file_names,Descriptor)
  
%% Function calls SIFT descriptor code of Krystian Mikolajczyk
%% via a front-end written by Jiri Matas and Frederik Schaffalitzky
%% 

%% Code returns SIFT descriptor of featuers and also characteristic angle
%% of region in image. These are saved into the same file as output by
%% the interest operators. Some regions may be discarded since they may
%% have a portion lying out side the image, so a descriptor vector cannot
%% be computed. 
  
%% Although not currently implemented, the JM and FSM code can handle
%% affine invariant regions, in addition to the scale-invariant ones  
%% currently used.

%% R. Fergus 03/10/05.  
  
%%% Default parameters section
if (nargin<3)
   fprintf('SIFT descriptor: No settings specified, so using defaults...\n');
   %%% No parameters for sift operator at present
end

%%% Setup parameters for JM and FSM's interface code
%% Get path of binary 
tmp = which('compute_descriptors.ln');
%% remove string "compute_descriptors.ln" 
%% from path
Par.Path.bin_dir = tmp(1:end-23);

%% silent operation of code
Verbose = 0;

%%% Get total number of images
nImages = length(image_file_names);

%%% Loop over all images
for i = 1:nImages
  
  %% load in image
  im = imread(image_file_names{i});

  %% get size
  [imy,imx,imz] = size(im);
     
  %% load in interest point file for image
  load(interest_file_names{i});
   
  %% find out how many points were found
  nPoints = length(scale);
   
  if nPoints>0 %% check that we have some points to find descriptors of
      
    %% if the image is in color, convert to grayscale...
    if (size(im,3)>1)
      im = rgb2gray(im);
    end
      
    %% Setup format of feature to interface with FSM & JM's code
    e = repmat([1 0 1]',1,nPoints);
    fts = [ x ; y ; e ]; 
               
    %% Call JM and FSM's code, which in turn calls KM's binary.
    [sift_descriptors, ftsout, angle, ind, out_imname] = gg_lola_km_binary(im, fts, scale' , 'sift', Verbose , Par);
      
    %% ind holds the index of the valid points found (some might have
    %%been too near the edge of the image to get a valid descriptor of...
    
    %% So throw away bad points.... 
    x = x(ind);
    y = y(ind);
    scale = scale(ind);
    score = score(ind);
        
    %% angle just needs transposing
    angle = angle';
    
    %% store descritpors as uint8 to save space....
    descriptor = uint8(sift_descriptors'); 

   else
    
     x = [];
     y = [];
     scale = [];
     score = [];
     angle = [];
     descriptor = [];
           
   end

   %%% save out results...
   save(interest_file_names{i},'x','y','scale','score','angle','descriptor');
   
   %%% print out progress every 10 images    
   if (mod(i,10)==0)
      fprintf('%d.',i);
   end
   
end
