function pend = p_t(tend, dspan)
    ro0 = 0.85;             % ��ʼѹǿΪ100MPa�����ܶ�Ϊ0.85
%     ro0 = 0.8679;
%     tspan = [0, min(dspan(2) + 5, 100)];
    tspan = (0:0.01:(dspan(2)+10));
    C = 0.85;               % ����ϵ��
    V = 500 * pi * 5^2;     % ��ѹ�͹����
    A = pi * 0.7^2;         % С�����
    global roh;
    hold on;
%     for k = 1:ceil(tend/100)
%         sol = ode45(@(t,ro) ((decide2(t,dspan)*C*A*sqrt(2*roh*(160-p_ro(ro))) ...
%             - ro*Q1(t)) / V), tspan, ro0);
%         ro0 = deval(sol, k * 100);
%         tspan = 100 + tspan;
%         plot(((k-1)*100:0.1:k*100), p_ro(deval(sol, ((k-1)*100:0.1:k*100))));
%     end
    for k = 1:ceil(tend/(dspan(2)+10))
        sol = ode45(@(t,ro) ((decide2(t,dspan)*C*A*sqrt(2*roh*(160-p_ro(ro))) ...
            - ro*Q1(t)) / V), tspan, ro0);  % �������Ӧ����ode23t
        ro0 = deval(sol, tspan(end));
        plot(tspan, p_ro(deval(sol, tspan)));
%         tspan = [tspan(1) tspan(end)];
        tspan = 10 + dspan(2) + tspan;
    end
    pend = p_ro(deval(sol, tend));
    hold off;
end