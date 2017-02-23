function do_preprocessing(config_file)
  
%%% Function to copy the raw images for the source directory into the
%%% directory for the experiment and perform various normalizations on them
%%% in the process.  
  
%%% Currently the function normalizes all images to a fixed size
%%% (specificed in Preprocessing.Image_Size) using the axis specified in
%%% Preprocessing.Axis_For_Resizing (either 'x' or 'y'). 

%% Also rescales file containing ground thruth locations of objects
%% within the scene. File name that holds locations of objects is
%% specified in Global.Ground_Truth_Name. The variable in the file 
%% is gt_bounding_boxes which is a 1 x nImages (of that class) cell
%% array, each element holding a 4 x nInstances (per image) matrix, with
%% the bounding box for each instance within the image. The format is:
%% [top_left_x top_left_y width height];
%% (should originally be in subdirectories of IMAGE_DIR, but will be
%%  copied to RUN_DIR by do_preprocessing.m)
  
%%% All images are put into the RUNDIR/Global.Image_Dir_Name directory in one
%%% big collection; i.e. all images from all classes will be in the same directory  
  
%%% R.Fergus (fergus@csail.mit.edu) 8/9/05.  
  
%%% evaluate global configuration file
eval(config_file);

%%% reset frame counter
frame_counter = 1;

%%% make directory in experimental dir. for images
[s,m1,m2]=mkdir(RUN_DIR,Global.Image_Dir_Name);

%%%% Go through each of the categories 
for cat = 1 : Categories.Number
  
  %%% Generate filenames for images
  in_file_names = genFileNames(Categories.Name(cat),Categories.Frame_Range{cat},IMAGE_DIR,Global.Image_File_Name,Global.Image_Extension,Global.Num_Zeros);

  %%% load up gronud truth location file (it exists)
  if (exist([IMAGE_DIR,'/',Categories.Name{cat},'/',Global.Ground_Truth_Name,'.mat']));
    %% load up file
    load([IMAGE_DIR,'/',Categories.Name{cat},'/',Global.Ground_Truth_Name,'.mat']);
    %% copy the variable held in file
    gt_bounding_boxes_original = gt_bounding_boxes;
    clear gt_bounding_boxes; %% clear original
    %% set flag
    location_information_present = 1;    
  else
    location_information_present = 0;
  end
  
  for frame = 1:length(in_file_names)
    
    %%% read image in 
    im = imread(in_file_names{frame});
    
    %%% find out size of image
    [imy,imx,imz] = size(im);
    
    %%% Resize image, proved Preprocessing.Image_Size isn't zero
    %%% in which case, do nothing.
    if (Preprocessing.Image_Size>0)
      
      %%% Figure out scale factor for resizing along appropriate axis
      if strcmp(Preprocessing.Axis_For_Resizing,'x')
        scale_factor = Preprocessing.Image_Size / imx;
      elseif strcmp(Preprocessing.Axis_For_Resizing,'y')
        scale_factor = Preprocessing.Image_Size / imy;     
      else
        error('Unknown axis');
      end
    
      %%% Rescale image using bilinear scaling
      im = imresize(im,scale_factor,Preprocessing.Rescale_Mode);
    else
      scale_factor = 1;
    end
    
    %%% resize ground truth location information
    if (location_information_present)
      gt_bounding_boxes{frame} = gt_bounding_boxes_original{frame} * scale_factor;
    end
    
    %%% Now save out to directory.
    fname = [RUN_DIR,'/',Global.Image_Dir_Name,'/',Global.Image_File_Name,prefZeros(frame_counter,Global.Num_Zeros),Global.Image_Extension];
    imwrite(im,fname,Global.Image_Extension(2:end));
    
    %%% increment frame counter
    frame_counter = frame_counter + 1;
  
    if (mod(frame_counter,10)==0)
      fprintf('.%d',frame_counter);
    end
  
  end

  if (location_information_present)  
    %% Now save rescaled ground truth information to RUNDIR, using class
    %% name as tag (since we mgiht have several classes with gt_location information).
    fn = [RUN_DIR,'/',Global.Ground_Truth_Name,'_',Categories.Name{cat},'.mat'];
    save(fn,'gt_bounding_boxes');
  end
  
  fprintf('\n');
  
end
