function [rec,prec,ap] = evalAP(gtBoxCell,detBoxCell,IOU_ratio,draw)
%compute AP over one class only
%gtBoxCell : cell array containing ground truth per image.
%          N ground truth images ==> gtBoxes is 1xN
%detBoxCell: cell array containing detetions per image.
%Ishan Misra CV Fall 2014

assert(length(gtBoxCell)==length(detBoxCell));

gtBoxes = []; detBoxes = [];
gtBoxIds = []; detBoxIds = [];
for i=1:length(gtBoxCell)
    if(~isempty(gtBoxCell{i}))
        gtBoxes = [gtBoxes; gtBoxCell{i}];
        gtBoxIds = [gtBoxIds; ones(size(gtBoxCell{i},1),1)*i];
    end
    if(~isempty(detBoxCell{i}))
        detBoxes = [detBoxes; detBoxCell{i}];
        detBoxIds = [detBoxIds; ones(size(detBoxCell{i},1),1)*i];
    end
end    

gtBoxIds
assert(length(gtBoxIds)==size(gtBoxes,1));
assert(length(detBoxIds)==size(detBoxes,1));
if(~exist('IOU_ratio','var'))
    IOU_ratio = 0.5;
end    
if(~exist('draw','var'))
    draw=false;
end    

% load ground truth objects
tic;
npos=0;
gtIds = unique(gtBoxIds);
%detIds = unique(detBoxIds);
%assert(all(ismember(gtIds,detIds)));
gt(length(gtIds))=struct('BB',[],'diff',[],'det',[]);
for i=1:length(gtIds)
    theseBoxes = gtBoxes(gtBoxIds==gtIds(i),:);
    
    gt(i).BB=theseBoxes';
    gt(i).diff=false(size(theseBoxes,1),1);
    gt(i).det=false(size(theseBoxes,1),1);
    npos=npos+sum(~gt(i).diff);
end

% load results
%[ids,confidence,b1,b2,b3,b4]=textread(sprintf(VOCopts.detrespath,id,cls),'%s %f %f %f %f %f');
BB = detBoxes(:,1:4)';
confidence = detBoxes(:,end);

% sort detections by decreasing confidence
[sc,si]=sort(-confidence);
BB=BB(:,si);
detBoxIds = detBoxIds(si);

% assign detections to ground truth objects
nd=length(confidence);
tp=zeros(nd,1);
fp=zeros(nd,1);
tic;
for d=1:nd
    
    % find ground truth image
    i = find(gtIds==detBoxIds(d));
    if isempty(i)
        fp(d)=1;  % false positive
        continue;
    elseif length(i)>1
        error('multiple image "%d"',detBoxIds(i));
    end

    % assign detection to ground truth object if any
    bb=BB(:,d);
    ovmax=-inf;
    for j=1:size(gt(i).BB,2)
        bbgt=gt(i).BB(:,j);
        bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
        if iw>0 && ih>0                
            % compute overlap as area of intersection / area of union
            ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
               (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
               iw*ih;
            ov=iw*ih/ua;
            if ov>ovmax
                ovmax=ov;
                jmax=j;
            end
        end
    end
    % assign detection as true positive/don't care/false positive
    if ovmax>=IOU_ratio
        if ~gt(i).diff(jmax)
            if ~gt(i).det(jmax)
                tp(d)=1;            % true positive
		gt(i).det(jmax)=true;
            else
                fp(d)=1;            % false positive (multiple detection)
            end
        end
    else
        fp(d)=1;                    % false positive
    end
end

% compute precision/recall
fp=cumsum(fp);
tp=cumsum(tp);
rec=tp/npos;
prec=tp./(fp+tp);

% compute average precision

ap=0;
for t=0:0.1:1
    p=max(prec(rec>=t));
    if isempty(p)
        p=0;
    end
    ap=ap+p/11;
end

if draw
    % plot precision/recall
    plot(rec,prec,'-');
    grid;
    xlabel 'recall'
    ylabel 'precision'
    title(sprintf('IOU %.2f',IOU_ratio));
end
