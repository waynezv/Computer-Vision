function do_naive_bayes_evaluation(config_file)

%% Test and plot graphs for a naive bayes classifier learnt with do_naive_bayes.m

%% The action of this routine depends on the directory in which it is
%% run: 
%% (a) If run from RUN_DIR, then it will evaluate the latest model in the
%% models subdirectory. i.e. if you have just run
%% do_plsa('config_file_2'), which saved to model_0011.mat and
%% config_file_0011.m in the models subdirectory in RUN_DIR, then doing
%% do_plsa_evaluation('config_file_2') will load up model_0011.mat and
%% evaluate it. 
%% (b) If run within in models subdirectory, then it
%% will evaluate the model corresponding to the configuration file passed
%% to it. i.e. do_plsa_evaluation('config_file_0002') will load
%% model_0002.mat and evaluate/plot figures for it. 
%%  
%% Mode (a) exists to allow a complete experiment to be run from start to
%% finish without having to manually go into the models subdirectory and
%% find the appropriate one to evaluate.
  
%% If this routine is called on a newly learnt model, it will run the pLSA code
%% in folding in mode and then plot lots of figures. If run a second time
%% on the same model, it will only plot the figures, since there is no need
%% to recompute the statistics on the testing images. If you want to force it
%% to re-run on the images, then remove the Pc_d_pos_test variable from the
%% model file. 
  
%% Note this only uses a pre-existing model to evaluate the test
%% images. Please use do_naive_bayes to actually learn the classifiers.  
%% Before running this, you must have run:
%%    do_random_indices - to generate random_indices.mat file.
%%    do_preprocessing - to get the images that the operator will run on.  
%%    do_interest_op  - to get extract interest points (x,y,scale) from each image.
%%    do_representation - to get appearance descriptors of the regions.  
%%    do_vq - vector quantize appearance of the regions in each image.
%%    do_naive_bayes - learn a Naive Bayes classifier.
  
%% R.Fergus (fergus@csail.mit.edu) 03/10/05.  

%% figure numbers to start at
FIGURE_BASE = 2000;
%% color ordering
cols = {'r' 'g' 'b' 'c' 'm' 'y' 'k'};

