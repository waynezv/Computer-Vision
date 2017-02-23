function do_form_codebook(config_file,codebook_name,codebook_size)
  
%% Function takes the regions from all training images in the interest_points directory, along with
%% their descirptors and performs k-means on the descriptors to form a codebook
%% for use in the do_vq function. The codebook is a
%% nDescriptor_Dimensions by VQ.Codebook_Size matrix holding the centers
%% of each cluster. This is then saved in the CODEBOOK_DIR directory,
%% using a filename consisting of the VQ.Codebook_Type tag and the number
%% of clusters, VQ.Codebook_Size. 

%% The clustering is performed using VGG code from Oxford written by Mark
%% Everingham. The source is provided, which must be compiled to a MEX file
%% for your given platform (the Linux one is already provided).  
  
%% N.B. The 2nd and 3rd inputs, codebook_name and codebook_size are
%% strings that over-ride the settings in the VQ
%% structure from config_file.

%% Before running this, you must have run:
%%    do_random_indices - to generate random_indices.mat file
%%    do_preprocessing - to get the images that the operator will run on  
%%    do_interest_op  - to get extract interest points (x,y,scale) from each image
%%    do_representation - to get appearance descriptors of the regions  

%% R.Fergus (fergus@csail.mit.edu) 03/10/05.  
  
%% Evaluate global configuration file
eval(config_file);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% If no VQ structure specifying codebook
%% give some defaults

if ~exist('VQ')
  %% use default codebook family
  VQ.Codebook_Type = 'generic';
  %% 1000 words is standard setting
  VQ.Codebook_Size = 1000;
  %% Max number of k-means iterations
  VQ.Max_Iterations = 10;
  %% Verbsoity of Mark's code
  VQ.Verbosity = 0;
end

%% Set codebook name and size if not manually specified.
if (nargin==1)
  codebook_name = VQ.Codebook_Type;
  codebook_size = VQ.Codebook_Size;
end

%% Get list of interest point file names
ip_file_names =  genFileNames({Global.Interest_Dir_Name},Categories.All_Train_Frames,RUN_DIR,Global.Interest_File_Name,'.mat',Global.Num_Zeros);
 
%% How many images are we processing?
nImages = length(Categories.All_Train_Frames);

%% create variable to hold all descriptors
all_descriptors = [];

%% Load up all interest points from all images....
for i = 1:nImages
  
  %% load up all interest points
  load(ip_file_names{i});
  
  %% Add descriptors to collection
  all_descriptors = [all_descriptors, descriptor];
    
end

%% form options structure for clustering
cluster_options.maxiters = VQ.Max_Iterations;
cluster_options.verbose  = VQ.Verbosity;

%% OK, now call kmeans clustering routine by Mark Everingham
[centers,sse] = vgg_kmeans(double(all_descriptors), codebook_size, cluster_options);

%% form name to save codebook under
fname = [CODEBOOK_DIR , '/', codebook_name ,'_', num2str(codebook_size) , '.mat']; 

%% save centers to file...
save(fname,'centers');
