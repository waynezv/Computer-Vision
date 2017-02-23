function FNs = genFileNames (subdirs,frames,root_dir,tag,ext,num_zeros)

%%% Simple routine that creates full absolute path of files for loading
%%% or saving. Returns a cell array of strings, each one being the
%%% filename plus full path.
   
  
if (nargin<=5)
  num_zeros = 4;
end
  
FNs={};
FNn=1;

for d=1:length(subdirs)
  for f = frames
    FNs{FNn}=[root_dir '/' subdirs{d} '/' tag prefZeros(f,num_zeros) ext];
    FNn=FNn+1;
  end
end





