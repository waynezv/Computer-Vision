function [detectionBoxes] = esvm_detect(I, models, params)
%original code by Tomasz Malisiewicz
%modifications by Ishan Misra for CV Fall 2014


[rs1, t1] = esvm_detectdriverBLOCK(I, models, params);
detectionBoxes = cat(1,rs1.bbs{:});
if(~isempty(detectionBoxes))
    detectionBoxes = clip_to_image(detectionBoxes,[1 1 size(I,2) size(I,1)]);
end    

detectionBoxes = esvm_nms(detectionBoxes,0.5);

function [resstruct,t] = esvm_detectdriverBLOCK(I, models, ...
                                             params)

%%HERE is the chunk version of exemplar localization

N = length(models);
ws = cellfun2(@(x)x.model.w,models);
bs = cellfun(@(x)x.model.b,models)';
bs = reshape(bs,[],1);
sizes1 = cellfun(@(x)x.model.hg_size(1),models);
sizes2 = cellfun(@(x)x.model.hg_size(2),models);

S = [max(sizes1(:)) max(sizes2(:))];
fsize = params.init_params.features();
templates = zeros(S(1),S(2),fsize,length(models));
templates_x = zeros(S(1),S(2),fsize,length(models));
template_masks = zeros(S(1),S(2),fsize,length(models));

for i = 1:length(models)
  t = zeros(S(1),S(2),fsize);
  t(1:models{i}.model.hg_size(1),1:models{i}.model.hg_size(2),:) = ...
      models{i}.model.w;

  templates(:,:,:,i) = t;
  template_masks(:,:,:,i) = repmat(double(sum(t.^2,3)>0),[1 1 fsize]);

  if (~isempty(params.nnmode)) || ...
        (isfield(params,'wtype') && ...
         strcmp(params.wtype,'dfun')==1)
    x = zeros(S(1),S(2),fsize);
    x(1:models{i}.model.hg_size(1),1:models{i}.model.hg_size(2),:) = ...
        reshape(models{i}.model.x(:,1),models{i}.model.hg_size);
    templates_x(:,:,:,i) = x;

  end
end

%maskmat = repmat(template_masks,[1 1 1 fsize]);
%maskmat = permute(maskmat,[1 2 4 3]);
%templates_x  = templates_x .* maskmat;

sbin = models{1}.model.init_params.sbin;
t = get_pyramid(I, sbin, params);
resstruct.padder = t.padder;

pyr_N = cellfun(@(x)prod([size(x,1) size(x,2)]-S+1),t.hog);
sumN = sum(pyr_N);

X = zeros(S(1)*S(2)*fsize,sumN);
offsets = cell(length(t.hog), 1);
uus = cell(length(t.hog),1);
vvs = cell(length(t.hog),1);

counter = 1;
for i = 1:length(t.hog)
  s = size(t.hog{i});
  NW = s(1)*s(2);
  ppp = reshape(1:NW,s(1),s(2));
  curf = reshape(t.hog{i},[],fsize);
  b = im2col(ppp,[S(1) S(2)]);

  offsets{i} = b(1,:);
  offsets{i}(end+1,:) = i;
  
  for j = 1:size(b,2)
   X(:,counter) = reshape (curf(b(:,j),:),[],1);
   counter = counter + 1;
  end
  
  [uus{i},vvs{i}] = ind2sub(s,offsets{i}(1,:));
end

offsets = cat(2,offsets{:});

uus = cat(2,uus{:});
vvs = cat(2,vvs{:});

% m.model.w = zeros(S(1),S(2),fsize);
% m.model.b = 0;
% temp_params = params;
% temp_params.detect_save_features = 1;
% temp_params.detect_exemplar_nms_os_threshold = 1.0;
% temp_params.max_models_before_block_method = 1;
% temp_params.detect_max_windows_per_exemplar = 28000;

% [rs] = esvm_detect(I, {m}, temp_params);
% X2=cat(2,rs.xs{1}{:});
% bbs2 = rs.bbs{1};


exemplar_matrix = reshape(templates,[],size(templates,4));

