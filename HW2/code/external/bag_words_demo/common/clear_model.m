function clear_model(model_number)
  
  %% little function to clear results so that 
  %% the testing routines will recompute things
  %% rather than just plotting....

    keyboard
%%% load up model    
load(['model_',prefZeros(model_number,4),'.mat']);
  
%%%% Efficient parts and structure model
if exist('bounding_box_efficient')
  clear bounding_box_efficient;
end

%%%% Parts and structure model
if exist('best_hypothesis')
  clear best_hypothesis
end

%%% plsa
if exist('Pd_z_test')
  clear Pd_z_test
end
  
if exist('Pc_d_pos_test')
  clear Pc_d_pos_test
end

%%% save model again
save(['model_',prefZeros(model_number,4),'.mat']);
