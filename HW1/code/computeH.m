% WENBO ZHAO
% Q 4.1
% 2015

function H2to1 = computeH(p1, p2)

N = size(p1, 2); % the number of points
A = zeros(2*N, 9); % set A to the required size
% add 1s to the last column of points
p1 = [p1;repmat(1, [1 N])];
p2 = [p2;repmat(1, [1 N])];
for i = 1 : N
    % ... your code here ...
    A(2*i-1,:) = [p2(:,i).' 0 0 0 -p1(1,i).*p2(:,i).'];
    A(2*i,:) = [0 0 0 p2(:,i).' -p1(2,i).*p2(:,i).'];
end


% ... your code here ...
% ... eig ...

[V,D] = eig(A.'*A);
% ... your code here ...
[minVal, minPos] = min(diag(D));
H = V(:, minPos);

H2to1 = reshape(H,3,3)';

end
