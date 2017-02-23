function do_vq(config_file)

%% Function takes the regions in interest_points directory, along with
%% their descirptors and vector-quantizes them using the codebook
%% specified in the VQ structure.
  
%% The VQ label is then stored in the interest_point/interest_xxxx.mat
%% file in the descriptor_vq variable. A histogram over codebook
%% entries is also computed and stored.

%% Before running this, you must have run:
%%    do_random_indices - to generate random_indices.mat file
%%    do_preprocessing - to get the images that the operator will run on  
%%    do_interest_op  - to get extract interest points (x,y,scale) from each image
%%    do_representation - to get appearance descriptors of the regions 
  
%% You must also have either: (a) run do_form_codebook to generate a codebook file
%%                        or: (b) already have a valid codebook file in
%% CODEBOOK_DIR, matching the VQ.Codebook_Type tag and of size VQ.Codebook_Size.
  
%% R.Fergus (fergus@csail.mit.edu) 03/10/05.  
   
  
        
%% Evaluate global configuration file
eval(config_file);

%% If no VQ structure specifying codebook
%% give some defaults

if ~exist('VQ')
  %% use default codebook family
  VQ.Codebook_Type = 'generic';
  %% 1000 words is standard setting
  VQ.Codebook_Size = 1000;
end

%% Evaluate global configuration file
eval(config_file);
 
%% Get list of interest point file names
ip_file_names =  genFileNames({Global.Interest_Dir_Name},[1:Categories.Total_Frames],RUN_DIR,Global.Interest_File_Name,'.mat',Global.Num_Zeros);
 
%% How many images are we processing?
nImages = Categories.Total_Frames;

%% Now load up codebook
codebook_name = [CODEBOOK_DIR , '/', VQ.Codebook_Type ,'_', num2str(VQ.Codebook_Size) , '.mat'];
load(codebook_name);

tic;
  
  %%% Loop over all images....
  for i=1:nImages
    
    if (mod(i,10)==0)
      fprintf('.%d',i);
    end
    
    %%% Load up interest point file
    load(ip_file_names{i});
    
    %%% Find number of points per image
    nPoints = length(scale);
    
    %%% Set distance matrix to all be large values
    distance = Inf * ones(nPoints,VQ.Codebook_Size);
    
    %%% Loop over all centers and all points and get L2 norm btw. the two.
    for p = 1:nPoints
      for c = 1:VQ.Codebook_Size
        distance(p,c) = norm(centers(:,c) - double(descriptor(:,p)));
      end
    end
    
    %%% Now find the closest center for each point
    [tmp,descriptor_vq] = min(distance,[],2);

    %%% Now compute histogram over codebook entries for image
    histogram = zeros(1,VQ.Codebook_Size);
    
    for p = 1:nPoints
      histogram(descriptor_vq(p)) = histogram(descriptor_vq(p)) + 1;
    end
    
    %%% transpose to match other variables
    descriptor_vq = descriptor_vq';
    
    %%% append descriptor_vq variable to file....
    save(ip_file_names{i},'descriptor_vq','histogram','-append');
    
  end
  
total_time=toc;

fprintf('\nFinished running VQ process\n');
fprintf('Total number of images: %d, mean time per image: %f secs\n',nImages,total_time/nImages);




