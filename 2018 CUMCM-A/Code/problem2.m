clc;
clear;

p = [300 862 74.2 1.18];
c = [1377 2100 1726 1005];
lambda = [0.082 0.37 0.045 0.028];
d = [0.0006 0.006 0.0036 0.0055];
for d2 = 180 : 190
    d(2) = d2 / 10000;
    d_all = sum(d);         % �Ĳ���Ϻ�Ⱥ�
    d_three = sum(d(1:3));  % ��������Ϻ�Ⱥ�
    d_two = sum(d(1:2));
    a = lambda ./ (p .* c);
    dt = 0.01;         % ʱ�䲽��1s
    dx = 0.0001;    % �ռ䲽��0.1mm
    n_one = int32(d(1) / dx);
    n_two = int32(d_two / dx);
    n_three = int32(d_three / dx);
    h1 = 108.0292;
    h2 = 12.6749;    % ��IV�㣬������������ϵ��
    t0 = 65;         % �����¶�Ϊ65
    % ��ʼ��
    time_all = 3601;
    t = 37 * ones(100 * time_all + 10, n_three + 2);   % ���Ĳ����һ���������
    t = [t0 * ones(100 * time_all + 10, 1), t];               % ���߽��ʼt0��C
    % ���޲�ַ�
    for i = 1 : 100 * time_all
        t_next = 37 * ones(1, size(t, 2));
        t_next(1) = t(i, 1)*(1 - 2*h1*dt/(p(1)*c(1)*dx) - 2*a(1)*dt/dx^2) + 2*a(1)*dt*t(i, 2)/dx^2 + 2*h1*dt*t0/(p(1)*c(1)*dx);
        for n = 2 : n_one                                   % ��һ��
            t_next(n) = a(1)*dt/(dx^2)*(t(i, n+1) + t(i, n-1)) + (1 - 2*a(1)*dt/(dx^2))*t(i, n);
        end
        t_next(1 + n_one) = t(i, 1 + n_one) + 2*dt*(lambda(1)*t(i, n_one) + lambda(2)*t(i, 2 + n_one) - (lambda(1) + lambda(2))*t(i, 1 + n_one)) / (dx^2 * (p(1)*c(1) + p(2)*c(2)));

        for n = 2 + n_one : n_two              % �ڶ���
            t_next(n) = a(2)*dt/(dx^2)*(t(i, n+1) + t(i, n-1)) + (1 - 2*a(2)*dt/(dx^2))*t(i, n);
        end
        t_next(1 + n_two) = t(i, 1 + n_two) + 2*dt*(lambda(2)*t(i, n_two) + lambda(3)*t(i, 2 + n_two) - (lambda(2) + lambda(3))*t(i, 1 + n_two)) / (dx^2 * (p(2)*c(2) + p(3)*c(3)));

        for n = 2 + n_two : n_three            % ������
            t_next(n) = a(3)*dt/(dx^2)*(t(i, n+1) + t(i, n-1)) + (1 - 2*a(3)*dt/(dx^2))*t(i, n);
        end
    %   t_next(103) = t(i, 103)*(1 - 2*h2*dt/(p(3)*c(3)*dx) - 2*a(3)*dt/dx^2) + 2*a(3)*dt*t(i, 102)/dx^2 + 2*h2*dt*37/(p(3)*c(3)*dx);
        t_next(1 + n_three) = t(i, 1 + n_three)*(1 - 2*h2*dt/(p(3)*c(3)*dx) - 2*a(3)*dt/dx^2) + 2*a(3)*dt*t(i, n_three)/dx^2 + 2*h2*dt*t(i, 2 + n_three)/(p(3)*c(3)*dx);

        % ���Ĳ�
        t_next(2 + n_three) = t(i, 2 + n_three) + h2*dt*(t(i, 1 + n_three) + t(i, 3 + n_three) - 2*t(i, 2 + n_three)) / (50*p(4)*c(4)*dx);

        t(i+1, :) = t_next;     % Ԥ�ȷ����ڴ�����
    end
    if(t(100 * 3301, end - 1) <= 44 && t(100 * 3601, end - 1) <= 47)
        break;
    end
end

disp(d(2));

res = zeros(time_all, 1);
for i = 1 : length(res)
    res(i) = t(i*100 - 99, end - 1);
end
res = [res; t(100 * time_all, end - 1)];
% xlswrite("result.xlsx", t, 1);
xlswrite('result.xlsx', res, 6, 'A2');
