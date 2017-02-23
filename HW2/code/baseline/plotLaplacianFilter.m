function H = plotLaplacianFilter()
alpha  = [0:0.1:1];

H = cell(length(alpha));
for i = 1:length(alpha)
    H{i} = getLaplacian(alpha(i)); 
end
n = length(alpha);
for i = 1:length(alpha)
    subplot(2,5,i)
    imagesc(H{i})
end

end



function H = getLaplacian(alpha)

 H = fspecial('laplacian',alpha)

end