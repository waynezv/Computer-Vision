function runPoohInfo
% CV Fall 2014 - Provided Code
% Show info for provided pooh data

	poohpath = 'data/pooh';
    ms = importdata(fullfile(poohpath, 'mean_shape.mat'));
    
	% Visualize pooh mean shape 
	% Format of ms: [nose_x nose_y; left_eye_x left_eye_y; right_eye_x; right_eye_y; right_ear_x right_ear_y; left_ear_x left_ear_y]
    plot(ms(:,1), ms(:,2), 'b+', 'markersize', 12, 'linewidth', 3); axis equal ij; ylim([-130,130]);
	text(ms(:,1)+5, ms(:,2), {'nose','left eye','right eye','right ear','left ear'}, 'color', 'r', 'fontsize', 14);
    mean_shape = ms;
    title('mean shape of Pooh, press any key to continue');
    pause;

    % Format of annotations
    % Each row is [frame_num nose_x nose_y left_eye_x left_eye_y right_eye_x right_eye_y right_ear_x right_ear_y left_ear_x left_ear_y]
    ann = load(fullfile(poohpath,'ann'));
    for u = 1:size(ann, 1)
        I = imread(fullfile(poohpath,'training',sprintf('image-%04d.jpg', ann(u,1))));
        imshow(I);        
        hold on;          

		% Reshape annotations so that it is 5-by-2, ann(u, 1) is frame number
		now_ann = reshape(ann(u,2:end), 2, 5)';

		% Compute scale difference between mean_shape and annotation
		scale = findscale(now_ann, mean_shape);

		% Prepare data for vl_feat
		% First row: x location(s) of where you want to extract SIFT
		% Second row: y location(s) of where you want to extract SIFT
		% Third row: scale of SIFT point, enlarge/shrink the SIFT point range according to scale differences
		% Fourth row: orientation (setting it to 0 is fine for this homework)
		fc = [now_ann'; [7 4 4 10 10] / scale; [0 0 0 0 0]];

		% Extract SIFT from I according to fc
		d = siftwrapper(I, fc);

		% Draw SIFT descriptors
		h3 = vl_plotsiftdescriptor(d,fc);
		set(h3,'color','g') ;

		% Draw ground truth locations
		now_ann = reshape(ann(u, 2:end), 2, 5)';
			plot(now_ann(:, 1), now_ann(:, 2), 'r+', 'MarkerSize', 15, 'LineWidth', 3);

		title(sprintf('training data at frame %d, with sift extracted, press any key to continue', ann(u, 1)));
		hold off;
		pause;
    end
end
