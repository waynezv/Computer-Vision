function F = solve_det2(FF, x1, x2)
a = vgg_singF_from_FF(FF);
F = [];
for i = 1:length(a)
  Fi = a(i)*FF{1} + (1-a(i))*FF{2};
%   for n = 1:7, disp(norm(x(:,n,1)'*Fi*x(:,n,2))), end  % test code
  if signs_OK(Fi,x1,x2)
    F = cat(3, F, Fi);
  end
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%

% Checks sign consistence of F and x
function OK = signs_OK(F,x1,x2)
[u,s,v] = svd(F');
e1 = v(:,3);
l1 = vgg_contreps(e1)*x1;
s = sum( (F*x2) .* l1 );
OK = all(s>0) | all(s<0);
return