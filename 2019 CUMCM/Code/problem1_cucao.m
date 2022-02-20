clc; clear;
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

% 下面对第一问进行粗糙求解
% 稳定在100MPa时，10s内喷出的质量
C = 0.85;               % 流量系数
V = 500 * pi * 5^2;     % 高压油管体积
A = pi * 0.7^2;         % 小孔面积
m_out = ro_p(100) * 44 * 100; %10s 有100个周期
q_in = C * A * sqrt(2 * (160 - 100) / ro_p(160));
dt100 = (10 * m_out) / (ro_p(160) * q_in * 1e4 - m_out);

% 稳定在150MPa时
m_out = ro_p(150) * 44 * 100;
q_in = C * A * sqrt(2 * (160 - 150) / ro_p(160));
dt150 = (10 * m_out) / (ro_p(160) * q_in * 1e4 - m_out);

% 2s内到150MPa
et = 2;
p = (100 : 50/(10*et) : 150);
ro = ro_p(p);
m_out = sum(ro .* 44);
ld = 0.4;   rd = 0.5;
er = 1;
while(abs(er) > 0.1)
    delt = (ld + rd) / 2;
    m_in = 0;
    for k = 1:ceil(et*1e3 / (delt+10))
       t = (delt+10) * (k-1);
       pt = 100 + 50 * (t / (et*1e3));
       m_in = m_in + delt * ro_p(160) * C * A * sqrt(2 * (160 - pt) / ro_p(160));
    end
    er = m_in - m_out;
    if(er > 0)
        rd = delt;
    else
        ld = delt;
    end
end
dt2 = delt;

% 5s内到150MPa
et = 5;
p = (100 : 50/(10*et) : 150);
ro = ro_p(p);
m_out = sum(ro .* 44);
ld = 0.1;   rd = 0.5;
er = 1;
while(abs(er) > 0.1)
    delt = (ld + rd) / 2;
    m_in = 0;
    for k = 1:ceil(et*1e3 / (delt+10))
       t = (delt+10) * (k-1);
       pt = 100 + 50 * (t / (et*1e3));
       m_in = m_in + delt * ro_p(160) * C * A * sqrt(2 * (160 - pt) / ro_p(160));
    end
    er = m_in - m_out;
    if(er > 0)
        rd = delt;
    else
        ld = delt;
    end
end
dt5 = delt;

% 10s内到150MPa
et = 10;
p = (100 : 50/(10*et) : 150);
ro = ro_p(p);
m_out = sum(ro .* 44);
ld = 0.1;   rd = 0.5;
er = 1;
while(abs(er) > 0.1)
    delt = (ld + rd) / 2;
    m_in = 0;
    for k = 1:ceil(et*1e3 / (delt+10))
       t = (delt+10) * (k-1);
       pt = 100 + 50 * (t / (et*1e3));
       m_in = m_in + delt * ro_p(160) * C * A * sqrt(2 * (160 - pt) / ro_p(160));
    end
    er = m_in - m_out;
    if(er > 0)
        rd = delt;
    else
        ld = delt;
    end
end
dt10 = delt;

    