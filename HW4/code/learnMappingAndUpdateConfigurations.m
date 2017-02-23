function [W, perturbedCfg_out, distPertToAnn] = learnMappingAndUpdateConfigurations(F, D, perturbedCfg, nPertCfg, nTrain, annotations)
% learn mapping D = FW by solving least square prob min||FW-D||_F^2 and
% update perturbed configurations using predicted displacement on features
%
W = learnLS(F, D);
D_update = F*W; % 1000-by-10
D_update = reshape(D_update', [2,5*nPertCfg,nTrain]);
distPertToAnn = 0;
% update configurations with new displacement
for i = 1:nTrain
    perturbedCfg_out{i}(1:2,:) = perturbedCfg{i}(1:2,:) + D_update(:,:,i); 
    perturbedCfg_out{i}(3:4,:) = perturbedCfg{i}(3:4,:);
    distPertToAnn = distPertToAnn + sum( pdist2( reshape(perturbedCfg_out{i}(1:2,:), [10,nPertCfg]).', ... % 100-by-10
                    annotations(i,2:end) ) ); % 1-by10               
end
end