if isfield(params,'wtype') && ...
      strcmp(params.wtype,'dfun')==1
  W = exemplar_matrix;
  U = reshape(templates_x,[],length(models));
  r2 = repmat(sum(W.*(U.^2),1)',1,size(X,2));
  r =  (W'*(X.^2) - 2*(W.*U)'*X + r2);
  r = bsxfun(@minus, r, bs);
elseif isempty(params.nnmode)
  %nnmode 0: Apply linear classifiers by performing one large matrix
  %multiplication and subtract bias
  r = exemplar_matrix' * X;
  r = bsxfun(@minus, r, bs);
elseif strcmp(params.nnmode,'normalizedhog') == 1
  r = exemplar_matrix' * X;
elseif strcmp(params.nnmode,'nndfun') == 1
  %Do euclidean distance (but only over the regions corresponding
  %to the in-mask (non-padded) regions
  W = reshape(template_masks,[],length(models));
  W = W / 100;
  U = reshape(templates_x,[],length(models));
  r2 = repmat(sum(W.*(U.^2),1)',1,size(X,2));
  r = - (W'*(X.^2) - 2*(W.*U)'*X + r2);
else
  error('invalid nnmode=%s\n',params.nnmode);
end

resstruct.bbs = cell(N,1);
resstruct.xs = cell(N,1);

for exid = 1:N

  goods = find(r(exid,:) >= params.detect_keep_threshold);
  
  if isempty(goods)
    continue
  end
  
  [sorted_scores,bb] = ...
      psort(-r(exid,goods)',...
            min(params.detect_max_windows_per_exemplar, ...
                length(goods)));
  bb = goods(bb);

  sorted_scores = -sorted_scores';

  resstruct.xs{exid} = X(:,bb);
  
  levels = offsets(2,bb);
  scales = t.scales(levels);
  curuus = uus(bb);
  curvvs = vvs(bb);
  o = [curuus' curvvs'] - t.padder;

  bbs = ([o(:,2) o(:,1) o(:,2)+size(ws{exid},2) ...
           o(:,1)+size(ws{exid},1)] - 1) .* ...
             repmat(sbin./scales',1,4) + 1 + repmat([0 0 -1 ...
                    -1],length(scales),1);
  
  bbs(:,5) = exid;
  bbs(:,6) = sorted_scores;
  
  resstruct.bbs{exid} = bbs;
end


if params.detect_save_features == 0
  resstruct.xs = cell(N,1);
end
%fprintf(1,'\n');

function rs = prune_nms(rs, params)
%Prune via nms to eliminate redundant detections

%If the field is missing, or it is set to 1, then we don't need to
%process anything.  If it is zero, we also don't do NMS.
if ~isfield(params,'detect_exemplar_nms_os_threshold') || (params.detect_exemplar_nms_os_threshold >= 1) ...
      || (params.detect_exemplar_nms_os_threshold == 0)
  return;
end

rs.bbs = cellfun2(@(x)esvm_nms(x,params.detect_exemplar_nms_os_threshold),rs.bbs);

if ~isempty(rs.xs)
  for i = 1:length(rs.bbs)
    if ~isempty(rs.xs{i})
      %NOTE: the fifth field must contain elements
      rs.xs{i} = rs.xs{i}(:,rs.bbs{i}(:,5) );
    end
  end
end

function t = get_pyramid(I, sbin, params)
%Extract feature pyramid from variable I (which could be either an image,
%or already a feature pyramid)

if isnumeric(I)
  
  clear t
  t.size = size(I);

  %Compute pyramid
  [t.hog, t.scales] = esvm_pyramid(I, params);
  t.padder = params.detect_pyramid_padding;
  for level = 1:length(t.hog)
    t.hog{level} = padarray(t.hog{level}, [t.padder t.padder 0], 0);
  end
  
  minsizes = cellfun(@(x)min([size(x,1) size(x,2)]), t.hog);
  t.hog = t.hog(minsizes >= t.padder*2);
  t.scales = t.scales(minsizes >= t.padder*2);  
else
  fprintf(1,'Already found features\n');
  
  if iscell(I)
    if params.detect_add_flip==1
      t = I{2};
    else
      t = I{1};
    end
  else
    t = I;
  end
end

