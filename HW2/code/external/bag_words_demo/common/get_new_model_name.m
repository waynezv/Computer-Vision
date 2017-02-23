function [fname,num] = get_new_model_name(model_dir,num_zeros)

%% little function to return filename for new model, along with its index
%% it sees how many existing models are in model_dir and generates a
%% filename for a new one.

%% input - model_dir, the full path to the model directory.

%% output - fname, full path and file name of new model
%%          num, index of new model

%%% what is the model filename prefix
model_prefix = 'model_';

%%% get list of all existing models in directory
d = dir([model_dir,'/*.mat']);

%%% get index of new model (+1 from last)
num = length(d)+1;

%%% create filename
fname = [model_dir,'/',model_prefix,prefZeros(num,num_zeros),'.mat'];