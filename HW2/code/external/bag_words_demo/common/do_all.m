function do_all(config_file)

%%% Top-level script for ICCV short course demos  
%%% Overall routine that does everything, call this with 
%%% a configuration file and it will run each subsection of the scheme in
%%% turn. See the comments in each do_ routine for details of what it does

%%% ALL settings for the experiment should be held in the configuration
%%% file. When first running the code, please ensure all paths within the
%%% configuration file are correct.  
  
%% Platform requirements: The currentl implementation only runs under 32-bit Linux
%% as the implementation of SIFT uses a Linux binary from
%% Krystian Mikolajczyk (km@robots.ox.ac.uk). The rest of the code will
%% run fine under Windows, so you will need alternative code to use in place
%% of the SIFT descriptor binary if you intend to use it under
%% Windows. Note that in the demos shown at ICCV, we copied the
%% interest_point files onto our Windows laptops, having run the SIFT
%% descriptor code on Linux machines. 
  
%% Software requirements: Matlab 
%%                        Image Processing toolbox
                          
%%% R.Fergus (fergus@csail.mit.edu) 03/10/05.  
  
%%% run configuration script robustly to get EXPERIMENT_TYPE
%%% this tells if we are doing plsa or a bag or words or a parts and
%%% structure experiment etc.
try
    eval(config_file);
catch
end

if strcmp(EXPERIMENT_TYPE,'plsa')
    
    %%% generate random indices for training and test frames
    do_random_indices(config_file);
    
    %%% copy & resize images into experiment subdir
    do_preprocessing(config_file);
    
    %%% run interest operator over images
    do_interest_operator(config_file);
    
    %%% obtain representation of interest points
    do_representation(config_file);
    
    %%% form appearance codebook
    do_form_codebook(config_file);
    
    %%% VQ appearance of regions
    do_vq(config_file);
    
    %%% run plsa to learn model
    do_plsa(config_file);
    
    %%% test model
    do_plsa_evaluation(config_file);
    
    
elseif strcmp(EXPERIMENT_TYPE,'naive_bayes')
  
    %%% generate random indices for trainig and test frames
    do_random_indices(config_file);
    
    %%% copy & resize images into experiment subdir
    do_preprocessing(config_file);
    
    %%% run interest operator over images
    do_interest_operator(config_file);
    
    %%% obtain representation of interest points
    do_representation(config_file);
    
    %%% form appearance codebook
    do_form_codebook(config_file);
    
    %%% VQ appearance of regions
    do_vq(config_file);
    
    %%% run plsa to learn model
    do_naive_bayes(config_file);
    
    %%% test model
    do_naive_bayes_evaluation(config_file);   

elseif strcmp(EXPERIMENT_TYPE,'parts_structure')
  
    %%% generate random indices for trainig and test frames
    do_random_indices(config_file);
    
    %%% copy & resize images into experiment subdir
    do_preprocessing(config_file);
    
    %%% manually click on training images to build model
    %%% N.B. REQUIRES USER INTERACTION
    do_manual_train_parts_structure(config_file);
    
    %%% run appearance filters from model over the image.
    do_part_filtering(config_file);
    
    %%% evaluate model using interest points
    do_test_parts_structure(config_file);
    
elseif strcmp(EXPERIMENT_TYPE,'parts_structure_efficient')
  
    %%% generate random indices for trainig and test frames
    do_random_indices(config_file);
    
    %%% copy & resize images into experiment subdir
    do_preprocessing(config_file);
    
    %%% manually click on training images to build model
    %%% N.B. REQUIRES USER INTERACTION
    do_manual_train_parts_structure(config_file);
    
    %%% run appearance filters from model over the image.
    do_part_filtering(config_file);
    
    %%% evaluate model using efficient methods of Felzenswalb and Huttenlocher
    do_test_efficient(config_file);

else
    error('Unknown experiment type');
end
    
