%%%%% Global configuration file %%%%%%

%%% For ICCV 2005 short course on Object Recognition
%%% by R. Fergus, L. Fei-Fei and A. Torralba.

%%% Holds all settings used in all parts of the code, enabling the exact
%%% reproduction of the experiment at some future date.

%%% Single most important setting - the overall experiment type
%%% used by do_all.m
EXPERIMENT_TYPE = 'naive_bayes';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DIRECTORIES - please change if copying the code to a new location
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Directory holding the experiment 
RUN_DIR = [ '/home/fergus/demos/experiments/bag_of_words' ];
%RUN_DIR = [ 'C:\MATLAB6p5\demos\experiments\toy_plsa' ];

%%% Directory holding all the source images
IMAGE_DIR = [ '/home/fergus/demos/images' ];

%% Codebook directory - holds all VQ codebooks 
CODEBOOK_DIR = [ '/home/fergus/demos/codebooks/' ];   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GLOBAL PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Mostly boring file and directory name settings

%% File name that holds locations of objects. The variable in the file 
%% is gt_bounding_boxes which is a 1 x nImages (of that class) cell
%% array, each element holding a 4 x nInstances (per image) matrix, with
%% the bounding box for each instance within the image. The format is:
%% [top_left_x top_left_y width height];
%% (should originally be in subdirectories of IMAGE_DIR, but will be
%%  copied to RUN_DIR by do_preprocessing.m)
Global.Ground_Truth_Name = 'ground_truth_locations';

%% how many zeros to prefix image, interest and model files by....
Global.Num_Zeros = 4;

%% subdirectory, file prefix and file extension of images 
Global.Image_Dir_Name = 'images';
Global.Image_File_Name = 'image_';
%%% changing the extension changes to image format used...
Global.Image_Extension = '.jpg';

%% subdirectory, file prefix and file extension of interest point files 
Global.Interest_Dir_Name = 'interest_points';
Global.Interest_File_Name = 'interest_';
%% we assume all the interest point files have a .mat extension

%% prefix of config files when stored alongside saved models
Global.Config_File_Name = 'config_file_';
%% we assume all the configuration files have a .mat extension

%% subdirectory name to hold saved models and prefix of actual files
Global.Model_Dir_Name = 'models';
Global.Model_File_Name = 'model_';
%% we assume all the model files have a .mat extension


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CATEGORIES 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Image classes to use (cell array)
Categories.Name = {'faces2',
                   'background_caltech'
                  };

%% Frame range for each of the classes to use 
%% (must have an entry for each of the classes in Categories.Name)
Categories.Frame_Range = { [1:100] ,
                           [1:100]
                         };

%% relative sizes of training and test sets 
%% 0.5 = equal; <0.5 = more testing; >0.5 = more training
Categories.Train_Test_Portion = 0.5;

%% load up random permutation of frame numbers
if exist([RUN_DIR '/random_indices.mat']);
  load([RUN_DIR '/random_indices.mat']);
else %% if it doesn't exist create it....
  error('random_indices.mat does not exist - run do_random_indices.m to create it');
end

%% Set Train_Frames field from the random_ordering file
Categories.Train_Frames = train_frames;

%% same for test frames...
Categories.Test_Frames = test_frames;

%% also get indices of all training frames
Categories.All_Train_Frames = cat(2,train_frames{:});

%% same for test frames......
Categories.All_Test_Frames = cat(2,test_frames{:});

%% Which classes are positive (1) and which are -ve (0)
Categories.Labels = [ 1 0 ];

%% Compute the total # categories and frames used
Categories.Number = length(Categories.Name);
Categories.Total_Frames = sum(cellfun('prodofsize',Categories.Frame_Range));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% IMAGE PREPROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Fixed size to which images are rescaled
%% set to zero to leave images alone
Preprocessing.Image_Size            = 200;

%% Which axis to use for the Image_Size parameter
Preprocessing.Axis_For_Resizing     = 'x';

%% What method to use for rescaling images
Preprocessing.Rescale_Mode          = 'bilinear';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% INTEREST OPERATOR 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Type of interest operator to use
Interest_Point.Type                 = 'Edge_Sampling';

%% Scales at which features are extracted (radius of region in pixels).
Interest_Point.Scale                = [10:30];

%% Maximum number of interest points allowed per image
Interest_Point.Max_Points           = 200;

%% Parameters for particular type of detector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Interest_Point.Weighted_Sampling    = 1;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DESCRIPTOR SETTINGS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Type of descriptor to use
Descriptor.Type                 = 'SIFT';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% VECTOR QUANTIZATION SETTINGS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Type of descriptor to use
VQ.Codebook_Type                 = 'generic';

%% Number of entries in codebook
VQ.Codebook_Size                 = 300;

%% Number of k-means iterations to use
VQ.Max_Iterations                = 10;

%% Verbosity level of k-means
VQ.Verbosity                     = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LEARNING SETTINGS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% How many topics in pLSA model
Learn.Num_Topics = 2;

%% Max number of EM iterations
Learn.Max_Iterations  = 100;

%% Min. allowable lh change before EM termination
Learn.Min_Likelihood_Change   = 1;   
   
%% Control level of printed and plotted output during learning   
Learn.Verbosity = 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% RECOGNITION SETTINGS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% what criterion is used to pick best topic from model
Recog.Best_Topic_Criterion = 'roc_area';
%Recog.Best_Topic_Criterion = 'roc_op';
%Recog.Best_Topic_Criterion = 'rpc_ap';
%Recog.Best_Topic_Criterion = 'rpc_area';

%% Control level of printed and plotted output during recognition   
Recog.Verbosity = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FINAL PLOTTING SETTINGS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% how many to plot at one time. [1 1] for a single image.
Plot.Number_Per_Figure = [2 2];

%% how to plot out example images
Plot.Example_Mode = 'ordered'; % image_0001, image_0002 etc.
%Plot.Example_Mode = 'alternate'; % 1st +ve test set image, 1st -ve test set image, 2nd +ve, 2nd -ve etc.
%Plot.Example_Mode = 'random'; % use random indices
%Plot.Example_Mode = 'best'; % best by likelihood
%Plot.Example_Mode = 'worst'; % worst by likelihood
%Plot.Example_Mode = 'borderline'; % images close to descision threshold 

%% show text above each frame or not
Plot.Labels = 1;
