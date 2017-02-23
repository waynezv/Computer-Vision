function F = genFeatureMatrix(annotation, perturbedCfg, nPertCfg, poohpath)
% generate feature matrix 
%
% << annotation  : ground truth 1-by-11
% << perturbedCfg: perturbations 4-by-(5nPertCfg)
% << nPertCfg    : number of perturbations
% << poohpath    : train path
%
% >> F: feature matrix nPertCfg-by-640
%
ann = annotation;
pCfg = reshape(perturbedCfg, [4, 5, nPertCfg]);

draw = 0;

I = imread(fullfile(poohpath,'training',sprintf('image-%04d.jpg', ann(1)))); 
if draw
    imshow(I); hold on;
    % Draw ground truth locations
    now_ann = reshape(ann(2:end), 2, 5)'; plot(now_ann(:, 1), now_ann(:, 2), 'r+', 'MarkerSize', 15, 'LineWidth', 3);
end
F = zeros(nPertCfg, 5*128);
for i = 1:nPertCfg
    % Extract SIFT from I according to perturbations
    d = siftwrapper(I, pCfg(:,:,i));
    if draw
        % Draw SIFT descriptors
        h3 = vl_plotsiftdescriptor(d, pCfg(:,:,i)); set(h3,'color','g');
        pause(0.5);
    end
%     for ii = 1:5
%         d(:,ii) = d(:,ii)./sum(d(:,ii));
%     end
    % !!! normalize !!!
    F(i,:) = d(:).';
%     F(i,:) = d(:)./sum(d(:));
end

end