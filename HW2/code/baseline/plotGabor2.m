function [Gs] = mygabor;  
% ???gabor filter ?????  
% Img = imread('1.tiff');  
  
sigma = 2*pi;  
sigma2 = sigma^2;  
  
GaborZ = 71;  
  
n=1;  
figure;  
for v=0:1:4  
    for u=0:1:7  
        j = u+8*v;  
    n  
        Kv = pi*2^(-(v+2)/2);  
        faiu = pi * u/8;  
%         Kj = Kv * exp( i * faiu );  
        Kj = [Kv *cos(faiu) Kv *sin(faiu)];  
        K2 = norm(Kj');  
        K2 = K2.^2;  
        Gab1 = (K2 /(sigma2));  
        for zx = -GaborZ:GaborZ-1  
            for zy = -GaborZ:GaborZ-1  
                x = [zx zy];  
                x=x';  
                Gab2 = exp(-K2 * (zx^2 + zy^2)/(2*sigma2));  
                Gab3 = (exp(i * Kj * x) - exp(-(sigma2)/2));  
                Gr(zx+GaborZ+1,zy+GaborZ+1) = real(Gab1 * Gab2 * Gab3);  
%                 Gab(zx+GaborZ+1,zy+GaborZ+1) = norm(Gab1 * Gab2 * Gab3);  
            end  
        end  
        subplot(5,8,n),imshow(Gr,[]);  
%         figure;imshow(Gab,[]);  
        n=n+1;   
    end  
%     figure;  
end  