function m_out = F_out(t, ro, span)
    global C;
    global Ad;
    p0 = 0.1;
    t = mod(t, 50);
    if(t >= span(1) && t < span(2))
        m_out = C * Ad * sqrt(2 * ro * (p_ro(ro) - p0));
    else
        m_out = 0;
    end
end