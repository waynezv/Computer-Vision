function SqrDist = m_sqrDist_Cstyle(Data1, Data2)
% Compute square Euclidean distances.
% Using C-Style programming style
% Usages:
% Inputs:
%   Data1: a d*n matrix representing a set of d-dim data points.
%   Data2: a d*m matrix representing a second set of d-dim data points.
% Outputs:
%   SqrDist: a n*m matrix, the entry in i_th row and j_th column represents
%       the square Euclidean distance between the i_th data point of Data1
%       and the j_th data point of Data2.
% By: Minh Hoai Nguyen (minhhoai@gmail.com)
% Date: 27 Aug 08

n = size(Data1,2);
m = size(Data2,2);
d = size(Data1, 1);
SqrDist = zeros(n, m);
for i=1:n
    for j=1:m        
        for k=1:d
            SqrDist(i,j) = SqrDist(i,j) +  (Data1(k,i) - Data2(k,i)).^2;
        end
    end
end