%% Evaluate global configuration file
eval(config_file);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Model section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% get filename of model to learn
%%% if in models subdirectory then just get index off config_file string
if (strcmp(pwd,[RUN_DIR,'/',Global.Model_Dir_Name]) | strcmp(pwd,[RUN_DIR,'\',Global.Model_Dir_Name]))
    ind = str2num(config_file(end-Global.Num_Zeros+1:end));
else
    %%% otherwise just take newest model in subdir.
    ind = length(dir([RUN_DIR,'/',Global.Model_Dir_Name,'/',Global.Model_File_Name,'*.mat']));    
end
%%% construct model file name
model_fname = [RUN_DIR,'/',Global.Model_Dir_Name,'/',Global.Model_File_Name,prefZeros(ind,Global.Num_Zeros),'.mat'];

%%% load up model
load(model_fname);

%% get +ve interest point file names
pos_ip_file_names = [];
pos_sets = find(Categories.Labels==1);
for a=1:length(pos_sets)
    pos_ip_file_names =  [pos_ip_file_names , genFileNames({Global.Interest_Dir_Name},Categories.Test_Frames{pos_sets(a)},RUN_DIR,Global.Interest_File_Name,'.mat',Global.Num_Zeros)];
end

%% get -ve interest point file names
neg_ip_file_names = [];
neg_sets = find(Categories.Labels==0);
for a=1:length(neg_sets)
    neg_ip_file_names =  [neg_ip_file_names , genFileNames({Global.Interest_Dir_Name},Categories.Test_Frames{neg_sets(a)},RUN_DIR,Global.Interest_File_Name,'.mat',Global.Num_Zeros)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test section - run model on testing images only if Pd_z_test does not exist
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('Pc_d_pos_test') %%% only do this section the first time we look at the model
                       %%% saves time if we just want to look at the pretty
                       %%% figures

%% Create matrix to hold word histograms from +ve images
X_fg = zeros(VQ.Codebook_Size,length(pos_ip_file_names));

%% load up all interest_point files which should have the histogram
%% variable already computed (performed by do_vq routine).
for a=1:length(pos_ip_file_names)
    %% load file
    load(pos_ip_file_names{a});
    %% store histogram
    X_fg(:,a) = histogram';    
end 


%% Create matrix to hold word histograms from +ve images
X_bg = zeros(VQ.Codebook_Size,length(neg_ip_file_names));

%% load up all interest_point files which should have the histogram
%% variable already computed (performed by do_vq routine).
for a=1:length(neg_ip_file_names)
    %% load file
    load(neg_ip_file_names{a});
    %% store histogram
    X_bg(:,a) = histogram';    
end 

%% positive is index 1
%% negitive class is index 2

%%%% do everything in log-space for numerical reasons....

%%% positive model on positive training images
for a=1:length(pos_ip_file_names)
    Pc_d_pos_test(1,a) = log(class_priors(1)) + sum(X_fg(:,a) .* log(Pw_pos)); 
end

%%% negative model on positive training images
for a=1:length(pos_ip_file_names)
    Pc_d_pos_test(2,a) = log(class_priors(2)) + sum(X_fg(:,a) .* log(Pw_neg)); 
end

%%% would normalise Pc_d_pos if it wasn't for serious numerical issues is
%%% VQ.Codebook_Size is large, so just leave unnormalised.

%%% positive model on negative training images
for a=1:length(neg_ip_file_names)
    Pc_d_neg_test(1,a) = log(class_priors(1)) + sum(X_bg(:,a) .* log(Pw_pos)); 
end

%%% negative model on negitive training images
for a=1:length(neg_ip_file_names)
    Pc_d_neg_test(2,a) = log(class_priors(2)) + sum(X_bg(:,a) .* log(Pw_neg)); 
end

%%% would normalise Pc_d_pos if it wasn't for serious numerical issues is
%%% VQ.Codebook_Size is large, so just leave unnormalised.

%%% Compute ROC and RPC on training data
labels = [ones(1,length(pos_ip_file_names)) , zeros(1,length(neg_ip_file_names))];
%%% use ratio of probabilities to avoid numerical issues
values = [Pc_d_pos_test(1,:)-Pc_d_pos_test(2,:) , Pc_d_neg_test(1,:)-Pc_d_neg_test(2,:)];

%%% compute roc
[roc_curve_test,roc_op_test,roc_area_test,roc_threshold_test] = roc([values;labels]');
%%% compute rpc
[rpc_curve_test,rpc_ap_test,rpc_area_test,rpc_threshold_test] = recall_precision_curve([values;labels]',length(pos_ip_file_names));


%%% save variables to file
save(model_fname,'Pc_d_pos_test','Pc_d_neg_test','roc_curve_test','roc_op_test','roc_area_test','roc_threshold_test','rpc_curve_test','rpc_ap_test','rpc_area_test','rpc_threshold_test','-append');
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plotting section - plot some figures to see what is going on...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% We will use figures from FIGURE_BASE to FIGURE_BASE + 4;
%% clear them ready for plotting action...
for a=FIGURE_BASE:FIGURE_BASE+4
    figure(a); clf;
end

%% Now lets look at the classification performance
figure(FIGURE_BASE); hold on;
plot(roc_curve_train(:,1),roc_curve_train(:,2),'r');
plot(roc_curve_test(:,1),roc_curve_test(:,2),'g');
axis([0 1 0 1]); axis square; grid on;
xlabel('P_{fa}'); ylabel('P_d'); title('ROC Curves');
legend('Train','Test');

%% Now lets look at the retrieval performance
figure(FIGURE_BASE+1); hold on;
plot(rpc_curve_train(:,1),rpc_curve_train(:,2),'r');
plot(rpc_curve_test(:,1),rpc_curve_test(:,2),'g');
axis([0 1 0 1]); axis square; grid on;
xlabel('Recall'); ylabel('Precision'); title('RPC Curves');
legend('Train','Test');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Now plot out example images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
labels = [ones(1,length(pos_ip_file_names)) , zeros(1,length(neg_ip_file_names))];
%%% use ratio of probabilities to avoid numerical issues
values = [Pc_d_pos_test(1,:)-Pc_d_pos_test(2,:) , Pc_d_neg_test(1,:)-Pc_d_neg_test(2,:)];

%% first decide on plotting order
if strcmp(Plot.Example_Mode,'ordered')
    %%% just go in orginial order of images
    plot_order = sort(Categories.All_Test_Frames);
elseif strcmp(Plot.Example_Mode,'alternate')
    %%% using random order but alternating between images of different
    %%% classes...
    ind = ones(Categories.Number,max(cellfun('length',Categories.Test_Frames)));
    tmp = length(Categories.Test_Frames{1});
    ind(1,1:tmp)=[1:tmp];
    for a=2:Categories.Number
        tmp = length(Categories.Test_Frames{a});
        offset=sum(cellfun('length',Categories.Test_Frames(1:a-1)));
        ind(a,1:tmp) = [1:tmp]+offset;
   end
   plot_order = ind(:);
   
elseif strcmp(Plot.Example_Mode,'random')
    %%% using order given in random_indices.mat
    plot_order = Categories.All_Test_Frames;
elseif strcmp(Plot.Example_Mode,'best')
    %%% plot ordered by ratio of posteriors, worst first
    [tmp2,plot_order] = sort(-values);
elseif strcmp(Plot.Example_Mode,'worst')
    %%% plot ordered by ratio of posteriors, worst first
    [tmp2,plot_order] = sort(values);    
elseif strcmp(Plot.Example_Mode,'borderline')
    %%% images closest to threshold
    %%% ordering by how close they are to the ROC thresholds...
    [tmp2,plot_order] = sort(abs(values-roc_threshold_train));
else
    error('Unknown type of Plot.Example_Mode');
end 

%% Get image filenames and ip filenames
image_file_names =  genFileNames({Global.Image_Dir_Name},Categories.All_Test_Frames,RUN_DIR,Global.Image_File_Name,Global.Image_Extension,Global.Num_Zeros);
ip_file_names =  genFileNames({Global.Interest_Dir_Name},Categories.All_Test_Frames,RUN_DIR,Global.Interest_File_Name,'.mat',Global.Num_Zeros);
    
%% now setup figure and run loop plotting images
figure(FIGURE_BASE+2);
nImage_Per_Figure = prod(Plot.Number_Per_Figure);

for a=1:nImage_Per_Figure:length(Categories.All_Test_Frames)
    
    clf; %% clear figure
    
    for b=1:nImage_Per_Figure
        
        %%% actual index
        index = plot_order(a+b-1);
        
        %%% get correct subplot
        subplot(Plot.Number_Per_Figure(1),Plot.Number_Per_Figure(2),b);
        
        %%% load image
        im=imread(image_file_names{index});
        
        %%% show image
        imagesc(im); hold on;
        
        %%% if grayscale, then adjust colormap
        if (size(im,3)==1)
            colormap(gray);
        end 
        
        %%% load up interest_point file
        load(ip_file_names{index});
        
        %%% loop over all regions, plotting and coloring according to Pw_z
        for c=1:length(x)
            %%% which topic is favoured by the region?
            [tmp,preferred_class]=max([Pw_pos(descriptor_vq(c)) , Pw_neg(descriptor_vq(c))]);
            %%% plot center of region
            plot(x(c),y(c),'Marker','+','MarkerEdgeColor',cols{rem(preferred_class-1,7)+1});
            %%% and circle showing scale
            drawcircle(y(c),x(c),2*scale(c)+1,cols{rem(preferred_class-1,7)+1},1);
            hold on;    
        end
        
        %%% do we plot header information?
        if (Plot.Labels)
           
            %% Label according to correct/incorrect classification
            %% is image above ROC threshold?
            
            above_threshold = (values(index)>roc_threshold_train);
            
            if (above_threshold==labels(index)) %% Correct classification    
                %% show image number and Pz_d
                title(['Correct - Image: ',num2str(index)]);    
            else
                %% show image number and Pz_d
                title(['INCORRECT - Image: ',num2str(index)]);    
            end
            
            fprintf('Image: %d \t Score: %f \t Threshold: %f\n',index,values(index),roc_threshold_train);
        end
    end
    
    pause
    
end 
