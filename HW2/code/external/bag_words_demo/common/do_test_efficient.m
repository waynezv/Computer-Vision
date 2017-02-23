function do_test_efficient(config_file)
  
 %% Function that takes a hand-trained parts and structure model and the
%% interest points produced by running the part templates over the images,
%% and finding the best configuration of them in each image.

%% Based on method in the paper:
%% Felzenszwalb, P. and Huttenlocher, D. "Pictorial Structures for Object
%% Recognition", Intl. Journal of Computer Vision, 61(1), pp. 55-79, January 2005.    
    
%% Does this for all images and then plots training and test separately.  
  
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
BASE_FIG_NUM = 500;

%%% standard color ordering
cols = {'r.' 'g.' 'b.' 'c.' 'm.' 'y.' 'k.'};
cols2 = {'rx' 'gx' 'bx' 'cx' 'mx' 'yx' 'kx'};
cols3 = {'ro' 'go' 'bo' 'co' 'mo' 'yo' 'ko'};
cols4 = {'r' 'g' 'b' 'c' 'm' 'y' 'k'};

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
model_fname = [RUN_DIR,'/',Global.Model_Dir_Name,'/',Global.Model_File_Name,prefZeros(ind,Global.Num_Zeros),'.mat']

%%% load up model
load(model_fname);

%%% Get total number of images
nImages = length(ip_file_names);

%%% get # parts
nParts = Learn.Num_Parts;

if (~exist('bounding_box_efficient'))

%%% precompute shape density variance
for b=2:Learn.Num_Parts
  determinant_term(b) = -log(shape_var_x(b) * shape_var_y(b) * 2 * pi); 
end

%%% round means to integer values
shape_mean_x = round(shape_mean_x);
shape_mean_y = round(shape_mean_y);

%%% get absolute values of means
abs_mean_x = abs(shape_mean_x);
abs_mean_y = abs(shape_mean_y);


tic;

