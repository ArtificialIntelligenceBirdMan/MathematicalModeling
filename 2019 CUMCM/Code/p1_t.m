function pend = p1_t(tend, dspan)
    % ����һ�ʵ�ѹǿ����ʱ���ͼ��tend�ǻ������䣬dspan�ǽ���ʱ��
    ro0 = 0.85;             % ��ʼѹǿΪ100MPa�����ܶ�Ϊ0.85
%     ro0 = 0.8679;           % ��ʼѹǿΪ150MPa�����ܶ�Ϊ0.8679�����Ҫ�����ͼ���޸�����
    spanbuf = (0:(10+dspan):tend);
    spanbuf = [spanbuf (100:100:tend)];
    spanbuf = sort(spanbuf);
    spanbuf = unique(spanbuf);
    C = 0.85;               % ����ϵ��
    V = 500 * pi * 5^2;     % ��ѹ�͹����
    A = pi * 0.7^2;         % С�����
    global roh;
    hold on;
    for k = 1:(length(spanbuf) - 1)
        tspan = spanbuf(k):0.01:spanbuf(k+1);
        sol = ode45(@(t,ro) ((decide2(t,dspan)*C*A*sqrt(2*roh*(160-p_ro(ro))) ...
            - ro*Q1(t)) / V), tspan, ro0);  % �������Ӧ����ode23t
        ro0 = deval(sol, tspan(end));
        plot(tspan, p_ro(deval(sol, tspan)));
    end
    pend = p_ro(deval(sol, tend));
    hold off;
end