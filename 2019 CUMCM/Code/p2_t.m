function p = p2_t(ted, w)
    wT = 2*pi / w;
    oT = 100;
    oTs = 0;
    wTs = wT;
    cnt = 0;
    % �������ɸ������ȵĻ�������
    spanbuf = zeros(ceil(ted/wT + ted/oT),1);
    while(wTs < ted - 1e-3 || oTs < ted - 1e-3)
        cnt = cnt + 1;
        if(wTs < oTs - 1e-3)
            spanbuf(cnt) = wTs;
            wTs = wTs + wT;
        elseif(wTs - 1e-3 > oTs)
            spanbuf(cnt) = oTs;
            oTs = oTs + oT;
        else    % ��ȵ����ҲҪ����
            spanbuf(cnt) = oTs;
            oTs = oTs + oT;
            wTs = wTs + wT;
        end
    end
    spanbuf(cnt+1) = ted;
    spanbuf(spanbuf==0) = [];
    spanbuf = [0; spanbuf];
    ro0 = 0.85;
    V = 500 * pi * 5^2;     % ��ѹ�͹����
    hold on;
    for k = 1:(length(spanbuf)-1)
        tspan = spanbuf(k):0.01:spanbuf(k+1);
        sol = ode23t(@(t,ro) (F_in(t,w,ro) - ro * Qrt(t,ro))/(V + V1_t(t,w)), tspan, ro0);
        ro0 = deval(sol, tspan(end));
        plot(tspan, p_ro(deval(sol, tspan)), '-');
    end
    hold off;
    p = p_ro(deval(sol, tspan(end)));
end