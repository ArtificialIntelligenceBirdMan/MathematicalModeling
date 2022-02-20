% 可能需要先运行其他模块文件代码
% 可能要先运行一次之后，第二次会求出更精确的结果
% 首先计算一系列全局变量
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

% % % 作极坐标图
% theta = 0:0.01:2*pi;
% plot(ppval(Rpp, theta) .* cos(theta), ppval(Rpp, theta) .* sin(theta), '-');
% title('\fontsize{15}凸轮边缘曲线');
% grid on;

% % % 这里作压强随密度变化曲线
% ro = 0.81:0.001:0.88;
% plot(ro, p_ro(ro), '-');
% xlabel('密度ρ(mg/mm^3)');
% ylabel('压强p(MPa)');
% title('\fontsize{15}燃油压强随密度变化关系图');
% grid on;


% % % 稳定在100
% global roh;
% roh = 0.8711;         % 0.8711
% end3 = 0.282;          % 注：调整这个值来设定开启时间，单位ms
% tscale = 8000;        % 注： 调整这个值来设定积分区间，单位ms
% tend = p1_t(tscale, [0, end3]);
% hold on;
% xlabel('时间t(ms)');
% ylabel('压强p(MPa)');
% title('\fontsize{15}燃油压强随时间变化关系图');
% grid on;

% % % 稳定在100 细致解
% global roh;
% roh = 0.8711;         % 0.8711
% end3 = 0.28;          % 注：调整这个值来设定开启时间，单位ms
% tscale = 200;        % 注： 调整这个值来设定积分区间，单位ms
% tend = p1_t(tscale, [0, end3]);
% hold on;
% xlabel('时间t(ms)');
% ylabel('压强p(MPa)');
% title('\fontsize{15}燃油压强随时间变化关系图');
% grid on;

% % % 稳定在150
% global roh;
% roh = 0.8711;         % 0.8711
% end3 = 0.75;          % 注：调整这个值来设定开启时间，单位ms
% tscale = 5000;        % 注：调整这个值来设定积分区间，单位ms
% tend = p1_t_ro0(0, tscale, [0, end3], 0.8679); %这里要设定初始密度为0.8679而非0.85
% hold on;
% xlabel('时间t(ms)');
% ylabel('压强p(MPa)');
% title('\fontsize{15}燃油压强随时间变化关系图');
% grid on;

% 两秒内到150
% global roh;
% roh = 0.8711;          
% end3 = 0.87;          % 注：调整这个值来设定开启时间，单位ms
% tscale = 5000;        % 注： 调整这个值来设定积分区间，单位ms
% tend = p1_t(tscale, [0, end3]);
% hold on;
% xlabel('时间t(ms)');
% ylabel('压强p(MPa)');
% title('\fontsize{15}燃油压强随时间变化关系图');
% grid on;

% 2s内到150MPa的两张图的拼接部分
% global roh;
% roh = 0.8711;          
% end3 = 0.87;          % 注：调整这个值来设定开启时间，单位ms
% tscale = 2000;        % 注： 调整这个值来设定积分区间，单位ms
% tend = p1_t(tscale, [0, end3]);
% end3 = 0.75;
% tend = p1_t_ro0(tscale, tscale, [0, end3], 0.8679);
% hold on;
% xlabel('时间t(ms)');
% ylabel('压强p(MPa)');
% title('\fontsize{15}燃油压强随时间变化关系图');
% grid on;

% 五秒内到150
% global roh;
% roh = 0.8711;      % 0.8711
% end3 = 0.72;          % 注：调整这个值设定进油
% tscale = 6000;        % 注： 调整这个值来设定积分区间，单位ms
% tend = p1_t(tscale, [0, end3]);
% hold on;
% xlabel('时间t(ms)');
% ylabel('压强p(MPa)');
% title('\fontsize{15}燃油压强随时间变化关系图');
% grid on;

