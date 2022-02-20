clc;    clear;
data_E = xlsread("附件3-弹性模量与压力.xlsx", 1, "A2:B402");
Epp = csape(data_E(:, 1), data_E(:, 2));

p0 = 100;
ro0 = 0.85;
pspan1 = [100 0];
pspan2 = [100 200];
global psol1;
global psol2;
psol1 = ode45(@(p,ro) (ro / ppval(Epp, p)), pspan1, ro0);
psol2 = ode45(@(p,ro) (ro / ppval(Epp, p)), pspan2, ro0);

rospan1 = [0.85, 0.88]; 
rospan2 = [0.85, 0.8];
global sol1;
global sol2;
sol1 = ode45(@(ro,p) (ppval(Epp, p) / ro), rospan2, p0);
sol2 = ode45(@(ro,p) (ppval(Epp, p) / ro), rospan1, p0);

data_h1 = xlsread("附件2-针阀运动曲线.xlsx", 1, "A2:B46");
data_h2 = xlsread("附件2-针阀运动曲线.xlsx", 1, "D2:E46");
data_h1 = [data_h1;0.45, 2];
data_h = [data_h1;data_h2];
global hpp;
hpp = csape(data_h(:, 1), data_h(:, 2));
% fnplt(hpp);
global d1;
global d0;
d1 = 2.5;   d0 = 1.4;
h0 = (sqrt(d1^2 + d0^2) - d1) / (2 * tan(pi/20));
% 通过下面的二分法可求得t0 = 0.33135
% er = 1;
% lt = 0.3;    rt = 0.4;
% while(abs(er) > 0.001)
%     mid = (lt + rt) / 2;
%     er = h0 - ppval(hpp, mid);
%     if(er > 0)
%         lt = mid;
%     else
%         rt = mid;
%     end
% end
global t0;
t0 = 0.33135;
% 通过下面的二分法可求得t1 = 2.1182
er = 1;
lt = 2.1;    rt = 2.2;
while(abs(er) > 0.001)
    mid = (lt + rt) / 2;
    er = h0 - ppval(hpp, mid);
    if(er < 0)
        lt = mid;
    else
        rt = mid;
    end
end
global t1;
t1 = mid;

data_R = xlsread("附件1-凸轮边缘曲线.xlsx", 1, "A2:B629");
global Rpp;
Rpp = csape(data_R(:, 1), data_R(:, 2));
% fnplt(Rpp);
global dR;
dR = fnder(Rpp,1);  % 一阶导数
% fnplt(dR);
% ppval(dR, 0);
global L0;  % 表示参与部分的高度
L0 = 20 / (pi * 2.5^2);
global m1;  % m1表示油泵内最大可能存油质量
m1 = ro_p(0.5) * V1_t(1, pi);
global S1;  % 油泵底面积
S1 = pi * 2.5^2;
global C;
C = 0.85;

% 下面求解问题二的常微分方程
% w = 2*pi / 50;   % 角速度
% tbegin = 0;
% tend = 80;
% tspan = tbegin:0.01:tend;
% ro0 = 0.85;
% V = 500 * pi * 5^2;     % 高压油管体积
% sol = ode23t(@(t,ro) (F_in(t,w,ro) - ro * Qrt(t,ro))/(V + V1_t(t,w)), tspan, ro0);
% plot(tspan, p_ro(deval(sol, tspan)), '-');

% % %  注：在这里设置角速度w的值，w=2*pi/50时，凸轮周期为50ms
w = 2*pi/50 - 0.07;
% % %  注：在这里设置总积分区间tall，tall=5000表示运行5000ms并打印图像
tall = 5000;
p2_t(tall, w);
hold on;
plot([0, tall], [100, 100], '-', 'LineWidth', 3);
hold off;