function D = genDisplacementMatrix(annotation, perturbedCfg)
% generate displacement matrix between perturbed configurations and ground
% truth
% annotation: ground truth 5-by-2
% perturbedCfg: 4-by-(n*5)
% D: n*10
n    = size(perturbedCfg, 2)./5;
ann  = annotation(2:end);
pCfg = reshape(perturbedCfg(1:2,:), [10, n]).';
D    = repmat(ann, [n, 1]) - pCfg;
end