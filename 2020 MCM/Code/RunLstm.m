function [r1, r2] = RunLstm(numdely,cell_num,cost_gate)
%% 数据加载，并归一化处理
figure;
[train_data,test_data]=LSTM_data_process(numdely);
data_length=size(train_data,1)-1;
data_num=size(train_data,2);
%% 网络参数初始化
% 结点数设置
input_num=data_length;
% cell_num=5;
output_num=1;
% 网络中门的偏置
bias_input_gate=rand(1,cell_num);
bias_forget_gate=rand(1,cell_num);
bias_output_gate=rand(1,cell_num);
%网络权重初始化
ab=20;
weight_input_x=rand(input_num,cell_num)/ab;
weight_input_h=rand(output_num,cell_num)/ab;
weight_inputgate_x=rand(input_num,cell_num)/ab;
weight_inputgate_c=rand(cell_num,cell_num)/ab;
weight_forgetgate_x=rand(input_num,cell_num)/ab;
weight_forgetgate_c=rand(cell_num,cell_num)/ab;
weight_outputgate_x=rand(input_num,cell_num)/ab;
weight_outputgate_c=rand(cell_num,cell_num)/ab;
%hidden_output权重
weight_preh_h=rand(cell_num,output_num);
%网络状态初始化
% cost_gate=0.25;
h_state=rand(output_num,data_num);
cell_state=rand(cell_num,data_num);
%% 网络训练学习
for iter=1:100
    yita=0.01;            %每次迭代权重调整比例
    for m=1:data_num
        %前馈部分
        if(m==1)
            gate=tanh(train_data(1:input_num,m)'*weight_input_x);
            input_gate_input=train_data(1:input_num,m)'*weight_inputgate_x+bias_input_gate;
            output_gate_input=train_data(1:input_num,m)'*weight_outputgate_x+bias_output_gate;
            for n=1:cell_num
                input_gate(1,n)=1/(1+exp(-input_gate_input(1,n)));
                output_gate(1,n)=1/(1+exp(-output_gate_input(1,n)));
            end
            forget_gate=zeros(1,cell_num);
            forget_gate_input=zeros(1,cell_num);
            cell_state(:,m)=(input_gate.*gate)';
        else
            gate=tanh(train_data(1:input_num,m)'*weight_input_x+h_state(:,m-1)'*weight_input_h);
            input_gate_input=train_data(1:input_num,m)'*weight_inputgate_x+cell_state(:,m-1)'*weight_inputgate_c+bias_input_gate;
            forget_gate_input=train_data(1:input_num,m)'*weight_forgetgate_x+cell_state(:,m-1)'*weight_forgetgate_c+bias_forget_gate;
            output_gate_input=train_data(1:input_num,m)'*weight_outputgate_x+cell_state(:,m-1)'*weight_outputgate_c+bias_output_gate;
            for n=1:cell_num
                input_gate(1,n)=1/(1+exp(-input_gate_input(1,n)));
                forget_gate(1,n)=1/(1+exp(-forget_gate_input(1,n)));
                output_gate(1,n)=1/(1+exp(-output_gate_input(1,n)));
            end
            cell_state(:,m)=(input_gate.*gate+cell_state(:,m-1)'.*forget_gate)';   
        end
        pre_h_state=tanh(cell_state(:,m)').*output_gate;
        h_state(:,m)=(pre_h_state*weight_preh_h)'; 
    end
    % 误差的计算
%     Error=h_state(:,m)-train_data(end,m);
    Error=h_state(:,:)-train_data(end,:);
    Error_Cost(1,iter)=sum(Error.^2);
    if Error_Cost(1,iter) < cost_gate
            iter
        break;
    end
                 [ weight_input_x,...
                weight_input_h,...
                weight_inputgate_x,...
                weight_inputgate_c,...
                weight_forgetgate_x,...
                weight_forgetgate_c,...
                weight_outputgate_x,...
                weight_outputgate_c,...
                weight_preh_h ]=LSTM_updata_weight(m,yita,Error,...
                                                   weight_input_x,...
                                                   weight_input_h,...
                                                   weight_inputgate_x,...
                                                   weight_inputgate_c,...
                                                   weight_forgetgate_x,...
                                                   weight_forgetgate_c,...
                                                   weight_outputgate_x,...
                                                   weight_outputgate_c,...
                                                   weight_preh_h,...
                                                   cell_state,h_state,...
                                                   input_gate,forget_gate,...
                                                   output_gate,gate,...
                                                   train_data,pre_h_state,...
                                                   input_gate_input,...
                                                   output_gate_input,...
                                                   forget_gate_input);


end
%% 绘制Error-Cost曲线图
for n=1:1:iter
    semilogy(n,Error_Cost(1,n),'*');
    hold on;
    title('Error-Cost曲线图');   
end
%% 数据检验
%数据加载
test_final=test_data;
test_final=test_final/sqrt(sum(test_final.^2));
total = sqrt(sum(test_data.^2));
test_output=test_data(:,end);
%前馈
m=data_num;
gate=tanh(test_final(1:input_num)'*weight_input_x+h_state(:,m-1)'*weight_input_h);
input_gate_input=test_final(1:input_num)'*weight_inputgate_x+cell_state(:,m-1)'*weight_inputgate_c+bias_input_gate;
forget_gate_input=test_final(1:input_num)'*weight_forgetgate_x+cell_state(:,m-1)'*weight_forgetgate_c+bias_forget_gate;
output_gate_input=test_final(1:input_num)'*weight_outputgate_x+cell_state(:,m-1)'*weight_outputgate_c+bias_output_gate;
for n=1:cell_num
    input_gate(1,n)=1/(1+exp(-input_gate_input(1,n)));
    forget_gate(1,n)=1/(1+exp(-forget_gate_input(1,n)));
    output_gate(1,n)=1/(1+exp(-output_gate_input(1,n)));
end
cell_state_test=(input_gate.*gate+cell_state(:,m-1)'.*forget_gate)';
pre_h_state=tanh(cell_state_test').*output_gate;
h_state_test=(pre_h_state*weight_preh_h)'* total;
test_output(end);
test = sprintf('----Test result is %s----' ,num2str(h_state_test));
true = sprintf('----True result is %s----' ,num2str(test_output(end)));
disp(test);
disp(true);
