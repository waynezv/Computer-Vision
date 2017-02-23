% function [D, ftsout, ang, ind, out_imname] = gg_lola_km_binary(Im, fts, scale, descr_type, verbose, Par);
%
% Compute descriptors for our (fsm+jiri) features using krystian's binary 
%
% INPUTS:
%         Im ... is the image
%         fts ... (5 x n), where each column is [x y a b c]:
%                 x,y is position of the feature.
%                 a,b,c are parameters of 2x2 symmetric matrix A=[a b; b c] representing local
%                   affine transformation (no rotation) taking elliptical 
%                   neighbourhood of x,y onto unit circle. abc must be normalized
%                   so that det(A)=1., see the note 4).
%         scale ... is vector of relative scale parameters for each feature
%         verbose ... if 1 print results of applying the binary.
%         Par.Path.bin_dir ... path to the compute_descriptors binary   
%
% Notes:
%              
%           1) In km's binary, each elliptical feature is 5x enlarged for
%              computing the descriptor.
%              To keep the original scale (specified by 'scale' parameter), in this file we divide 'scale' 
%              parameter by 5 before we input the features into the binary.
%           
%           2) If you display overlapped ellipses over image using '-DR' option for the km binary.
%              The ellipses are scaled only 3x. (Not 5x as  used for descriptor computation);
%
%           3) Note on features detected in lola movie by fsm: 
%              The [a b;b c] parameters are already prescaled! 
%              Unless we want to use smaller or bigger ellipses than the standard one(x5),
%              these features need not be further rescaled and scale parameter should be kept 1.
%              The scale is divided by 5 before inputting it into the km's binary, where it is 
%              again multiplied by 5. The descriptor is therefore computed on the original region 
%              specified only by [a b; b c]
%
%         ! 4) Transformation matrix A=[a b;b c] should be normalized so that determinant is 1.
%              The scale factor input into km binary should be "scale = s_rel*sqrt(det(A))",
%              where s_rel is our prefered relative scale of the region. 
%
% OUTPUT:
%          D      ... n x d matrix where each row contains d-dimensional descriptor valued 0..255
%          ftsout ... x y a b c   feature parameters for each row of D
%          ang    ... detected dominant gradient orientation for each row of D
%          ind    ... index array, for each row of D pointing to corresponding feature 
%                     in input fts
%          out_imname ... name of image with overlayed regions, only when
%                         verbose is 1.
%
% Note:   The output descriptor array D may be either longer or shorter then the input 
%         feature array fts:
%            1) One feature can have multiple descriptors corresponding to 
%               multiple detected dominant gradient orientations due to
%               e.g. bimodal gradient orientation histogram.
%            2) Some features can have no descriptor at all, e.g. feature ellipses
%               reaching out of image
%         
%                         
% Josef Sivic <josef@robots.ox.ac.uk>
% 13/12/2002

function [D, ftsout, ang, ind, out_imname] = gg_lola_km_binary(Im, fts, scale, descr_type, verbose, Par);

if nargin < 5 
   verbose = 0;
end;   

if nargin < 6
  %binary_path = '/homes/11/josef/cvbins/km/';
  binary_path = '/users/josef/cvbins/km/';
else
%  binary_path = [Par.Path.bin_dir 'km/'];   
   binary_path = [Par.Path.bin_dir '/'];   
end;   


if ~isempty(findstr(descr_type,'sift'))
   descr_type = 'sift';
end;   


%binary_path = '/homes/11/josef/cvbins/km/bin.old/'; %!!!
%corner_file = [binary_path 'corners.in'];
%image_file  = [binary_path 'inIm.pgm'];
%out_file    = [binary_path 'out.desc'];

%corner_file = '/tmp/corners2.in';
%image_file  = '/tmp/inIm2.pgm';
%out_file    = '/tmp/out2.desc';

temp_name =  sprintf('%.16f',now);
corner_file = ['/tmp/corners', temp_name,'.in'];
image_file = ['/tmp/inIm', temp_name,'.pgm'];
out_file = ['/tmp/out', temp_name,'.desc'];
out_imname = ['/tmp/out', temp_name,'.desc.pgm'];

% save image as pgm
%vgg_save_image(Im,sprintf('/homes/11/josef/data/lola/sets.lola/gtset/%03d.pgm',i), 'pgm');   
if max(Im(:))<2
  imwrite(Im*255, image_file,'pgm');
else
  imwrite(Im, image_file,'pgm');
end;



% creat input feature point file 

% values we do not use, but that are set as km suggested
cornerness = 1000 * ones(size(fts,2),1);
angle      = 0 * ones(size(fts,2),1);     % detected in descriptor binary anyway
type       = 0  * ones(size(fts,2),1);
lap        = 10 * ones(size(fts,2),1);
extr       = 0 * ones(size(fts,2),1);

