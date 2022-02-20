function b = decide1(t, span)
    t0 = mod(t, 100);
    a = span(1);
    b = span(2);
    if(t0 < a || t0 >= b)
        b = 0;
    else
        b = 1;
    end
end