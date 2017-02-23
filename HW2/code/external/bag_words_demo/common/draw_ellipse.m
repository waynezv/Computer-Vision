function [ph,xy,L,l,th] = draw_ellipse(m,A,col,lw,ph)
%DISEGNA_ELLLISSE  Draws ellipse specified by parameters
%% restituisce assi maggiore e minore ed orientazione dell'asse maggiore
%% P. Perona, Oct. 24  1997
%% m = vector containing x and y coords of center
%% A = matrix containing shape parameters (coded as in a Gaussian's
%% covariance matrix)
%% lw = width of the line used to draw the ellipse
%% ph = plot handle - if this is specified then the ellipse is drawn into
%% the Xdata and Ydata of the plot

if nargin<3, col='g'; end;
if nargin<4, lw = 3;  end;
if nargin<5, ph = 0; end;

N = 65; %% Numero punti campione per disegnare l'ellisse
radius = 2; %% Draw 2sigma ellipse

cxy = m(:);

if (det(A)<0),
   error('Negative determinant of A');
end;

%% Generate points on circle
theta = 2*pi*[0:N]/N;
uv = [radius * cos(theta); radius * sin(theta)];

%% genera ellisse a partire da cerchio
[U,S,V] = svd(A);
AA = U * sqrt(S);
xy = AA * uv;
XX = cxy(1) + xy(1,:);
YY = cxy(2) + xy(2,:);

if ph,
    set(ph,'XData',XX,'YData',YY);
else,
    hold_state = ishold;
    if ~hold_state, hold on; end;
    ph = plot(XX, YY, col, 'LineWidth', lw);  %% Draw ellipse
  %  plot(cxy(1)+[0 0; radius*AA(1,:)], cxy(2)+[0 0; radius*AA(2,:)], col, 'LineWidth', 1); %% Draw major and minor axes
    if ~hold_state, hold off; end;
    axis equal;
end;

a = A(1,1); b=A(1,2); c=A(2,2);
%% Calcola assi maggiore, minore ed orientazione dell'ellisse
L = sqrt(radius)/sqrt((a+c)/2 - sqrt((a-c)^2/4 + b^2));
l = sqrt(radius)/sqrt((a+c)/2 + sqrt((a-c)^2/4 + b^2));
th = atan2(AA(2,2),AA(1,2));

