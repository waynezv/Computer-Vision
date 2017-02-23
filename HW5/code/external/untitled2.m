% Linear step
A = vgg_vec_swap(x1,x2)';
[u,s,v] = svd(A,0);
FF{1} = reshape(v(:,end-1),[3 3]);
FF{2} = reshape(v(:,end  ),[3 3]);

% Solving cubic equation and getting 1 or 3 solutions for F
a = vgg_singF_from_FF(FF);
F = [];
for i = 1:length(a)
  Fi = a(i)*FF{1} + (1-a(i))*FF{2};
  %for n = 1:7, disp(norm(x(:,n,1)'*Fi*x(:,n,2))), end  % test code
  if signs_OK(Fi,x1,x2)
    F = cat(3, F, Fi);
  end
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%
% Solve The cubic equation for a
a = roots([-D(2,1,1)+D(1,2,2)+D(1,1,1)+D(2,2,1)+D(2,1,2)-D(1,2,1)-D(1,1,2)-D(2,2,2)
            D(1,1,2)-2*D(1,2,2)-2*D(2,1,2)+D(2,1,1)-2*D(2,2,1)+D(1,2,1)+3*D(2,2,2)
            D(2,2,1)+D(1,2,2)+D(2,1,2)-3*D(2,2,2)
            D(2,2,2)]);
a = a(abs(imag(a))<10*eps);
% Checks sign consistence of F and x
function OK = signs_OK(F,x1,x2)
[u,s,v] = svd(F');
e1 = v(:,3);
l1 = vgg_contreps(e1)*x1;
s = sum( (F*x2) .* l1 );
OK = all(s>0) | all(s<0);
return