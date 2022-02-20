clc; clear;
data_E = xlsread("����3-����ģ����ѹ��.xlsx", 1, "A2:B402");
Epp = csape(data_E(:, 1), data_E(:, 2));
% fnplt(Epp);
rospan1 = [0.85, 0.88]; 
rospan2 = [0.85, 0.8];
p0 = 100;
[ro1,p1] = ode45(@(ro,p) (ppval(Epp, p) / ro), rospan1, p0);   % ���ﲻ����0.85!
[ro2,p2] = ode45(@(ro,p) (ppval(Epp, p) / ro), rospan2, p0);
ro = [ro2(end:-1:1);ro1];
p = [p2(end:-1:1);p1];
% plot(ro, p, '-o');
global sol1;
global sol2;
sol1 = ode45(@(ro,p) (ppval(Epp, p) / ro), rospan2, p0);
% deval(sol1, 0.84)
sol2 = ode45(@(ro,p) (ppval(Epp, p) / ro), rospan1, p0);
% deval(sol2, 0.86)
% plot((0.5:0.001:1), p_ro((0.5:0.001:1)));

% ��������һ�ʵ��ܶȺ�ѹǿ�ھ��߷���(a, b)�¹���ʱ��ı��ʽ
tend = 10;
tspan = [0 tend];       % ��������
ro0 = 0.85;             % ��ʼѹǿΪ100MPa�����ܶ�Ϊ0.85
dend_l = 4;
dend_u = 8;
dspan = [3, (dend_l + dend_u) / 2];         % ���͵�ʱ������
C = 0.85;               % ����ϵ��
V = 500 * pi * 5^2;     % ��ѹ�͹����
A = pi * 0.7^2;         % С�����
global roh;     % ��ѹ���ܶ�
er = 1;
lp = 0.85;  rp = 0.88;
% while(abs(er) > 0.01)
%     mid = (lp + rp) / 2;
%     er = 160 - p_ro(mid);
%     if(er > 0)
%         lp = mid;
%     else
%         rp = mid;
%     end
% end
% roh = mid;      % 0.8711
% % ����1���ȳ��ͺ���ͣ�ʱ���
% er = 1;
% while(abs(er) > 0.1)
%     dspan = [3, (dend_l + dend_u) / 2];         % ���͵�ʱ������
%     sol = ode45(@(t,ro) ((decide1(t,dspan)*C*A*sqrt(2*ro*(160-p_ro(ro)))...
%         - ro*Q1(t)) / V), tspan, ro0);
%     er = 100 - p_ro(deval(sol, tend));
%     dend_l
%     dend_u
%     if(er > 0)
%         dend_l = (dend_l + dend_u) / 2;
%     else
%         dend_u = (dend_l + dend_u) / 2;
%     end
% end
% sol = ode45(@(t,ro) ((decide1(t,[3,6])*C*A*sqrt(2*ro*(160-p_ro(ro)))...
%         - ro*Q1(t)) / V), tspan, ro0);
% p_ro(deval(sol, tend))
% t = 0:0.01:tend;
% plot(t, deval(sol, t), '-o');
% plot(t, p_ro(deval(sol,t)), '-o');

% ����2�����ͺͽ���ͬʱ����
% dend_l = 1;
% dend_u = 5;
% dspan = [0, (dend_l + dend_u) / 2];         % ���͵�ʱ������
% er = 1;
% while(abs(er) > 0.1)
%     dspan = [0, (dend_l + dend_u) / 2];         % ���͵�ʱ������
%     sol = ode45(@(t,ro) ((decide1(t,dspan)*C*A*sqrt(2*ro*(160-p_ro(ro)))...
%         - ro*Q1(t)) / V), tspan, ro0);
%     er = 100 - p_ro(deval(sol, tend));
%     if(abs(er) < 0.1)
%         break;
%     end
%     if(er > 0)
%         dend_l = (dend_l + dend_u) / 2;
%     else
%         dend_u = (dend_l + dend_u) / 2;
%     end
% end
% p_ro(deval(sol, tend))
% t = 0:0.01:tend;
% plot(t, p_ro(deval(sol,t)), '-o');

% ��һ�ʺ��
% p_t(17000, [0, 17000])

% ���һ��ǰ��
end3 = 0.25;
tend = p_t(5000, [0, end3]);

er = 1;
lr = 0.85;  rr = 0.88;
% while(abs(er) > 0.1)
%     mid = (lr + rr) / 2;
%     er = 150 - p_ro(mid);
%     if(er > 0)
%         lr = mid;
%     else
%         rr = mid;
%     end
% end
% r150 = mid
r150 = 0.8679;
    