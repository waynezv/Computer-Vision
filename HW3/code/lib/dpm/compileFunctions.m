fileNames = {'bounded_dt.cc',  'fconv_var_dim.cc',  'get_detection_trees.cc'};

cellfun(@(x)(mex(x)),fileNames);
