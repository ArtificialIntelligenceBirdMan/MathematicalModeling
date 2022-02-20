clc; clear;
data_E = xlsread("附件3-弹性模量与压力.xlsx", 1, "A2:B402");
Epp = csape(data_E(:, 1), data_E(:, 2));
% fnplt(Epp);
rospan1 = [0.85, 0.88]; 
rospan2 = [0.85, 0.8];
p0 = 100;
[ro1,p1] = ode45(@(ro,p) (ppval(Epp, p) / ro), rospan1, p0);   % 这里不能有0.85!
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

% 下面计算第一问的密度和压强在决策方案(a, b)下关于时间的表达式
tend = 10;
tspan = [0 tend];       % 积分区间
ro0 = 0.85;             % 初始压强为100MPa，则密度为0.85
dend_l = 4;
dend_u = 8;
dspan = [3, (dend_l + dend_u) / 2];         % 进油的时间区间
C = 0.85;               % 流量系数
V = 500 * pi * 5^2;     % 高压油管体积
A = pi * 0.7^2;         % 小孔面积
global roh;     % 高压侧密度
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
% % 方案1，先出油后进油，时间错开
% er = 1;
% while(abs(er) > 0.1)
%     dspan = [3, (dend_l + dend_u) / 2];         % 进油的时间区间
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

% 方案2，出油和进油同时进行
% dend_l = 1;
% dend_u = 5;
% dspan = [0, (dend_l + dend_u) / 2];         % 进油的时间区间
% er = 1;
% while(abs(er) > 0.1)
%     dspan = [0, (dend_l + dend_u) / 2];         % 进油的时间区间
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

% 第一问后半
% p_t(17000, [0, 17000])

% 求第一问前半
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
    