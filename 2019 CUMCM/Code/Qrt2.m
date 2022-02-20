function Q = Qrt2(t, ro)
    % 唯一的区别是喷油周期变为50ms
    global t0;
    global t1;
    p0 = 0.1;   % 大气压
    t = mod(t, 50); % 这里变了
    global C;
    global d1;
    global d0;
    if(t < t0)
        Q = C*pi*(d1*h_t(t)*tan(pi/20)+h_t(t)^2*tan(pi/20)^2) ...
            * sqrt(2*(p_ro(ro)-p0)/ro);
    elseif(t < t1)
        Q = (pi/4)*C*d0^2*sqrt(2*(p_ro(ro)-p0)/ro);
    elseif(t < 2.45)
        Q = C*pi*(d1*h_t(t)*tan(pi/20)+h_t(t)^2*tan(pi/20)^2) ...
            * sqrt(2*(p_ro(ro)-p0)/ro);
    else
        Q = 0;
    end
end
