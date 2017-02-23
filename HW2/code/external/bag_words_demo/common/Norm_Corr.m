function Norm_Corr(image_file_names,output_file,filters,Interest_Point)
  
%% Function that takes templates from hand clicked model uses them as
%% normalized cross-correlation templates, running them
%% over the image, selecting the top Interest_Point.Max_Points points
%% according to their response. 
 
%% Currently not multi-scale but can easily be made so...  
  
%% Inputs: 
%%      1. image_file_names - cell array of filenames of all images to be processed
%%      2. output_file_names - cell array of output filenames
%%      3. filter - patch_size^2 x Learn.Num_Parts matrix holding mean
%%                  pixel intensities of hand clicked points 
%%      4. Interest_Point - structure holding all settings of the interest operator
  
%% Outputs:
%%      None - it saves the results for each image to the files
%%      specified in output_file_names.
%%      Each file holds 5 variables:
%%              x - x coordinates of points (Learn.Num_Parts x 1) cell
%array, each element of which is of size (at most) 1 by Interest_Point.Max_Points
%%              y - y coordinates of points (Learn.Num_Parts x 1) cell array
%%          scale - characteristic scale of points (radius, inpixels)(Learn.Num_Parts x 1) cell array
%%     descriptor - normalized correlation score of image at each point, a single number in the range -1 to +1       
%%          score - same as descriptor.  
%% response_image - "image" of correlation response at all locations (& scales if doing multi-scale version).
  
%% It is expected that Learn.Num_Parts should match size(filters,2).  
  
%%% R.Fergus (fergus@csail.mit.edu)  03/10/05.  

%%% DEBUG swtich. Normally set to 0 but if set to >=1 will start plotting
%%% out results so user can check operation of the fucntion    
DEBUG       = 0;

%%% standard colors
cols = {'r.' 'g.' 'b.' 'c.' 'm.' 'y.' 'k.'};

%%% Get total number of images
nImages = length(image_file_names);

%%% Get total number of parts
nParts  = size(filters,2);

%%% get size of each filter
filter_size = sqrt(size(filters,1));

%%% Loop over all images
for i = 1:nImages

  %%% print out progress
  if (mod(i,10)==0)
    fprintf('.%d',i);
  end
  
  %%% Reset variables
  x = cell(nParts,1); 
  y = cell(nParts,1); 
  scale = cell(nParts,1); 
  score = cell(nParts,1);
  descriptor = cell(nParts,1);
  
  %%% read in image
  im=imread(image_file_names{i});
  
  %% Get size
  [imy,imx,imz]=size(im);
     
  %% Convert to grayscale if not already so...
  if (imz>1)
    im=rgb2gray(im);
  end
  
  if (length(Interest_Point.Scale)>1)
    %%% multiscale section
    
    %%% not yet implemented. 
    
    %%% General plan:  1. Form image pyramid.
    %                  2. Do correlation at each level.
    %                  3. Resize lower levels of the pyramid to same size ...
    %                      as original image.
    %                  4. Do 3-D localmax over (x,y,scale) volume.
  
  else %%% single scale
    
    %%% Run normalised cross-correlation
    
    for a=1:nParts %%% loop over each part

      %%% use image processing toolbox function
      tmp_image = normxcorr2(reshape(filters(:,a),[filter_size filter_size]),im);
       
      %%% crop full output to get image over valid protion
      offset = round(filter_size/2);
      response_image(:,:,a) = tmp_image(filter_size-offset:end,filter_size-offset:end);
      
      %%% now find local maxima of response
      max_im = localmax(response_image(:,:,a));
      
      %%% get indices of points
      [y{a},x{a},tmp] = find(max_im);
      
      for b=1:length(x{a})
        %%% get response of local maxima 
        descriptor{a}(b) = response_image(y{a}(b),x{a}(b),a);
      end

      %%% copy to score
      score{a} = descriptor{a};

      %%% set scale
      scale{a} = Interest_Point.Scale * ones(1,length(descriptor{a}));
      
      if (length(descriptor{a})>Interest_Point.Max_Points)
        %%%%% Find the top Interest_Point.Max_Points locations
        [tmp,ind] = sort(-descriptor{a});
        good_ind = ind(1:Interest_Point.Max_Points);
        
        %% Now throw away the bad ones
        x{a} = x{a}(good_ind);
        y{a} = y{a}(good_ind);
        descriptor{a} = descriptor{a}(good_ind);
        score{a} = score{a}(good_ind);
        scale{a} = scale{a}(good_ind);
      end
      
    end  %%% end of loop over all parts
    
    
  end %%% end of single/multi-scale if statement
  
  if DEBUG
    
    if (length(Interest_Point.Scale)>1)
      %%% debug plotting not setup for this yet
    else

      %%% show original figures
      figure(997); clf; 
      imagesc(im); colormap(gray);
      hold on;
      for b=1:nParts
        plot(x{b},y{b},cols{b});
      end
        
      %%% show response image with local maxima superimposed
      figure(998); clf; 
      for b=1:nParts
        subplot(nParts,1,b); 
        imagesc(response_image(:,:,b)); colorbar; hold on;
        plot(x{b},y{b},'k.');
        title(['Part: ',num2str(b)]);
      end
      
      pause
      
    end
    
  end
  
  
  %%% Now save out point info and response images to interest_point file
  
  save(output_file{i},'x','y','scale','score','descriptor','response_image');
  
end %% end of loop over all images
