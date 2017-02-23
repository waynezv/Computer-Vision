function do_interest_operator(config_file)
  
%% Top-level function that generates interest points for all images in
%% the images/ subidrectory, putting the output in interest_points/ 

%% This routine is a wrapper for each of the different interest operator
%% types you may have. Currently there is only one really simple operator based on
%% sampling from edgels found within the image. 
  
%% The structure Interest_Point should be passed to each interest
%% operator, and will hold all parameter settings for the operator.  
   
%% N.B. This routine does not give a representation to each region - it
%% only finds its location and scale within the image. Use
%% do_represenation to get SIFT descriptors or whatever describing each region.  

%% Before running this, you must have run:
%%    do_random_indices - to generate random_indices.mat file
%%    do_preprocessing - to get the images that the operator will run on  
  
%%% R.Fergus (fergus@csail.mit.edu) 03/10/05.  
  
%% Evaluate global configuration file
eval(config_file);

%% Create directories for interest points
[s,m1,m2]=mkdir(RUN_DIR,Global.Interest_Dir_Name);

%% Get list of file name of input images
img_file_names = genFileNames({Global.Image_Dir_Name},[1:Categories.Total_Frames],RUN_DIR,Global.Image_File_Name,Global.Image_Extension,Global.Num_Zeros);
 
%% Get list of output file names
ip_file_names =  genFileNames({Global.Interest_Dir_Name},[1:Categories.Total_Frames],RUN_DIR,Global.Interest_File_Name,'.mat',Global.Num_Zeros);
 
%% Find type of Interest Operator to be used
%% (should be specified in the config_file)
%% and run across 
tic;

if strcmp(Interest_Point.Type,'Edge_Sampling')

  %%% Edge Sampling: simple, crude interest operator.
  Edge_Sampling(img_file_names,ip_file_names,Interest_Point);
  
elseif strcmp(Interest_Point.Type,'Another_Type')
  
  %% Add your favourite interest point operator here....
  
else
  error('Unknown type of operator');
end

total_time=toc;

fprintf('\nFinished running interest point operator\n');
fprintf('Total number of images: %d, mean time per image: %f secs\n',Categories.Total_Frames,total_time/Categories.Total_Frames);
