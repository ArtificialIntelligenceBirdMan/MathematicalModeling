clc;    clear;
% ��E������������ֵ
data_E = xlsread("����3-����ģ����ѹ��.xlsx", 1, "A2:B402");
Epp = csape(data_E(:, 1), data_E(:, 2));

% ���ѹ���p����ֵ��
p0 = 100;
ro0 = 0.85;
pspan1 = [100 0];
pspan2 = [100 200];
global psol1;
global psol2;
psol1 = ode45(@(p,ro) (ro / ppval(Epp, p)), pspan1, ro0);
psol2 = ode45(@(p,ro) (ro / ppval(Epp, p)), pspan2, ro0);

% ���p���ڦѵ���ֵ��
rospan1 = [0.85, 0.88]; 
rospan2 = [0.85, 0.8];
global sol1;
global sol2;
sol1 = ode45(@(ro,p) (ppval(Epp, p) / ro), rospan2, p0);
sol2 = ode45(@(ro,p) (ppval(Epp, p) / ro), rospan1, p0);

% ���뷧�˶�����ֵ
data_h1 = xlsread("����2-�뷧�˶�����.xlsx", 1, "A2:B46");
data_h2 = xlsread("����2-�뷧�˶�����.xlsx", 1, "D2:E46");
data_h1 = [data_h1;0.45, 2];
data_h = [data_h1;data_h2];
global hpp;
hpp = csape(data_h(:, 1), data_h(:, 2));
global d1;
global d0;
d1 = 2.5;   d0 = 1.4;

global Ad;  % ��ѹ�����
Ad = pi * 0.7^2;
global t0;
t0 = 0.33135;
global t1;
t1 = 2.11814;

data_R = xlsread("����1-͹�ֱ�Ե����.xlsx", 1, "A2:B629");
global Rpp;
Rpp = csape(data_R(:, 1), data_R(:, 2));
global dR;
dR = fnder(Rpp,1);  % һ�׵���
global L0;  % ��ʾ���벿�ֵĸ߶�
L0 = 20 / (pi * 2.5^2);
global m1;  % m1��ʾ�ͱ��������ܴ�������
m1 = ro_p(0.5) * V1_t(1, pi);
global S1;  % �ͱõ����
S1 = pi * 2.5^2;
global C;
C = 0.85;

% ��������������ĳ�΢�ַ���
% w = 2*pi / 25;   % ���ٶ�
% tbegin = 0;
% tend = 100;
% tspan = tbegin:0.01:tend;
% ro0 = 0.85;
% V = 500 * pi * 5^2;     % ��ѹ�͹����
% dspan = [45 50];
% sol = ode23t(@(t,ro) (F_in(t,w,ro) - F_out(t,ro,dspan) - ro * Qrt2(t,ro))/(V + V1_t(t,w)), tspan, ro0);
% plot(tspan, p_ro(deval(sol, tspan)), '-');

% ����������ǰ���ʣ��൱���������ڱ�Ϊ50ms
% ��������Ľ�����ǵڶ��ʵ�2��������Ҫ��һЩ
% ԭ���ǽ���ʱ��ѹ�͹���ѹǿ�ϵڶ���ʱ��С�����ÿ�ν�����ʵ������
% w = 2*pi / 50 - 0.074;
% ted = 2000;
% dspan = [50 50];
% res = p3_t(ted, w, dspan);
% grid on;
% xlabel('ʱ��t(ms)');
% ylabel('ѹǿp(MPa)');
% title('\fontsize{15}��ȼ��ѹǿ��ʱ��仯��ϵͼ���������죩');

% Ȼ���Ǻ���ʣ�ֻ����һ�������ڵ����
% % % �������ȿ���50ms�ڽ���һ�ε����
% % % ע����������ͱõ����ڣ���50ms�ڽ��͵Ĵ���N
% N = 1;
% % ע�����������ѹ����ʼ��ʱ��jT����50ms�ڼ�ѹ����������Ϊ[jT, 50)
% jT = 47.6;
% % jT = 42.829;  
% w = 2*pi*N / 50;
% ted = 50;
% % dspan = [42.829 50];
% dspan = [jT 50]; 
% res = p3_t(ted, w, dspan);
% grid on;
% xlabel('ʱ��t(ms)');
% ylabel('ѹǿp(MPa)');
% title('\fontsize{15}һ�����ڣ�50ms����ȼ��ѹǿ��ʱ��仯��ϵͼ�����ٶ�125.7rad/s,��ѹ������ʱ��Ϊ47.6-50ms��');

% % % ���濼��50ms�ڽ������ε����
% % % ע����������ͱõ�����
% N = 2;
% % % ע�����������ѹ����ʼ��ʱ��jT����50ms�ڼ�ѹ����������Ϊ[jT, 50)
% jT = 42.829;  
% w = 2*pi*N / 50;
% ted = 50;
% dspan = [jT 50]; 
% res = p3_t(ted, w, dspan);
% grid on;
% xlabel('ʱ��t(ms)');
% ylabel('ѹǿp(MPa)');
% title('\fontsize{15}һ�����ڣ�50ms����ȼ��ѹǿ��ʱ��仯��ϵͼ�����ٶ�251.3rad/s,��ѹ������ʱ��Ϊ42.829-50ms��');

% % % ���濼��50ms�ڽ���3�ε����
% % % ע����������ͱõ�����
% N = 3;
% % % % ע�����������ѹ����ʼ��ʱ��jT����50ms�ڼ�ѹ����������Ϊ[jT, 50)
% jT = 39.168;  
% w = 2*pi*N / 50;
% ted = 50;
% dspan = [jT 50]; 
% res = p3_t(ted, w, dspan);
% grid on;
% xlabel('ʱ��t(ms)');
% ylabel('ѹǿp(MPa)');
% title('\fontsize{15}һ�����ڣ�50ms����ȼ��ѹǿ��ʱ��仯��ϵͼ�����ٶ�377.0rad/s,��ѹ������ʱ��Ϊ39.168-50ms��');

