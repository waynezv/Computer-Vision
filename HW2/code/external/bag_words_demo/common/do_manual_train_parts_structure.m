function do_manual_train_parts_structure(config_file)
  
%% Function that lets the user manually click on parts of the
%objects. The number of clicks per image is determined by the number of
%parts in the model, which is in turn set by the Learn.Num_Parts
%parameter. The scale of the regions picked out by each click (shown by
%the red square) is given in Interest_Points.Scale, which should be a
%single value.
  
% The model will use the first clicked point as a landmark, which all the
% other will be measured relative to. The position of all the other parts
% is assumed to be conditionally independent, given the landmark. Thus
% the model is a tree structured graphical model, of depth 1. Gaussian
% distributions are used to model the location of each part relative to
% the landmark. 

%% Note that the model learnt is only translation invariant. It is not
%scale or rotation etc. invariant at all. Feel free to upgrade it!!!  
  
% For the appearance, the artimetic mean of the raw pixels intensities of
% each part over all images is taken to be the filter that will be used
% by do_parts_filtering.m routine.     
  
%% Note that this only trains a model. It does not evaluate any test
%% images. Use do_plsa_evaluation for that.  
  
%% Before running this, you must have run:
%%    do_random_indices - to generate random_indices.mat file
%%    do_preprocessing - to get the images that the operator will run on  

%% R.Fergus (fergus@csail.mit.edu) 03/10/05.  

  
%%% debugging switch
DEBUG = 1;  
  
%%% figure to use for presenting images to the user for clicking  
TEMP_FIGURE_NUM = 999;  

%%% standard color ordering
cols = {'r' 'g' 'b' 'c' 'm' 'y' 'k'};

%% Evaluate global configuration file
eval(config_file);

%% ensure models subdir is present
[s,m1,m2] = mkdir(RUN_DIR,Global.Model_Dir_Name);

%% Which classes are positive
pos_class_ind = find(Categories.Labels);

%% indices of images belonging to positive class
pos_image_ind = cat(2,Categories.Train_Frames{pos_class_ind});

%% Get list of file name of input images of positive class only
img_file_names = genFileNames({Global.Image_Dir_Name},pos_image_ind,RUN_DIR,Global.Image_File_Name,Global.Image_Extension,Global.Num_Zeros);

%% show instuctions...
fprintf('\nA total of %d images selected for training\n',length(img_file_names));
fprintf('\nPlease select %d points per image.\n',Learn.Num_Parts);
fprintf('Left mouse button selects; Right mouse button deletes previous click\n',Learn.Num_Parts);

%% prepare cell array to hold all clicked regions
part = cell(1,Learn.Num_Parts);

%%% Check that we have a constant scale supplied for features (manual
%scale selection not yet implemented)
if (length(Interest_Point.Scale)>1)
  error('Multi-scale feature selection not currently implemented. Set Interest_Point.Scale to be a single number not a vector.');
end

%%% Width and height of features
width = Interest_Point.Scale * 2;
height = width; %%% square region

