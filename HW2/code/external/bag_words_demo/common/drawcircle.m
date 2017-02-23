function c=drawcircle(y,x,size,colour,lw)

if (nargin==4)
   lw=3;
end

hold on;

t = 0:pi/50:2*pi;    
plot(size/2*sin(t)+x,size/2*cos(t)+y,colour,'Linewidth',lw);

hold off;
