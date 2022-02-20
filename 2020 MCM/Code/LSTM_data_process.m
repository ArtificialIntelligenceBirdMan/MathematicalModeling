
function [train_data,test_data]=LSTM_data_process(numdely)
 
load('DATA.mat');
[ttt,numdata] = size(a);
numsample = numdata - numdely - 1;
train_data = zeros(numdely+1, numsample);
test_data = zeros(numdely+1,1);
 
for i = 1 :numsample
    train_data(:,i) = a(i:i+numdely)';
end
test_data = a(numdata-numdely: numdata);
data_length=size(train_data,1);          
data_num=size(train_data,2);           
% 
%%归一化过程
for n=1:data_num
    train_data(:,n)=train_data(:,n)/sqrt(sum(train_data(:,n).^2));  
end
% for m=1:size(test_data,2)
%     test_data(:,m)=test_data(:,m)/sqrt(sum(test_data(:,m).^2));
