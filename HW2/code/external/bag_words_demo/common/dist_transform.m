function [out,location]=dist_transform(cost_function,x_multiply,y_multiply,z_multiply)
%
% Wrapper function for the distance transform 
% Depending on the size of cost_function it will implement 1,2, or 3-D
% versions of the distance transform. 

%% Running out of time to comment this fully.....  
  
% The actual transform is performed by the dist_transform_1d function  
% and is based on the methods described in:
%
%% Felzenszwalb, P. and Huttenlocher, D. "Pictorial Structures for Object
%% Recognition", Intl. Journal of Computer Vision, 61(1), pp. 55-79, January 2005.    

%  
% R.Fergus 6/10/05 (fergus@csail.mit.edu)  

  
if (nargin==1)
   x_multiply = 1;
   y_multiply = 1;  
   z_multiply = 1;   
end

if (nargin==2)
   y_multiply = 1;  
   z_multiply = 1;   
end   

if (nargin==3)
   z_multiply = 1;   
end   

[size_y, size_x, size_z]=size(cost_function);

if ndims(cost_function)>3
   error('Can only handle 1,2 or 3-D cost functions');
end

if ((size_y==1) | (size_x==1))
   %%% 1-D
   mode = '1D';

   if (size_y>size_x)
      cost_function = cost_function';
      [size_y, size_x, size_z]=size(cost_function);
   end
   
elseif (size_z==1)
   mode = '2D';
else
   mode = '3D';
   
end

if strcmp(mode,'1D');
   
   [out,location] = dist_transform_1d(cost_function*x_multiply,size_x);
 
elseif strcmp(mode,'2D')

   out = zeros(size_y,size_x);
   location = zeros(size_y,size_x,2);
   
   for row=1:size_y
      
      [out(row,:),location(row,:,1)] = dist_transform_1d(cost_function(row,:)*x_multiply,size_x);
      
   end
   
   for col=1:size_x
      
      [out(:,col),location(:,col,2)] = dist_transform_1d(out(:,col)/x_multiply*y_multiply,size_y);
      
   end
   
   out = out / y_multiply;
   
else %%% 3-D mode
   
   out = zeros(size_y,size_x,size_z);
   location = zeros(size_y,size_x,size_z,3);
    
   for depth = 1:size_z
   
      for row=1:size_y
	 
	 [out(row,:,depth),location(row,:,depth,1)] = dist_transform_1d(cost_function(row,:,depth)*x_multiply,size_x);
	 
      end
      
      for col=1:size_x
	 
	 [out(:,col,depth),location(:,col,depth,2)] = dist_transform_1d(out(:,col,depth)/x_multiply*y_multiply,size_y);
	 
      end
   
   end
   
   for col=1:size_x
      for row=1:size_y
	 
	 [out(row,col,:),location(row,col,:,3)] = dist_transform_1d(out(row,col,:)/y_multiply*z_multiply,size_z);
      
      end
   end
     
   out = out / z_multiply;
   
end

   
   
   
   
   
