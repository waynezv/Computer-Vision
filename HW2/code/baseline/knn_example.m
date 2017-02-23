clear all;
close all;
clc;

%%?????????
mu1=[0 0];  %??
S1=[0.3 0;0 0.35];  %???
data1=mvnrnd(mu1,S1,100);   %????????
plot(data1(:,1),data1(:,2),'+');
label1=ones(100,1);
hold on;

%%?????????
mu2=[1.25 1.25];
S2=[0.3 0;0 0.35];
data2=mvnrnd(mu2,S2,100);
plot(data2(:,1),data2(:,2),'ro');
label2=label1+1;

data=[data1;data2];
label=[label1;label2];

K=11;   %????K?????????????????
%?????KNN???????????
for ii=-3:0.1:3
    for jj=-3:0.1:3
        test_data=[ii jj];  %????
        label=[label1;label2];
        %%????KNN????????11NN?
        %??????????????????????????? 
        distance=zeros(200,1);
        for i=1:200
            distance(i)=sqrt((test_data(1)-data(i,1)).^2+(test_data(2)-data(i,2)).^2);
        end

        %?????????????K???,???????????
        for i=1:K
            ma=distance(i);
            for j=i+1:200
                if distance(j)<ma
                    ma=distance(j);
                    label_ma=label(j);
                    tmp=j;
                end
            end
            distance(tmp)=distance(i);  %???
            distance(i)=ma;

            label(tmp)=label(i);        %??????????
            label(i)=label_ma;
        end

        cls1=0; %???1????????????
        for i=1:K
           if label(i)==1
               cls1=cls1+1;
           end
        end
        cls2=K-cls1;    %?2????????????
        
        if cls1>cls2    
           plot(ii,jj);     %???1???????
        end
        
    end
end

function [dists,neighbors] = top_K_neighbors( X_train,y_train,X_test,K )
% Author: Ren Kan
%   Input: 
%   X_test the test vector with P*1
%   X_train and y_train are the train data set
%   K is the K neighbor parameter
[~, N_train] = size(X_train);
test_mat = repmat(X_test,1,N_train);
dist_mat = (X_train-double(test_mat)) .^2;
% The distance is the Euclid Distance.
dist_array = sum(dist_mat);
[dists, neighbors] = sort(dist_array);
% The neighbors are the index of top K nearest points.
dists = dists(1:K);
neighbors = neighbors(1:K);

end

function result = recog( K_labels,class_num )  
%RECOG Summary of this function goes here  
%   Author: Ren Kan  
[~,K] = size(K_labels);  
class_count = zeros(1,class_num+1);  
for i=1:K  
    class_index = K_labels(i)+1; % +1 is to avoid the 0 index reference.  
    class_count(class_index) = class_count(class_index) + 1;  
end  
[~,result] = max(class_count);  
result = result - 1; % Do not forget -1 !!!  
  
end  