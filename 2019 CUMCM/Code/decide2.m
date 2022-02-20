function b = decide2(t, span)
    t0 = mod(t, span(2) + 10);
    if(t0 <= span(2))
        b = 1;
    else
        b = 0;
    end
end