for a = 1:length(img_file_names)

  %%% get figur up and clear it
  figure(TEMP_FIGURE_NUM); clf;
  
  %%% read in image
  im = imread(img_file_names{a});
  
  %%% get size
  [imy,imx,imz] = size(im);
  
  %%% show it 
  imagesc(im); hold on; axis('equal');

  %%% if grayscale image then change colormap
  if (imz==1)
    colormap(gray);
    im_gray = im;
  else
    %%% get grayscale version
    im_gray = rgb2gray(im);
  end
  
  %%% put up image number
  title(['Image: ',num2str(a)]);
 
  %%% now get user input
  num_clicked = 1;
  
  fprintf('Image: %d, choose point ',a);

  while(num_clicked<=Learn.Num_Parts)
    
    fprintf('%d ',num_clicked);
    [x(num_clicked),y(num_clicked),b] = ginput(1);
    
    if (b==1) %%% left button
      
      %%% show clicked point
      plot(x(num_clicked),y(num_clicked),'r.');
    
      %%% get rectangle
      rect = [x(num_clicked)-width/2 y(num_clicked)-height/2 width-1 height-1];
      
      %%% show rectangle
      rectangle('Position',rect,'EdgeColor','r');
      
      %%% increment number of clicks
      num_clicked = num_clicked+1;
 
    elseif (b==3) %%% right
      %%% correct previous point (overwrite in black)
      if (num_clicked>1)
        fprintf('Correcting point: %d\n',num_clicked);
   
        %%% overwrite red dot with black one
        plot(x(num_clicked-1),y(num_clicked-1),'k.');
        
        %%% get rectangle
        rect = [x(num_clicked-1)-width/2 y(num_clicked-1)-height/2 width-1 height-1];
      
        %%% show rectangle
        rectangle('Position',rect,'EdgeColor','k');
        
        %%% decrease clicks
        num_clicked = num_clicked-1;
      end
      
    else
      %%% middle not used
    end

    %%% tiny pause to prevent accidental double-clicks on the same point
    pause(0.05);
    
  end
  
  fprintf('\n');
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ok, we now have user clicked points for the image in x and y
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %%% Now crop regions at fixed scale, set by mean of Interest_Point.Scale.
    
  for b=1:Learn.Num_Parts
    
    %%% get rectangle
    rect = [x(b)-width/2 y(b)-height/2 width-1 height-1];
    
    %%% crop rectangle from image
    p = imcrop(im_gray,rect);
 
    %%% store raw pixels in matrix
    part{b}(:,a) = p(:);
     
  end
  
  %%% Store relative configuration of points, using 1st click as a
  %%% landmark
  shape_x(:,a) = [x-x(1)]';
  shape_y(:,a) = [y-y(1)]';

  %%% store hand clicked locations for posterity....
  hand_clicks_x(:,a) = x';
  hand_clicks_y(:,a) = y';
  
end %%% end of loop over all images

%%% Now find average appearance by averaging over pixel values of all
%%% hand-clicked instances

for c=1:Learn.Num_Parts
  part_filter(:,c) = mean(part{c},2);
end

%%% Now get distribution on shape
shape_mean_x = mean(shape_x,2);
shape_mean_y = mean(shape_y,2);
shape_var_x  = var(shape_x')';
shape_var_y  = var(shape_y')';
  
if DEBUG
  %%% Plot out model
  
  %%% show part filters
  figure(TEMP_FIGURE_NUM+1);
  for a=1:Learn.Num_Parts
    subplot(1,Learn.Num_Parts,a);
    imagesc(reshape(part_filter(:,a),[width height]));
    colormap(gray); axis('equal');
    title(['Filter ',num2str(a)]);
  end
  
  %%% show relative location model
  figure(TEMP_FIGURE_NUM+2); axis('ij'); axis('square'); hold on;
  for a=1:Learn.Num_Parts
    plot(shape_mean_x(a),shape_mean_y(a),cols{a},'Marker','+');
    if (a>1) %% only show ellipses for non-landmark parts
      [ph,cy,L,l,th] = draw_ellipse([shape_mean_x(a);shape_mean_y(a)],diag([shape_var_x(a);shape_var_y(a)]),cols{a},2,[]);
    end
  end
  title('Relative location model');
  
end


%%%% now store everything: the model, the templates, the hand-clicked locations....
[fname,model_ind] = get_new_model_name([RUN_DIR,'/',Global.Model_Dir_Name],Global.Num_Zeros);

%%% save variables to file
save(fname,'shape_mean_x','shape_mean_y','shape_var_x','shape_var_y','part_filter','hand_clicks_x','hand_clicks_y','part');

%%% copy conf_file into models directory too..
config_fname = which(config_file);
copyfile(config_fname,[RUN_DIR,'/',Global.Model_Dir_Name,'/',Global.Config_File_Name,prefZeros(model_ind,Global.Num_Zeros),'.m']);
