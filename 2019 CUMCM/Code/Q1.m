function Q = Q1(t)
    % 计算喷油速率随时间的函数关系
    % t的单位是ms
    t0 = mod(t, 100);
    if(t0 < 0.2)
        Q = 100 * t0;
    elseif(t0 < 2.2)
        Q = 20;
    elseif(t0 <= 2.4)
        Q = 240 - 100 * t0;
    else
        Q = 0;
    end
end