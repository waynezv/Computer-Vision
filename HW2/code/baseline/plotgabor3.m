gaborfilter=gabor(12,0,8,0,1);  
%imshow(gaborfilter/2+0.5);  
  
theta=[0 pi/4 2*pi/4 3*pi/4 4*pi/4 5*pi/4 6*pi/4 7*pi/4];  
gamma=1;  
psi=0;  
sigma=6; % ????12  
lambda=[5 6 7 8 9];  
  
[nh nw]=size(gaborfilter);  
  
G=cell(5,8);  
for i = 1:5  
    for j = 1:8  
        G{i,j}=zeros(nh,nw);  
    end  
end  
  
for i = 1:5  
    for j = 1:8  
        G{i,j}=gabor(sigma,theta(j),lambda(i),psi,gamma);  
    end  
end  
  
%plot  
figure;  
for i = 1:5  
    for j = 1:8  
        subplot(5,8,(i-1)*8+j);          
        %imshow(real(G{s,j})/2-0.5,[]);  
%         imshow(real(G{i,j}),[]);
        imagesc(real(G{i,j}));
    end  
end  
