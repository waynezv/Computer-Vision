function [out,loc]=dist_transform_1d(cost_function,size_x)
%% Performs a 1-D distance transform
%% based on the pseudo-code provided in 
  
%% Felzenszwalb, P. and Huttenlocher, D. "Pictorial Structures for Object
%% Recognition", Intl. Journal of Computer Vision, 61(1), pp. 55-79, January 2005.    

%% This is a Matlab implementation, thus all arrays start at 1 not 0 as
%% in C  
%  
% R.Fergus 6/10/05 (fergus@csail.mit.edu)  

  
if (nargin==1)
   size_x = length(cost_function);
end

out = zeros(size(cost_function));
loc = zeros(size(cost_function));

k=0;
v(1)=0;
z(1)=-Inf;
z(2)=Inf;

for q=1:size_x-1
   
   s = ((cost_function(q+1)+q^2) - (cost_function(v(k+1)+1)+v(k+1)^2)) / (2*(q - v(k+1)));
   
   while (s<=z(k+1))
      k=k-1;
      s = ((cost_function(q+1)+q^2) - (cost_function(v(k+1)+1)+v(k+1)^2)) / (2*(q - v(k+1)));
   end
   
   k=k+1;
   v(k+1)=q;
   z(k+1)=s;
   z(k+2)=Inf;
      
end
   
k=0;

for q=0:size_x-1
   
   while (z(k+2)<q)
      k=k+1;
   end
   
   loc(q+1) = v(k+1)+1;
   out(q+1) = (q-v(k+1))^2 + cost_function(v(k+1)+1);
   
end



