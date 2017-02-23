function hits=test_localization(ground_truth_boxes,bounding_boxes,Recog)
  
%% Does localization test
  
%% Inputs - 1. ground_truth_boxes - cell array of dim. 1 x number of
%% positive test frames, each element being 4 x nInstances in that image.
%% The 4 elements are [top_left_x top_left_y width height] of bounding box.
%%          Holds the true locations of each object within the frames. 
%%          2. bounding_boxes - cell array of dim. 1 x number of
%% positive test frames, each element being 4 x nInstances in that image
%% The 4 elements are [top_left_x top_left_y width height] of bounding box.
%% Holds the output of the detector.
%%          3. Recog - structure from the config_file holding settings
%% for recognition. Fields used include Recog.Localization_Criterion and   
%% Recog.Localization_Threshold.
  
%% Output - 1. Hits - binary vector of 1 x nImages recording correct hit
%% or not...  
  
%% for simplicity it just assumes only one instance per frame
%% please do upgrade it to handle multiple if you want to.....
  
%% R.Fergus (fergus@csail.mit.edu) 03/10/05.  
  
  
%% how many frames
nImages = size(bounding_boxes,2);

%% counter for frame with bounding box info
counter = 1;

for i = 1:nImages

  if (~isempty(ground_truth_boxes{i}))
  if strcmp(Recog.Localization_Criterion,'overlap_intersect')
    
    %%% Criterion used in PASCAL evaluation
    %%% http://www.pascal-network.org/challenges/VOC/
    
    %%% measures ratio of (overlap btw. ground truth and proposed bounding
    %boxes) to (union of ground truth and proposed bounding
    %boxes) 
    
    %% use visual method (assume integer rectangle locations)
   
    %% get boxes for this frame
    %% N.B. We currently only take one detection per image - see note above.
    bound_box = round(bounding_boxes{i}(:,1));
    gt_bound_box = round(ground_truth_boxes{i}(:,1));
        
    %% Check box is inside image
    if (bound_box(1)<1)
      bound_box(1) = 1;
    end
    
    if (bound_box(2)<1)
      bound_box(2) = 1;
    end

    %%% Check gt box is inside image (also need to check positive extent
    %of image)
    if (gt_bound_box(1)<1)
      gt_bound_box(1) = 1;
    end
    
    if (gt_bound_box(2)<1)
      gt_bound_box(2) = 1;
    end
    
    %% get max_x and max_y over both boxes
    maxx = max([bound_box(1)+bound_box(3),gt_bound_box(1)+gt_bound_box(3)]);
    maxy = max([bound_box(2)+bound_box(4),gt_bound_box(2)+gt_bound_box(4)]);

    %% form big block which will cover both
    block = zeros(maxy,maxx);
    
    %%% add in ground_truth box
    block(gt_bound_box(2):gt_bound_box(2)+gt_bound_box(4),gt_bound_box(1):gt_bound_box(1)+gt_bound_box(3)) = 1;
    %%% now add in proposed box
    block(bound_box(2):bound_box(2)+bound_box(4),bound_box(1):bound_box(1)+bound_box(3)) = block(bound_box(2):bound_box(2)+bound_box(4),bound_box(1):bound_box(1)+bound_box(3)) + 1; 
   
    %%% areas overlapping btw. two boxes will have two hits    
    overlap = length(find(block==2));
    
    %%% areas in one or other box will be >0
    union = length(find(block>0));

    %%% see if ratio is above threshold
    hits(counter) = ((overlap/union)>Recog.Localization_Threshold);
    
  elseif strcmp(Recog.Localization_Criterion,'any_old_type')
  else
    error('Unknown type of criterion');
  end
  
  counter = counter + 1;
  
  end
  
end

