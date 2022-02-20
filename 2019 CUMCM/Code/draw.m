% ������Ҫ����������ģ���ļ�����
% ����Ҫ������һ��֮�󣬵ڶ��λ��������ȷ�Ľ��
% ���ȼ���һϵ��ȫ�ֱ���
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

% % % ��������ͼ
% theta = 0:0.01:2*pi;
% plot(ppval(Rpp, theta) .* cos(theta), ppval(Rpp, theta) .* sin(theta), '-');
% title('\fontsize{15}͹�ֱ�Ե����');
% grid on;

% % % ������ѹǿ���ܶȱ仯����
% ro = 0.81:0.001:0.88;
% plot(ro, p_ro(ro), '-');
% xlabel('�ܶȦ�(mg/mm^3)');
% ylabel('ѹǿp(MPa)');
% title('\fontsize{15}ȼ��ѹǿ���ܶȱ仯��ϵͼ');
% grid on;


% % % �ȶ���100
% global roh;
% roh = 0.8711;         % 0.8711
% end3 = 0.282;          % ע���������ֵ���趨����ʱ�䣬��λms
% tscale = 8000;        % ע�� �������ֵ���趨�������䣬��λms
% tend = p1_t(tscale, [0, end3]);
% hold on;
% xlabel('ʱ��t(ms)');
% ylabel('ѹǿp(MPa)');
% title('\fontsize{15}ȼ��ѹǿ��ʱ��仯��ϵͼ');
% grid on;

% % % �ȶ���100 ϸ�½�
% global roh;
% roh = 0.8711;         % 0.8711
% end3 = 0.28;          % ע���������ֵ���趨����ʱ�䣬��λms
% tscale = 200;        % ע�� �������ֵ���趨�������䣬��λms
% tend = p1_t(tscale, [0, end3]);
% hold on;
% xlabel('ʱ��t(ms)');
% ylabel('ѹǿp(MPa)');
% title('\fontsize{15}ȼ��ѹǿ��ʱ��仯��ϵͼ');
% grid on;

% % % �ȶ���150
% global roh;
% roh = 0.8711;         % 0.8711
% end3 = 0.75;          % ע���������ֵ���趨����ʱ�䣬��λms
% tscale = 5000;        % ע���������ֵ���趨�������䣬��λms
% tend = p1_t_ro0(0, tscale, [0, end3], 0.8679); %����Ҫ�趨��ʼ�ܶ�Ϊ0.8679����0.85
% hold on;
% xlabel('ʱ��t(ms)');
% ylabel('ѹǿp(MPa)');
% title('\fontsize{15}ȼ��ѹǿ��ʱ��仯��ϵͼ');
% grid on;

% �����ڵ�150
% global roh;
% roh = 0.8711;          
% end3 = 0.87;          % ע���������ֵ���趨����ʱ�䣬��λms
% tscale = 5000;        % ע�� �������ֵ���趨�������䣬��λms
% tend = p1_t(tscale, [0, end3]);
% hold on;
% xlabel('ʱ��t(ms)');
% ylabel('ѹǿp(MPa)');
% title('\fontsize{15}ȼ��ѹǿ��ʱ��仯��ϵͼ');
% grid on;

% 2s�ڵ�150MPa������ͼ��ƴ�Ӳ���
% global roh;
% roh = 0.8711;          
% end3 = 0.87;          % ע���������ֵ���趨����ʱ�䣬��λms
% tscale = 2000;        % ע�� �������ֵ���趨�������䣬��λms
% tend = p1_t(tscale, [0, end3]);
% end3 = 0.75;
% tend = p1_t_ro0(tscale, tscale, [0, end3], 0.8679);
% hold on;
% xlabel('ʱ��t(ms)');
% ylabel('ѹǿp(MPa)');
% title('\fontsize{15}ȼ��ѹǿ��ʱ��仯��ϵͼ');
% grid on;

% �����ڵ�150
% global roh;
% roh = 0.8711;      % 0.8711
% end3 = 0.72;          % ע���������ֵ�趨����
% tscale = 6000;        % ע�� �������ֵ���趨�������䣬��λms
% tend = p1_t(tscale, [0, end3]);
% hold on;
% xlabel('ʱ��t(ms)');
% ylabel('ѹǿp(MPa)');
% title('\fontsize{15}ȼ��ѹǿ��ʱ��仯��ϵͼ');
% grid on;

