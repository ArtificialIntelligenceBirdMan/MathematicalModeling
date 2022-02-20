clc;    clear;
% 对E作三次样条插值
data_E = xlsread("附件3-弹性模量与压力.xlsx", 1, "A2:B402");
Epp = csape(data_E(:, 1), data_E(:, 2));

% 求解ρ关于p的数值解
p0 = 100;
ro0 = 0.85;
pspan1 = [100 0];
pspan2 = [100 200];
global psol1;
global psol2;
psol1 = ode45(@(p,ro) (ro / ppval(Epp, p)), pspan1, ro0);
psol2 = ode45(@(p,ro) (ro / ppval(Epp, p)), pspan2, ro0);

% 求解p关于ρ的数值解
rospan1 = [0.85, 0.88]; 
rospan2 = [0.85, 0.8];
global sol1;
global sol2;
sol1 = ode45(@(ro,p) (ppval(Epp, p) / ro), rospan2, p0);
sol2 = ode45(@(ro,p) (ppval(Epp, p) / ro), rospan1, p0);

% 对针阀运动作插值
data_h1 = xlsread("附件2-针阀运动曲线.xlsx", 1, "A2:B46");
data_h2 = xlsread("附件2-针阀运动曲线.xlsx", 1, "D2:E46");
data_h1 = [data_h1;0.45, 2];
data_h = [data_h1;data_h2];
global hpp;
hpp = csape(data_h(:, 1), data_h(:, 2));
global d1;
global d0;
d1 = 2.5;   d0 = 1.4;

global Ad;  % 减压阀面积
Ad = pi * 0.7^2;
global t0;
t0 = 0.33135;
global t1;
t1 = 2.11814;

data_R = xlsread("附件1-凸轮边缘曲线.xlsx", 1, "A2:B629");
global Rpp;
Rpp = csape(data_R(:, 1), data_R(:, 2));
global dR;
dR = fnder(Rpp,1);  % 一阶导数
global L0;  % 表示参与部分的高度
L0 = 20 / (pi * 2.5^2);
global m1;  % m1表示油泵内最大可能存油质量
m1 = ro_p(0.5) * V1_t(1, pi);
global S1;  % 油泵底面积
S1 = pi * 2.5^2;
global C;
C = 0.85;

% 下面求解问题三的常微分方程
% w = 2*pi / 25;   % 角速度
% tbegin = 0;
% tend = 100;
% tspan = tbegin:0.01:tend;
% ro0 = 0.85;
% V = 500 * pi * 5^2;     % 高压油管体积
% dspan = [45 50];
% sol = ode23t(@(t,ro) (F_in(t,w,ro) - F_out(t,ro,dspan) - ro * Qrt2(t,ro))/(V + V1_t(t,w)), tspan, ro0);
% plot(tspan, p_ro(deval(sol, tspan)), '-');

% 先求解第三问前半问，相当于喷油周期变为50ms
% 这里求出的结果不是第二问的2倍，而是要少一些
% 原因是进油时高压油管内压强较第二问时更小，因此每次进油其实更多了
% w = 2*pi / 50 - 0.074;
% ted = 2000;
% dspan = [50 50];
% res = p3_t(ted, w, dspan);
% grid on;
% xlabel('时间t(ms)');
% ylabel('压强p(MPa)');
% title('\fontsize{15}内燃油压强随时间变化关系图（两个喷嘴）');

% 然后是后半问，只考虑一个周期内的情况
% % % 下面首先考虑50ms内进油一次的情况
% % % 注：这里调整油泵的周期，即50ms内进油的次数N
% N = 1;
% % 注：这里调整减压阀开始的时刻jT，即50ms内减压阀开启区间为[jT, 50)
% jT = 47.6;
% % jT = 42.829;  
% w = 2*pi*N / 50;
% ted = 50;
% % dspan = [42.829 50];
% dspan = [jT 50]; 
% res = p3_t(ted, w, dspan);
% grid on;
% xlabel('时间t(ms)');
% ylabel('压强p(MPa)');
% title('\fontsize{15}一个周期（50ms）内燃油压强随时间变化关系图（角速度125.7rad/s,减压阀开启时间为47.6-50ms）');

% % % 下面考虑50ms内进油两次的情况
% % % 注：这里调整油泵的周期
% N = 2;
% % % 注：这里调整减压阀开始的时刻jT，即50ms内减压阀开启区间为[jT, 50)
% jT = 42.829;  
% w = 2*pi*N / 50;
% ted = 50;
% dspan = [jT 50]; 
% res = p3_t(ted, w, dspan);
% grid on;
% xlabel('时间t(ms)');
% ylabel('压强p(MPa)');
% title('\fontsize{15}一个周期（50ms）内燃油压强随时间变化关系图（角速度251.3rad/s,减压阀开启时间为42.829-50ms）');

% % % 下面考虑50ms内进油3次的情况
% % % 注：这里调整油泵的周期
% N = 3;
% % % % 注：这里调整减压阀开始的时刻jT，即50ms内减压阀开启区间为[jT, 50)
% jT = 39.168;  
% w = 2*pi*N / 50;
% ted = 50;
% dspan = [jT 50]; 
% res = p3_t(ted, w, dspan);
% grid on;
% xlabel('时间t(ms)');
% ylabel('压强p(MPa)');
% title('\fontsize{15}一个周期（50ms）内燃油压强随时间变化关系图（角速度377.0rad/s,减压阀开启时间为39.168-50ms）');

