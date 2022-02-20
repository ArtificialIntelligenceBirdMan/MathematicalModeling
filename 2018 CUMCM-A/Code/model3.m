clc;
clear;
p = [300 862 74.2 1.18];
c = [1377 2100 1726 1005];
lambda = [0.082 0.37 0.045 0.028];
d = [0.0006 0.006 0.0036 0.005];
d_all = sum(d); % �Ĳ���Ϻ�Ⱥ�
a = lambda ./ (p .* c);
Sigma = sum(d(1:3) ./ lambda(1:3));
dt = 0.01;         % ʱ�䲽��1s
dx = 0.0001;    % �ռ䲽��0.1mm
t0 = 75.0;
t1 = 37.0;      % t1�Ǽ������̬ʱ���¶ȣ��������ǲ�õ���̬�¶�
t4 = 59.16;
t5 = 48.08;
t6 = 37.0;

% ��ʼ��
time_all = 1;
t =  112.4 * ones(100 * time_all, 1);
t = [t, 59.16 * ones(100 * time_all, 102), 48.08 * ones(100 * time_all, 1)];
times = 0;

while abs(t(100 * time_all, 1) - t1) > 0.0001
    % ��ʼ��
    if(times == 0)
        t1 = 73.7;
    else
%         t1 = t1 - 0.8 * (t1 - t(100 * time_all, 1));
        t1 = t(100 * time_all, 1);
    end
%     t4 = t(100 * time_all, 103);
%     t5 = t(100 * time_all, 104);
    h1 = (t1 - t4) / (Sigma * (t0 - t1));    % ����࣬������������ϵ��
    h2 = (t1 - t4) / (Sigma * (t5 - t6));    % ��IV�㣬������������ϵ��
    time_all = 10000;        % ����10000���Ӧ�������ȶ�
    t = 37 * ones(100 * time_all + 10, d_all / dx);
    t = [t0 * ones(100 * time_all + 10, 1), t];      % ���߽��ʼΪt0
%     h1 = 102;
%     h2 = 6.3;
    % ���޲�ַ�
    for i = 1 : 100 * time_all
        t_next = 37 * ones(1, size(t, 2));
        t_next(1) = t(i, 1)*(1 - 2*h1*dt/(p(1)*c(1)*dx) - 2*a(1)*dt/dx^2) + 2*a(1)*dt*t(i, 2)/dx^2 + 2*h1*dt*t0/(p(1)*c(1)*dx);
        for n = 2 : 6               % ��һ��
            t_next(n) = a(1)*dt/(dx^2)*(t(i, n+1) + t(i, n-1)) + (1 - 2*a(1)*dt/(dx^2))*t(i, n);
        end
        t_next(7) = t(i, 7) + 2*dt*(lambda(1)*t(i, 6) + lambda(2)*t(i, 8) - (lambda(1) + lambda(2))*t(i, 7)) / (dx^2 * (p(1)*c(1) + p(2)*c(2)));

        for n = 8 : 66              % �ڶ���
            t_next(n) = a(2)*dt/(dx^2)*(t(i, n+1) + t(i, n-1)) + (1 - 2*a(2)*dt/(dx^2))*t(i, n);
        end
        if(t(i, 66) > 37.0)
            t_next(67) = t(i, 67) + 2*dt*(lambda(2)*t(i, 66) + lambda(3)*t(i, 68) - (lambda(2) + lambda(3))*t(i, 67)) / (dx^2 * (p(2)*c(2) + p(3)*c(3)));
        else
            t_next(67) = 37;
        end

        for n = 68 : 102            % ������
            t_next(n) = a(3)*dt/(dx^2)*(t(i, n+1) + t(i, n-1)) + (1 - 2*a(3)*dt/(dx^2))*t(i, n);
        end
        if(t(i, 102) > 37.0)
            t_next(103) = t(i, 103)*(1 - 2*h2*dt/(p(3)*c(3)*dx) - 2*a(3)*dt/dx^2) + 2*a(3)*dt*t(i, 102)/dx^2 + 2*h2*dt*t(i, 104)/(p(3)*c(3)*dx);            
        else
            t_next(103) = 37;
        end

        % ���Ĳ�
        t_next(104) = t(i, 104) + h2*dt*(t(i, 103) + t(i, 105) - 2*t(i, 104)) / (50*p(4)*c(4)*dx);

        t(i+1, :) = t_next;     % Ԥ�ȷ����ڴ�����
    end
    times = times + 1;
    disp(t(100 * time_all, 1));
    disp(t(100 * time_all, 104));
end


res = zeros(time_all, 1);
for i = 1 : length(res)
    res(i) = t(i*100 - 99, 104);
end
res = [res; t(100 * time_all, 104)];
% xlswrite("result.xlsx", t, 1);
xlswrite("result.xlsx", res, 4, "A2");
