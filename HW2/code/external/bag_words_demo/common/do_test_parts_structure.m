function do_test_parts_structure(config_file)
  
%% Function that takes a hand-trained parts and structure model and the
%% interest points produced by running the part templates over the images,
%% and finding the best configuration of them in each image.
  
%% When run on a model for the first time, it compute all evaluation
%% measures and saves to the model file before plotting. If run again on
%% the same model file, it just plots the measures and examples out. To
%% recompute the evaluation measures, do clear_models(<model_number>) in
%% the models subdirectory. Then run this function again and it will
%% recompute everything. 
  
%% Before running this, you must have run:
%%    do_random_indices - to generate random_indices.mat file
%%    do_preprocessing - to get the images that the operator will run on  
%%    do_manual_train_parts_structure - to get the model and part
%%                                      templates.
%%    do_parts_filtering - to get interest points from part templates.
  
%% R.Fergus (fergus@csail.mit.edu) 03/10/05.  

%%% debug switch
DEBUG = 0;

%%% base figure number
FIGURE_BASE = 500;

%%% standard color ordering
cols = {'r.' 'g.' 'b.' 'c.' 'm.' 'y.' 'k.'};
cols2 = {'rx' 'gx' 'bx' 'cx' 'mx' 'yx' 'kx'};
cols3 = {'r' 'g' 'b' 'c' 'm' 'y' 'k'};

%% Evaluate global configuration file
eval(config_file);

%% Get list of file name of input images of positive class only
img_file_names = genFileNames({Global.Image_Dir_Name},[1:Categories.Total_Frames],RUN_DIR,Global.Image_File_Name,Global.Image_Extension,Global.Num_Zeros);

%% Get list of output file names
ip_file_names =  genFileNames({Global.Interest_Dir_Name},[1:Categories.Total_Frames],RUN_DIR,Global.Interest_File_Name,'.mat',Global.Num_Zeros);

%% load up most recent model and take model from it.... 

%%% just take newest model in subdir.
ind = length(dir([RUN_DIR,'/',Global.Model_Dir_Name,'/', Global.Model_File_Name,'*.mat']));    
    
%%% construct model file name
model_fname = [RUN_DIR,'/',Global.Model_Dir_Name,'/',Global.Model_File_Name,prefZeros(ind,Global.Num_Zeros),'.mat'];

%%% load up model
load(model_fname);

%%% Get total number of images
nImages = length(ip_file_names);


if (~exist('best_hypothesis'))

%%% precompute shape density variance
for b=2:Learn.Num_Parts
  determinant_term(b) = -log(shape_var_x(b) * shape_var_y(b) * 2 * pi); 
end

tic;

for i = 1:nImages  
  
  %%% display progress
  if (mod(i,10)==0)
    fprintf('.%d',i);
  end
  
  %%% load up interest files 
  load(ip_file_names{i});
  
  %%% find out how many possible landmarks we have
  nPossible_Landmarks = length(x{1});
  
  %%% find out how many possibilities we have for the non-landmark parts
  for a=1:Learn.Num_Parts
    nPossible(a) = length(x{a});
  end
  
  %%% setup data structure for holding matching costs
  hypothesis = cell(1,Learn.Num_Parts);
  
  %%% reset variables used
  best_hyp = zeros(Learn.Num_Parts,length(x{1}));
  max_per_landmark = zeros(Learn.Num_Parts,length(x{1}));
  
  %%%% REMEMBER THIS IS A TREE-STRUCTURED MODEL, NOT A FULL MODEL....
  %%%% thus we don't need to compare between non-landmark parts...
    
  %%%%% Main loop to try out all possible combinations
  for non_landmark_part = 2:Learn.Num_Parts
    
    %%% setup grid for all possible pairs of landmark, non-landmark part
    %feature allocations
    hypothesis{non_landmark_part} = zeros(nPossible_Landmarks,nPossible(non_landmark_part));
    
    %%% try out different landmarks
    
    for landmark = 1:nPossible_Landmarks
    
      %% position of landmark
      x_ref = x{1}(landmark);
      y_ref = y{1}(landmark);
 
      %% get distance of all points from landmark
      distance_x = x{non_landmark_part} - x_ref;
      distance_y = y{non_landmark_part} - y_ref;

      %% relative to mean of distribution
      x_m = distance_x - shape_mean_x(non_landmark_part);
      y_m = distance_y - shape_mean_y(non_landmark_part);
      
      %%% compute shape probability in log-space
      shape_probab = determinant_term(non_landmark_part) -0.5 * ( ((x_m.^2) * 1/shape_var_x(non_landmark_part)) + ((y_m.^2) * 1/shape_var_y(non_landmark_part)))';
      
      %%% take appearance as just correlation score
      app_probab = score{non_landmark_part};

      if strcmp(Recog.Mode,'shape_and_appearance')
        %% combine shape and appearance scores
        hypothesis{non_landmark_part}(landmark,:) = shape_probab + app_probab * Recog.Shape_Appearance_Weighting;
      elseif strcmp(Recog.Mode,'appearance_only')
        hypothesis{non_landmark_part}(landmark,:) = app_probab; 
      elseif strcmp(Recog.Mode,'shape_only')
        hypothesis{non_landmark_part}(landmark,:) = shape_probab;
      else
        error('Unknown mode');
      end
      
      %%%% Now find maximum for each landmark
      [best_score,best_hyp(non_landmark_part,landmark)] = max(hypothesis{non_landmark_part}(landmark,:));
      max_per_landmark(non_landmark_part,landmark) = best_score;
      
    end %% landmark feature loop
    
  end %% part loop

  if ~strcmp(Recog.Mode,'shape_only')
    %%% add in appearance of landmark 
    max_per_landmark(1,:) = score{1} * Recog.Shape_Appearance_Weighting; 
  end
  
  %%% find best landmark
  [best_overall_score(i),best_landmark] = max(sum(max_per_landmark));
  
  %%% now find best non-landmark part allocations for this landmark
  best_hypothesis(:,i) = best_hyp(:,best_landmark);
  
  %% fill in landmark
  best_hypothesis(1,i) = best_landmark;

  %% compute bounding box of best hypothesis for localization measure
  %% get locations in the image
  for b=1:Learn.Num_Parts
    xx(b) = x{b}(best_hypothesis(b,i));
    yy(b) = y{b}(best_hypothesis(b,i));
  end
  %% now find min and max x and y
  x_min = min(xx);
  y_min = min(yy);
  x_max = max(xx);
  y_max = max(yy);
  %% now compute bounding rectangle
  bounding_box{i} = round([x_min,y_min,x_max-x_min,y_max-y_min])';
  
  
  if DEBUG
    %%% load image
    im=imread(img_file_names{i});
    
    %%% show image
    figure(FIGURE_BASE-1); clf;
    imagesc(rgb2gray(im)); colormap(gray); hold on;
    
    %%% plot features
    for b=1:Learn.Num_Parts
      plot(x{b},y{b},cols{b});
    end
    
    %%% now mark in best hypothesis
    for b=1:Learn.Num_Parts
      plot(x{b}(best_hypothesis(b,i)),y{b}(best_hypothesis(b,i)),cols2{b},'Markersize',20,'Linewidth',8);
    end
   
    title(['Image: ',num2str(i),' Best match score: ',num2str(best_overall_score(i))]);
    
    pause
    
  end
  
  