% 5s内到150MPa的两张图的拼接部分
% global roh;
% roh = 0.8711;          
% end3 = 0.72;          % 注：调整这个值来设定开启时间，单位ms
% tscale = 5000;        % 注： 调整这个值来设定积分区间，单位ms
% tend = p1_t(tscale, [0, end3]);
% end3 = 0.75;
% tend = p1_t_ro0(tscale, 2000, [0, end3], 0.8679);
% hold on;
% xlabel('时间t(ms)');
% ylabel('压强p(MPa)');
% title('\fontsize{15}燃油压强随时间变化关系图');
% grid on;

% 十秒内到150
% global roh;
% roh = 0.8711;      % 0.8711
% end3 = 0.68;           % 注：调整这个值设定进油
% tscale = 11000;        % 注： 调整这个值来设定积分区间，单位ms
% tend = p1_t(tscale, [0, end3]);
% hold on;
% xlabel('时间t(ms)');
% ylabel('压强p(MPa)');
% title('\fontsize{15}燃油压强随时间变化关系图');
% grid on;

% 10s内到150MPa的两张图的拼接部分
% global roh;
% roh = 0.8711;          
% end3 = 0.68;          % 注：调整这个值来设定开启时间，单位ms
% tscale = 10000;        % 注： 调整这个值来设定积分区间，单位ms
% tend = p1_t(tscale, [0, end3]);
% end3 = 0.75;
% tend = p1_t_ro0(tscale, 2000, [0, end3], 0.8679);
% hold on;
% xlabel('时间t(ms)');
% ylabel('压强p(MPa)');
% title('\fontsize{15}燃油压强随时间变化关系图');
% grid on;

% % %  下面是第二问的结果的作图
% % %  注：在这里设置角速度w的值，w=2*pi/50时，凸轮周期为50ms
% % %  所以修改下面这一项（可以只修改减号后的值，也可以直接改）
% % w = 2*pi/50 - 0.0948;
% < 0.0303
% w = 0.0300;        % 表示角速度为30rad/s
% %  注：在这里设置总积分区间tall，tall=5000表示运行5000ms并打印图像
% tall = 42000;
% p2_t(tall, w);
% hold on;
% plot([0, tall], [100, 100], '-', 'LineWidth', 3);
% xlabel('时间t(ms)');
% ylabel('压强p(MPa)');
% title('\fontsize{15}燃油压强随时间变化关系图（角速度为31rad/s）');
% hold off;

% % % 下面是第三问前半问的作图
% % %  注：在这里设置角速度w的值，w=2*pi/50时，凸轮周期为50ms
% % %  所以修改下面这一项（可以只修改减号后的值，也可以直接改）
% w = 2*pi/50 - 0.2;
% w = 0.0500;        % 表示角速度为50rad/s
% % %  注：在这里设置总积分区间tall，tall=5000表示运行5000ms并打印图像
% tall = 30000;
% p3_t(tall, w, [50, 50]);
% hold on;
% plot([0, tall], [100, 100], '-', 'LineWidth', 3);
% xlabel('时间t(ms)');
% ylabel('压强p(MPa)');
% title('\fontsize{15}燃油压强随时间变化关系图（角速度为31rad/s）');
% hold off;

% % % 如果不用分段法，直接龙格库塔积分结果
% tspan = 0:0.01:500;
% dspan = [0, 0.28];
% V = 500 * pi * 5^2;     % 高压油管体积
% A = pi * 0.7^2;         % 小孔面积
% sol = ode45(@(t,ro) ((decide2(t,dspan)*C*A*sqrt(2*ro*(160-p_ro(ro)))...
%         - ro*Q1(t)) / V), tspan, ro0);
% plot(tspan, p_ro(deval(sol, tspan)), '-');
% xlabel('时间t(ms)');
% ylabel('压强p(MPa)');
% title('\fontsize{15}燃油压强随时间变化关系图（不分段求解）');

% % 作Q(t)图
% t = 0:0.01:5;
% q = zeros(size(t));
% for k = 1:length(t)
%     q(k) = Qrt(t(k), 0.85);
% end
% plot(t, q, '-');
% xlabel('时间t(ms)');
% ylabel('流量Q(mm^3/ms)');
% title('\fontsize{15}流量随时间变化关系图');

% 第三问后半问，只考虑一个周期内的情况
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

