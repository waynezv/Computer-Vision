function [ MM ] = localmax ( I )

%
%  [ MM ] = localmax ( I )
%
%  MM is a binary mask. For each local maximum in I, a one is entered 
%  in MM.
%
%
%  (c) in 1999 by Markus Weber
%
%  Califonia Institute of Technology
% 

%
%  $Id: localmax.m,v 1.2 2004/10/16 17:01:21 fergus Exp $
%
%  $Log: localmax.m,v $
%  Revision 1.2  2004/10/16 17:01:21  fergus
%
%  Post sicily 04 work submission.
%
%  Revision 1.1.1.1  2003/10/20 16:22:42  fergus
%  ECCV '04 code
%
%  Revision 1.1.1.1  2002/11/21 19:01:47  fergus
%  Inital import of constellation model code
%

I = padarray(I,[1 1],0,'both');

[Y X] = size(I); 

M = zeros(Y, X);

M = I(2 : Y-1, 2 : X-1) > I(2 : Y-1, 3 : X);

M = M & (I(2 : Y-1, 2 : X-1) > I(1 : Y-2, 3 : X));

M = M & (I(2 : Y-1, 2 : X-1) > I(1 : Y-2, 2 : X-1));

M = M & (I(2 : Y-1, 2 : X-1) > I(1 : Y-2, 1 : X-2));

M = M & (I(2 : Y-1, 2 : X-1) > I(2 : Y-1, 1 : X-2));

M = M & (I(2 : Y-1, 2 : X-1) > I(3 : Y, 1 : X-2));

M = M & (I(2 : Y-1, 2 : X-1) > I(3 : Y, 2 : X-1));

M = M & (I(2 : Y-1, 2 : X-1) > I(3 : Y, 3 : X));

%MM = zeros(Y, X);
MM=M;
%MM(2 : Y-1, 2 : X-1) = M;