% normalize fts so that determinant of each feature is 1
scaleA = zeros(size(fts,2),1);
ftsn   = zeros(size(fts));
ftsn(1:2,:) = fts(1:2,:);
for i = 1:size(fts,2)
   a = fts(3,i);    b = fts(4,i);   c = fts(5,i);   A = [a b;b c];
   scaleA(i) = sqrt(det(A));
   ftsn(3:5,i) = fts(3:5,i)./scaleA(i);
end;

% set scale for each feature
if size(scale,1) ==1 
  inscale = scale .* scaleA / 5; % divide scale by 5  %!!!
else 
  inscale = scale .* scaleA / 5;  %!!!
end;  

        
% -1 matlab -> C
km_in = [ftsn(1,:)'-1 ftsn(2,:)'-1 cornerness inscale angle type lap extr ftsn(3,:)' ftsn(4,:)' ftsn(4,:)' ftsn(5,:)'];

% scale included in fts
%inscale_1 = ones(size(inscale));
%km_in = [fts(1,:)'-1 fts(2,:)'-1 cornerness inscale_1 angle type lap extr inscale.*fts(3,:)' inscale.*fts(4,:)' inscale.*fts(4,:)' inscale.*fts(5,:)'];

%fsmi = [100 101]; km_in = [fts(1,fsmi)'-1 fts(2,fsmi)'-1 cornerness(fsmi) inscale(fsmi) angle(fsmi) type(fsmi) lap(fsmi) extr(fsmi) fts(3,fsmi)' fts(4,fsmi)' fts(4,fsmi)' fts(5,fsmi)'];

% save data to input file
fid = fopen(corner_file,'w');
fprintf(fid,'%d \n',size(km_in,1)); % save number of features in the file
fprintf(fid,'0 \n');                % number of descriptors in the file is 0
fprintf(fid,'%.4f %.4f %d %.3f %d %d %d %d %.6f %.6f %.6f %.6f \n' ,km_in');
fclose(fid);


% run binary
exec_string =  [binary_path, 'compute_descriptors.ln ',   ...
 ' -', descr_type, ...
 ' -i ', image_file, ...
 ' -p ', corner_file, ...
 ' -o ', out_file, ...
];

if verbose
   exec_string = [exec_string ' -DR']; %draw points
   [ss,ww] = unix(exec_string)
else
   [ss,ww]=unix(exec_string);
end; 


% load output file
fid = fopen(out_file,'r');
if fid==-1
   disp('Could not open output file');
   disp(ss); disp(ww);
   D = []; ftsout=[]; ang=[]; ind=[];
   return;
   %keyboard;
end;   
   
nod = fscanf(fid, '%d',1); % read number of descriptors
dd = fscanf(fid, '%d',1); % read dimension of descriptors
%DD = fscanf(fid, '%.4f %.4f %d %d %d %d %d %d %.6f %.6f %.6f %.6f %f'
tmp = fscanf(fid, '%f',[dd+12 nod])';
fclose(fid);

if verbose
  fprintf('Reading: %d descriptors of dimension %d \n',nod, dd);
end;

D = tmp(:,13:end);
ftsout = [tmp(:,1)+1 tmp(:,2)+1 tmp(:,9) tmp(:,10) tmp(:,12)]';  %+1 C->matlab
ang = tmp(:,5);

%keyboard; %!!!


%find the corresponding indices from ftsout
[tmpind, d2] = vgg_nearest_neighbour(ftsout(1:2,:), fts(1:2,:));
ind = int32(tmpind(:,1));


% assign input fts to output descriptors (km binary erases affine parameters from fts)
ftsout = fts(:,ind);

% !!!
delete(corner_file);
delete(image_file);
delete(out_file);

return;





% kmout = load('/homes/11/josef/cvbins/km/out.aff');
% kmi = find(kmout(:,1)==639&kmout(:,2)==50 );
% kmfts = [kmout(kmi,1:2) kmout(kmi,9) kmout(kmi,10) kmout(kmi,12)];
% kmscale = kmout(kmi,4);
% 
% % plot one km detected feature
% T = [kmout(kmi,9) kmout(kmi,10); kmout(kmi,10) kmout(kmi,12)];
% iT = inv(T);
% ikmfts = [kmout(kmi,1:2) iT(1,1) iT(1,2) iT(2,2)]
% gg_plot_ellipses(Im,ikmfts',kmscale*5)
% 
% % plot all km detected features
% kmfts = [kmout(:,1:2) kmout(:,9) kmout(:,10) kmout(:,12)];
% kmscale = kmout(:,4);
% gg_plot_ellipses(Im,kmfts',kmscale*3);
% 
% % plot fsm's features
% fsmfts = load('/homes/11/josef/cvbins/km/164.fsm_corners')';
% gg_plot_ellipses(Im,fsmfts,5);
% fsmi = 600;
% for fsmi = 1:size(fsmfts,2)
%    a = fsmfts(3,fsmi);
%    b = fsmfts(4,fsmi);
%    c = fsmfts(5,fsmi);
%    Tfsm = [a b; b c];
%    dt(fsmi) = det(Tfsm);
% end;

