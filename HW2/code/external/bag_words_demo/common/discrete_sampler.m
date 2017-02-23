function samples_out=discrete_sampler(density,num_samples,replacement_option)
%
% Function that draws samples from a discrete density
%
% density - discrete probability density (should sum to 1)
% num_samples - number of samples to draw
% replacement_option: 1 for sampling with replacment, 0 for no replacment

samples_out = zeros(1,num_samples);

%% Get CDF
cum_density = cumsum(density);

%% Draw samples from uniform distribution
uni_samples = rand(1,num_samples);

a=1;

while (a<=num_samples)

   binary = uni_samples(a)>cum_density;
   
   highest = find(binary);
   
   if isempty(highest)
      samples_out(1,a) = 1;
   else
      samples_out(1,a) = highest(end)+1;
   end
   
   if ((~replacement_option) & (a>1)) %% if we aren't doing replacement
      if (sum(samples_out(1,a)==samples_out(1,1:a-1))>0)
	 uni_samples(1,a)=rand; %% gen. new uniform sample
	 a=a-1; %% redo this sample
      end
   end
   
   a=a+1;
   
end

