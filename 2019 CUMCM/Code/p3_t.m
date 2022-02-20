function p = p3_t(ted, w, dspan)
    wT = 2*pi / w;
%     oT = 100;
%     oTs = 0;
%     wTs = wT;
%     cnt = 0;
    % 构造若干个不均匀的积分区间
    spanbuf = 0:wT:ted;
    spanbuf = [spanbuf, (50:50:ted), (dspan(1):50:ted)];
    spanbuf = sort(spanbuf);
    spanbuf = unique(spanbuf);
    spanbuf(diff(spanbuf) < 0.01) = [];     % 去重
    ro0 = 0.85;
    V = 500 * pi * 5^2;     % 高压油管体积
    hold on;
    for k = 1:(length(spanbuf)-1)
        tspan = spanbuf(k):0.01:spanbuf(k+1);
        sol = ode45(@(t,ro) (F_in(t,w,ro) - F_out(t,ro,dspan) - ro * Qrt2(t,ro))/(V + V1_t(t,w)), tspan, ro0);
        ro0 = deval(sol, tspan(end));
        plot(tspan, p_ro(deval(sol, tspan)), '-');
    end
    hold off;
    p = p_ro(deval(sol, tspan(end)));
end