function do_plsa(config_file)

%% Function that runs the pLSA learning procedure, calling code written
%% by Josef Sivic (josef@robots.ox.ac.uk), based on the paper:
%% 
%%  J. Sivic, B. C. Russell, A. Efros, A. Zisserman and W. T. Freeman,
%%  Discovering objects and their location in images, ICCV 2005.
%%  http://www.robots.ox.ac.uk/~vgg/publications/papers/sivic05b.pdf
  
%% Starts with random initialisation and saves the learnt model
%% into a file in the models/ subdirectory within RUNDIR, along with a
%% copy of the configuration file holding all experment settings.

%% Note that this only trains a model. It does not evaluate any test
%% images. Use do_plsa_evaluation for that.  
  
%% Before running this, you must have run:
%%    do_random_indices - to generate random_indices.mat file
%%    do_preprocessing - to get the images that the operator will run on  
%%    do_interest_op  - to get extract interest points (x,y,scale) from each image
%%    do_representation - to get appearance descriptors of the regions  
%%    do_vq - vector quantize appearance of the regions
  
%% R.Fergus (fergus@csail.mit.edu) 03/10/05.  
 
    
%% Evaluate global configuration file
eval(config_file);

%% ensure models subdir is present
[s,m1,m2]=mkdir(RUN_DIR,Global.Model_Dir_Name);

%% get all file names of training image interest point files.
ip_file_names =  genFileNames({Global.Interest_Dir_Name},Categories.All_Train_Frames,RUN_DIR,Global.Interest_File_Name,'.mat',Global.Num_Zeros);

%% Create matrix to hold word histograms from all images
X = zeros(VQ.Codebook_Size,length(Categories.All_Train_Frames));

%% load up all interest_point files which should have the histogram
%% variable already computed (performed by do_vq routine).
for a=1:length(ip_file_names)
    %% load file
    load(ip_file_names{a});
    %% store histogram
    X(:,a) = histogram';    
end 

%%% Call actual EM routine....
[Pw_z,Pd_z,Pz,Li] = pLSA_EM(X,[],Learn.Num_Topics,Learn);

%%% Now save model out to file
[fname,model_ind] = get_new_model_name([RUN_DIR,'/',Global.Model_Dir_Name],Global.Num_Zeros);

%%% save variables to file
save(fname,'Pw_z','Pd_z','Pz','Li');

%%% copy conf_file into models directory too..
config_fname = which(config_file);
copyfile(config_fname,[RUN_DIR,'/',Global.Model_Dir_Name,'/',Global.Config_File_Name,prefZeros(model_ind,Global.Num_Zeros),'.m']);