end

total_time=toc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Compute some performance metrics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% get labels for test frames
labels = zeros(1,Categories.Total_Frames);
for a=1:Categories.Number
  labels(Categories.Test_Frames{a}) = [Categories.Labels(a)*ones(1,length(Categories.Test_Frames{a}))];
end

%%% now get scores of test images
values = -Inf * ones(1,Categories.Total_Frames);
for a=1:Categories.Number
  values(Categories.Test_Frames{a}) = best_overall_score(Categories.Test_Frames{a});
end

%%% since all training images are given -Inf score, weed out to avoid
%%% skewing ROC curve
good_ind = find(~isinf(values));
values2 = values(good_ind); labels2 = labels(good_ind);

%%% Now compute object present/absent peformance using ROC curve
[roc_curve,roc_op,roc_area,roc_threshold] = roc([values2;labels2]');

%%% Now do localization performance. This will be measured only on +ve
%categories, since all proposed detections on -ve data are definately
%false alarms. Note that the ground_truth_locations_{category_name} files
%produced by do_preprocessing.m must exist in RUN_DIR.
%% load up 

%%% first rescale proposed bounding box...
for a=1:length(bounding_box)

  %%% Enlarge proposed bounding box by Recog.Manual_Bounding_Box_Scaling
  %%% first get centroid
  centroid_x = bounding_box{a}(1,:) + bounding_box{a}(3,:)/2;
  centroid_y = bounding_box{a}(2,:) + bounding_box{a}(4,:)/2;   
  
  %%% repoistion new top left corner
  bounding_box{a}(1,:) = centroid_x - bounding_box{a}(3,:)/2*Recog.Manual_Bounding_Box_Scaling;
  bounding_box{a}(2,:) = centroid_y - bounding_box{a}(4,:)/2*Recog.Manual_Bounding_Box_Scaling;
  
  %%% adjust width and height
  bounding_box{a}(3,:) = bounding_box{a}(3,:) * Recog.Manual_Bounding_Box_Scaling;
  bounding_box{a}(4,:) = bounding_box{a}(4,:) * Recog.Manual_Bounding_Box_Scaling;    
    
end

localization_labels = zeros(1,Categories.Total_Frames);
gt_boxes = cell(1,Categories.Total_Frames);

total_number_instances = 0;
for a=1:Categories.Number
  if (Categories.Labels(a)==1)
    fname = [RUN_DIR,'/',Global.Ground_Truth_Name,'_',Categories.Name{a},'.mat'];
    if (exist(fname))
      load(fname);
      
      %%% get relavent boxes
      gt_boxes(Categories.Test_Frames{a}) = gt_bounding_boxes(:,Categories.Test_Frames{a});
       
      %%% record total number of instances
      total_number_instances = total_number_instances + sum(cellfun('size',gt_boxes,2));
    else
      error([fname,' does not exist']);
    end
    
    %% find correct localizations
    localization_labels(Categories.Test_Frames{a}) = test_localization(gt_boxes(Categories.Test_Frames{a}),bounding_box(Categories.Test_Frames{a}),Recog);

  else
    %% all putative detection on negatively labelled images are
    %% automatically false alarms....
     
    localization_labels(Categories.Test_Frames{a}) = zeros(1,length(Categories.Test_Frames{a}));
    
  end 
end

%% Now compute recall_prescision curve
[rpc_curve,rpc_ap,rpc_area,rpc_threshold] = recall_precision_curve([values;localization_labels]',total_number_instances);

%%% Now save to model
save(model_fname,'best_hypothesis','best_overall_score','bounding_box','gt_boxes','roc_curve','roc_area','roc_op','roc_threshold','rpc_curve','rpc_ap','rpc_area','rpc_threshold','values','localization_labels','labels','-append');


fprintf('\nFinished running parts and structure model over images\n');
fprintf('Total number of images: %d, mean time per image: %f secs\n',Categories.Total_Frames,total_time/Categories.Total_Frames);


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plotting section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% We will use figures from FIGURE_BASE to FIGURE_BASE + 4;
%% clear them ready for plotting action...
for a=FIGURE_BASE:FIGURE_BASE+2
    figure(a); hold on;% clf;
end

figure(FIGURE_BASE);
%%% get number of existing plots...
q=get(FIGURE_BASE,'UserData');
if isempty(q)
  plot(roc_curve(:,1),roc_curve(:,2),cols3{1}); hold on;
  set(FIGURE_BASE,'UserData',1);
else
  plot(roc_curve(:,1),roc_curve(:,2),cols3{rem(q-2,7)+2}); hold on;
  set(FIGURE_BASE,'UserData',q+1);
end 
axis([0 1 0 1]); axis square; grid on;
xlabel('P_{fa}'); ylabel('P_d'); title(['ROC Curve, Area: ',num2str(roc_area),' OpP: ',num2str(roc_op)]);

figure(FIGURE_BASE+1);
q=get(FIGURE_BASE+1,'UserData');
if isempty(q)
  plot(rpc_curve(:,1),rpc_curve(:,2),cols3{1}); hold on;
  set(FIGURE_BASE+1,'UserData',1);
else
  plot(rpc_curve(:,1),rpc_curve(:,2),cols3{rem(q-2,7)+2}); hold on;
  set(FIGURE_BASE+1,'UserData',q+1);
end
axis([0 1 0 1]); axis square; grid on;
xlabel('Recall'); ylabel('Precision'); title('RPC Curves');

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
   plot_order =  Categories.All_Test_Frames(ind(:)); 
elseif strcmp(Plot.Example_Mode,'random')
    %%% using order given in random_indices.mat
    plot_order = Categories.All_Test_Frames;
elseif strcmp(Plot.Example_Mode,'best')
    %%% plot ordered by score 
    [tmp2,ind] =(sort(-best_overall_score(Categories.All_Test_Frames)));
    plot_order =  Categories.All_Test_Frames(ind);
elseif strcmp(Plot.Example_Mode,'worst')
    %%% plot ordered by score on worst topic
    [tmp2,ind] =(sort(best_overall_score(Categories.All_Test_Frames)));
    plot_order =  Categories.All_Test_Frames(ind);    
elseif strcmp(Plot.Example_Mode,'borderline')
    %%% ordering by how close they are to the topic_thresholds...
    [tmp2,ind] = sort(abs(best_overall_score(Categories.All_Test_Frames)-roc_threshold));
    plot_order =  Categories.All_Test_Frames(ind);  
else
    error('Unknown type of Plot.Example_Mode');
end 

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
        im=imread(img_file_names{index});
        
        %%% show image
        imagesc(im); hold on;
        
        %%% if grayscale, then adjust colormap
        if (size(im,3)==1)
            colormap(gray);
        end 
        
        %%% load up interest_point file
        load(ip_file_names{index});

        %%% plot features
        for b=1:Learn.Num_Parts
          plot(x{b},y{b},cols{b});
        end
        
        %%% now mark in best hypothesis
        for b=1:Learn.Num_Parts
          plot(x{b}(best_hypothesis(b,index)),y{b}(best_hypothesis(b,index)),cols2{b},'Markersize',20,'Linewidth',8);
        end

        
        if (~isempty(gt_boxes{index}))
          %%% show ground_truth bounding box
          rectangle('Position',gt_boxes{index},'EdgeColor','b','Linewidth',2);
          
          if (localization_labels(index)==1)
            %% correct localization
            rectangle('Position',bounding_box{index},'EdgeColor','g','Linewidth',2);
          else
            %% incorrect
            rectangle('Position',bounding_box{index},'EdgeColor','r','Linewidth',2);
          end
        end
        
        h=title(['Image: ',num2str(index),' Best match score: ',num2str(best_overall_score(index))]);
        if (labels(index)==1)
          set(h,'Color','g');
        else
          set(h,'Color','r');          
        end
        
    end
    
    pause
    
end 
