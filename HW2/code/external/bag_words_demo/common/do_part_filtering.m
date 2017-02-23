function do_part_filtering(config_file)
  
%% Function that takes a hand-trained parts and structure model and runs
%% the part templates over the images, storing the locations of the top
%% Interest_Point.Max_Points points.

%% This procedure should only be called after running
%% do_manual_train_parts_structure, since the part_filter variable is needed. 
  
%% Before running this, you must have run:
%%    do_random_indices - to generate random_indices.mat file
%%    do_preprocessing - to get the images that the operator will run on  
%%    do_manual_train_parts_structure - to get the model and part
%                                       templates.
  
%% R.Fergus (fergus@csail.mit.edu) 03/10/05.  
   
%% Evaluate global configuration file
eval(config_file);

%% Create directories for interest points
[s,m1,m2]=mkdir(RUN_DIR,Global.Interest_Dir_Name);

%% Get list of file name of input images
img_file_names = genFileNames({Global.Image_Dir_Name},[1:Categories.Total_Frames],RUN_DIR,Global.Image_File_Name,Global.Image_Extension,Global.Num_Zeros);
 
%% Get list of output file names
ip_file_names =  genFileNames({Global.Interest_Dir_Name},[1:Categories.Total_Frames],RUN_DIR,Global.Interest_File_Name,'.mat',Global.Num_Zeros);
 
%% load up most recent model and take part filters from it.... 

%%% just take newest model in subdir.
ind = length(dir([RUN_DIR,'/',Global.Model_Dir_Name,'/', Global.Model_File_Name,'*.mat']));    
    
%%% construct model file name
model_fname = [RUN_DIR,'/',Global.Model_Dir_Name,'/',Global.Model_File_Name,prefZeros(ind,Global.Num_Zeros),'.mat'];

%%% load up model
load(model_fname);

tic;

if strcmp(Interest_Point.Type,'Norm_Corr')

  %%% Normalised correlation - as simple as it gets.
  Norm_Corr(img_file_names,ip_file_names,part_filter,Interest_Point);
  
elseif strcmp(Interest_Point.Type,'Another_Type')
  
  %% Add your favourite interest point operator here....
  
  %% other possible ones include: projection into PCA or ICA bases
  %%                              orientated Gabor filter bases                                
  
else

  error('Unknown type of operator');

end

total_time=toc;

fprintf('\nFinished running part filtering\n');
fprintf('Total number of images: %d, mean time per image: %f secs\n',Categories.Total_Frames,total_time/Categories.Total_Frames);
