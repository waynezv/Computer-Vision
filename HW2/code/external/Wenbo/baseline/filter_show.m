createFilterBank()
figure
for i = 1:3
    subplot(3,1,i)
    imagesc(ans{i, 1});
end
figure
for j = 4:6
    subplot(3,1,j-3)
    imagesc(ans{j, 1});
end
figure
for k = 8:10
    subplot(3,1,k-7)
    imagesc(ans{k, 1});
end