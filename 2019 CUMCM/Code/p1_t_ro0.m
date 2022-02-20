function pend = p1_t_ro0(tstart, tend, dspan, ro0)
    % 作第一问的压强关于时间的图，tend是积分区间，dspan是进油时间
    % 这个函数版本要求提供ro0
    spanbuf = (0:(10+dspan):tend);
    spanbuf = [spanbuf (100:100:tend)];
    spanbuf = sort(spanbuf);
    spanbuf = unique(spanbuf);
    C = 0.85;               % 流量系数
    V = 500 * pi * 5^2;     % 高压油管体积
    A = pi * 0.7^2;         % 小孔面积
    global roh;
    hold on;
    for k = 1:(length(spanbuf) - 1)
        tspan = spanbuf(k):0.01:spanbuf(k+1);
        sol = ode45(@(t,ro) ((decide2(t,dspan)*C*A*sqrt(2*roh*(160-p_ro(ro))) ...
            - ro*Q1(t)) / V), tspan, ro0);  % 这里可能应该用ode23t
        ro0 = deval(sol, tspan(end));
        plot(tspan + tstart, p_ro(deval(sol, tspan)));
    end
    pend = p_ro(deval(sol, tend));
    hold off;
end