% 5s�ڵ�150MPa������ͼ��ƴ�Ӳ���
% global roh;
% roh = 0.8711;          
% end3 = 0.72;          % ע���������ֵ���趨����ʱ�䣬��λms
% tscale = 5000;        % ע�� �������ֵ���趨�������䣬��λms
% tend = p1_t(tscale, [0, end3]);
% end3 = 0.75;
% tend = p1_t_ro0(tscale, 2000, [0, end3], 0.8679);
% hold on;
% xlabel('ʱ��t(ms)');
% ylabel('ѹǿp(MPa)');
% title('\fontsize{15}ȼ��ѹǿ��ʱ��仯��ϵͼ');
% grid on;

% ʮ���ڵ�150
% global roh;
% roh = 0.8711;      % 0.8711
% end3 = 0.68;           % ע���������ֵ�趨����
% tscale = 11000;        % ע�� �������ֵ���趨�������䣬��λms
% tend = p1_t(tscale, [0, end3]);
% hold on;
% xlabel('ʱ��t(ms)');
% ylabel('ѹǿp(MPa)');
% title('\fontsize{15}ȼ��ѹǿ��ʱ��仯��ϵͼ');
% grid on;

% 10s�ڵ�150MPa������ͼ��ƴ�Ӳ���
% global roh;
% roh = 0.8711;          
% end3 = 0.68;          % ע���������ֵ���趨����ʱ�䣬��λms
% tscale = 10000;        % ע�� �������ֵ���趨�������䣬��λms
% tend = p1_t(tscale, [0, end3]);
% end3 = 0.75;
% tend = p1_t_ro0(tscale, 2000, [0, end3], 0.8679);
% hold on;
% xlabel('ʱ��t(ms)');
% ylabel('ѹǿp(MPa)');
% title('\fontsize{15}ȼ��ѹǿ��ʱ��仯��ϵͼ');
% grid on;

% % %  �����ǵڶ��ʵĽ������ͼ
% % %  ע�����������ý��ٶ�w��ֵ��w=2*pi/50ʱ��͹������Ϊ50ms
% % %  �����޸�������һ�����ֻ�޸ļ��ź��ֵ��Ҳ����ֱ�Ӹģ�
% % w = 2*pi/50 - 0.0948;
% < 0.0303
% w = 0.0300;        % ��ʾ���ٶ�Ϊ30rad/s
% %  ע�������������ܻ�������tall��tall=5000��ʾ����5000ms����ӡͼ��
% tall = 42000;
% p2_t(tall, w);
% hold on;
% plot([0, tall], [100, 100], '-', 'LineWidth', 3);
% xlabel('ʱ��t(ms)');
% ylabel('ѹǿp(MPa)');
% title('\fontsize{15}ȼ��ѹǿ��ʱ��仯��ϵͼ�����ٶ�Ϊ31rad/s��');
% hold off;

% % % �����ǵ�����ǰ���ʵ���ͼ
% % %  ע�����������ý��ٶ�w��ֵ��w=2*pi/50ʱ��͹������Ϊ50ms
% % %  �����޸�������һ�����ֻ�޸ļ��ź��ֵ��Ҳ����ֱ�Ӹģ�
% w = 2*pi/50 - 0.2;
% w = 0.0500;        % ��ʾ���ٶ�Ϊ50rad/s
% % %  ע�������������ܻ�������tall��tall=5000��ʾ����5000ms����ӡͼ��
% tall = 30000;
% p3_t(tall, w, [50, 50]);
% hold on;
% plot([0, tall], [100, 100], '-', 'LineWidth', 3);
% xlabel('ʱ��t(ms)');
% ylabel('ѹǿp(MPa)');
% title('\fontsize{15}ȼ��ѹǿ��ʱ��仯��ϵͼ�����ٶ�Ϊ31rad/s��');
% hold off;

% % % ������÷ֶη���ֱ������������ֽ��
% tspan = 0:0.01:500;
% dspan = [0, 0.28];
% V = 500 * pi * 5^2;     % ��ѹ�͹����
% A = pi * 0.7^2;         % С�����
% sol = ode45(@(t,ro) ((decide2(t,dspan)*C*A*sqrt(2*ro*(160-p_ro(ro)))...
%         - ro*Q1(t)) / V), tspan, ro0);
% plot(tspan, p_ro(deval(sol, tspan)), '-');
% xlabel('ʱ��t(ms)');
% ylabel('ѹǿp(MPa)');
% title('\fontsize{15}ȼ��ѹǿ��ʱ��仯��ϵͼ�����ֶ���⣩');

% % ��Q(t)ͼ
% t = 0:0.01:5;
% q = zeros(size(t));
% for k = 1:length(t)
%     q(k) = Qrt(t(k), 0.85);
% end
% plot(t, q, '-');
% xlabel('ʱ��t(ms)');
% ylabel('����Q(mm^3/ms)');
% title('\fontsize{15}������ʱ��仯��ϵͼ');

% �����ʺ���ʣ�ֻ����һ�������ڵ����
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