for i = 1:nImages  
  
  %%% display progress
  if (mod(i,10)==0)
    fprintf('.%d',i);
  end
  
  %%% load up interest files 
  load(ip_file_names{i});
    
  %%% get size of response_image
  [imy,imx,tmp] = size(response_image);
  
  %%% setup variables
  overall_resp = zeros(imy,imx);
  part_resp = zeros(imy,imx,nParts-1);
  locations = cell(1,nParts-1);

  for p=2:Learn.Num_Parts
    
     %% Pad response_image with v.large costs (not Inf since it screws up
     %% dist_transform_1d function). This is designed to ensure we don't
     %% run out of image when we translate it 
	    
     %% Also: (a) scale Appearance costs, giving weighting between shape and
     %% appearance, and (b) negate everything since for distance transform, low is
     %% good but probability map has good being high values_efficient
     padded_response_image = padarray(-Recog.Shape_Appearance_Weighting*response_image(:,:,p),[abs_mean_y(p) abs_mean_x(p)],1e200,'both');                      
	   
     %%% translate response image by mean of that part relative to the
     %%% landmark
     translated_response = padded_response_image([abs_mean_y(p)+shape_mean_y(p)+1:imy+(abs_mean_y(p)+shape_mean_y(p))],[abs_mean_x(p)+shape_mean_x(p)+1:imx+(abs_mean_x(p)+shape_mean_x(p))]);
     
     %%% Now do distance transform, using variance as multiplication factor.
     [part_resp(:,:,p-1),locations{p-1}] = dist_transform(translated_response,shape_var_x(p),shape_var_y(p));
	 
 
  end

  %% Now add in landmark response to sum of all other parts...
  overall_resp = (-Recog.Shape_Appearance_Weighting * response_image(:,:,1)) + sum(part_resp,3);

  %% Find minimum overall 
  [min_score,landmark_pos] = min(overall_resp(:));
  
  %% Get landmark x,y location
  [landmark_y, landmark_x] = ind2sub([imy imx],landmark_pos);

  %% Get locations of other parts...
  for p = 2:nParts
    part_x(p-1) = locations{p-1}(landmark_y,landmark_x,1);
    part_y(p-1) = locations{p-1}(landmark_y,landmark_x,2);
  end
	 
  %%% Overall best locations....
  best_x = [landmark_x,part_x+shape_mean_x(2:end)'];
  best_y = [landmark_y,part_y+shape_mean_y(2:end)'];
  
  %%% plot stufff
  if DEBUG
    

    figure(BASE_FIG_NUM); clf;
    im = imread(img_file_names{i});
    imagesc(im); hold on;
%   
    for p=1:nParts
      plot(best_x(p),best_y(p),cols{p},'Markersize',20,'Linewidth',5);
    end
    
    figure(BASE_FIG_NUM+1); clf;
    %%% landmark response
    subplot(2,nParts,nParts+1);
    imagesc(-overall_resp); caxis([-1 1]*Recog.Shape_Appearance_Weighting);
    hold on; title('Overall probab.');
    plot(landmark_x,landmark_y,'wx','Markersize',20,'Linewidth',5);
  
    %%% get best overall reponse
    q = -response_image(:,:,1);
    [tmp,pos] = min(q(:));
    [yy,xx] = ind2sub([imy imx],pos);
   % plot(xx,yy,'ko','Markersize',20,'Linewidth',5);
    colorbar;
    
    subplot(2,nParts,1);
    imagesc(response_image(:,:,1)); caxis([-1 1]); colorbar;
    title(['Appearance probab., part 1']); hold on;
    plot(xx,yy,'ko','Markersize',20,'Linewidth',5);
    
    %%% non-landmark parts
    for p=2:nParts
    %%% get best overall reponse

      q = -response_image(:,:,p);
      [tmp,pos] = min(q(:));
      [yy,xx] = ind2sub([imy imx],pos);
   
      subplot(2,nParts,nParts+p)
      imagesc(-part_resp(:,:,p-1)); hold on; caxis([-1 1]*Recog.Shape_Appearance_Weighting); colorbar;      
      plot(part_x,part_y,'wx','Markersize',20,'Linewidth',5);
      plot(xx-shape_mean_x(p),yy-shape_mean_y(p),'ko','Markersize',20,'Linewidth',5);
      title(['Distance transformed part ',num2str(p)]);
      subplot(2,nParts,p);
      imagesc(response_image(:,:,p)); hold on; caxis([-1 1]); colorbar;
      plot(xx,yy,'ko','Markersize',20,'Linewidth',5);
      title(['Appearance probab., part ',num2str(p)]);
    end

    %%% plot best 

    pause
  end

  
  %%% Collect statistics for plotting and ROC and RPC curves
  best_locations_x(:,i) = best_x';
  best_locations_y(:,i) = best_y';
  
  %% now find min and max x and y
  x_min = min(best_x);
  y_min = min(best_y);
  x_max = max(best_x);
  y_max = max(best_y);
  %% now compute bounding rectangle
  bounding_box_efficient{i} = round([x_min,y_min,x_max-x_min,y_max-y_min])';
  %% get score..
  best_overall_score_efficient(i) = -min_score; %% negate to turn cost back into probability... 
  
end

total_time=toc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Compute some performance metrics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% get labels for test frames
labels_efficient = zeros(1,Categories.Total_Frames);
for a=1:Categories.Number
  labels_efficient(Categories.Test_Frames{a}) = [Categories.Labels(a)*ones(1,length(Categories.Test_Frames{a}))];
end

%%% now get scores of test images
values_efficient = -Inf * ones(1,Categories.Total_Frames);
for a=1:Categories.Number
  values_efficient(Categories.Test_Frames{a}) = best_overall_score_efficient(Categories.Test_Frames{a});
end

%%% since all training images are given -Inf score, weed out to avoid
%%% skewing ROC curve
good_ind = find(~isinf(values_efficient));
values_efficient2 = values_efficient(good_ind); labels_efficient2 = labels_efficient(good_ind);

%%% Now compute object present/absent peformance using ROC curve
[roc_curve_efficient,roc_op_efficient,roc_area_efficient,roc_threshold_efficient] = roc([values_efficient2;labels_efficient2]');

%%% Now do localization performance. This will be measured only on +ve
%categories, since all proposed detections on -ve data are definately
%false alarms. Note that the ground_truth_locations_{category_name} files
%produced by do_preprocessing.m must exist in RUN_DIR.
%% load up 

%%% first rescale proposed bounding box...
for a=1:length(bounding_box_efficient)

  %%% Enlarge proposed bounding box by Recog.Manual_Bounding_Box_Efficient_Scaling
  %%% first get centroid
  centroid_x = bounding_box_efficient{a}(1,:) + bounding_box_efficient{a}(3,:)/2;
  centroid_y = bounding_box_efficient{a}(2,:) + bounding_box_efficient{a}(4,:)/2;   
  
  %%% repoistion new top left corner
  bounding_box_efficient{a}(1,:) = centroid_x - bounding_box_efficient{a}(3,:)/2*Recog.Manual_Bounding_Box_Scaling;
  bounding_box_efficient{a}(2,:) = centroid_y - bounding_box_efficient{a}(4,:)/2*Recog.Manual_Bounding_Box_Scaling;
  
  %%% adjust width and height
  bounding_box_efficient{a}(3,:) = bounding_box_efficient{a}(3,:) * Recog.Manual_Bounding_Box_Scaling;
  bounding_box_efficient{a}(4,:) = bounding_box_efficient{a}(4,:) * Recog.Manual_Bounding_Box_Scaling;    
    
end

localization_labels_efficient = zeros(1,Categories.Total_Frames);
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
    localization_labels_efficient(Categories.Test_Frames{a}) = test_localization(gt_boxes(Categories.Test_Frames{a}),bounding_box_efficient(Categories.Test_Frames{a}),Recog);

  else
    %% all putative detection on negatively labelled images are
    %% automatically false alarms....
     
    localization_labels_efficient(Categories.Test_Frames{a}) = zeros(1,length(Categories.Test_Frames{a}));
    
  end 
end

%% Now compute recall_prescision curve
[rpc_curve_efficient,rpc_ap_efficient,rpc_area_efficient,rpc_threshold_efficient] = recall_precision_curve([values_efficient;localization_labels_efficient]',total_number_instances);

%%% Now save to model
save(model_fname,'best_locations_x','best_locations_y','best_overall_score_efficient','bounding_box_efficient','gt_boxes','roc_curve_efficient','roc_area_efficient','roc_op_efficient','roc_threshold_efficient','rpc_curve_efficient','rpc_ap_efficient','rpc_area_efficient','rpc_threshold_efficient','values_efficient','localization_labels_efficient','labels_efficient','-append');


fprintf('\nFinished running parts and structure model, using efficient methods, over images\n');
fprintf('Total number of images: %d, mean time per image: %f secs\n',Categories.Total_Frames,total_time/Categories.Total_Frames);




end %% end of computing results section

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plotting section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% We will use figures from FIGURE_BASE to FIGURE_BASE + 4;
%% clear them ready for plotting action...
for a=BASE_FIG_NUM:BASE_FIG_NUM+2
    figure(a); %clf;
end

figure(BASE_FIG_NUM);
q=get(BASE_FIG_NUM,'UserData');
if isempty(q)
  plot(roc_curve_efficient(:,1),roc_curve_efficient(:,2),cols4{1}); hold on;
  set(BASE_FIG_NUM,'UserData',1);
else
  q=q+1;
  plot(roc_curve_efficient(:,1),roc_curve_efficient(:,2),cols4{rem(q-1,7)+1}); hold on;
  set(BASE_FIG_NUM,'UserData',q);
end
axis([0 1 0 1]); axis square; grid on;
xlabel('P_{fa}'); ylabel('P_d'); title(['ROC Curve, Area: ',num2str(roc_area_efficient),' OpP: ',num2str(roc_op_efficient)]);

figure(BASE_FIG_NUM+1);
q=get(BASE_FIG_NUM+1,'UserData');
if isempty(q)
  plot(rpc_curve_efficient(:,1),rpc_curve_efficient(:,2),cols4{1}); hold on;  
  set(BASE_FIG_NUM+1,'UserData',1);
else
  q=q+1;
  plot(rpc_curve_efficient(:,1),rpc_curve_efficient(:,2),cols4{rem(q-1,7)+1}); hold on;
  set(BASE_FIG_NUM+1,'UserData',q);
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
    [tmp2,ind] =(sort(-best_overall_score_efficient(Categories.All_Test_Frames)));
    plot_order =  Categories.All_Test_Frames(ind);
elseif strcmp(Plot.Example_Mode,'worst')
    %%% plot ordered by score on worst topic
    [tmp2,ind] =(sort(best_overall_score_efficient(Categories.All_Test_Frames)));
    plot_order =  Categories.All_Test_Frames(ind);    
elseif strcmp(Plot.Example_Mode,'borderline')
    %%% ordering by how close they are to the topic_thresholds...
    [tmp2,ind] = sort(abs(best_overall_score_efficient(Categories.All_Test_Frames)-roc_threshold_efficient));
    plot_order =  Categories.All_Test_Frames(ind);  
else
    error('Unknown type of Plot.Example_Mode');
end 

%% now setup figure and run loop plotting images
figure(BASE_FIG_NUM+2);
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
        
        %%% now mark in best hypothesis
        for b=1:Learn.Num_Parts
          plot(best_locations_x(b,index),best_locations_y(b,index),cols2{b},'Markersize',20,'Linewidth',8);
        end

        
        if (~isempty(gt_boxes{index}))
          %%% show ground_truth bounding box
          rectangle('Position',gt_boxes{index},'EdgeColor','b','Linewidth',2);
          
          if (localization_labels_efficient(index)==1)
            %% correct localization
            rectangle('Position',bounding_box_efficient{index},'EdgeColor','g','Linewidth',2);
          else
            %% incorrect
            rectangle('Position',bounding_box_efficient{index},'EdgeColor','r','Linewidth',2);
          end
        end
        
        h=title(['Image: ',num2str(index),' Best match score: ',num2str(best_overall_score_efficient(index))]);
        if (labels_efficient(index)==1)
          set(h,'Color','g');
        else
          set(h,'Color','r');          
        end
        
    end
    
    pause
    
end 
