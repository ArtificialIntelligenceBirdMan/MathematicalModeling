function ro = ro_p(p)
    global psol1;
    global psol2;
    ro = zeros(size(p));
    for k = 1:length(p)
        if(p(k) > 100)
            ro(k) = deval(psol2, p(k));
        elseif(p(k) > 0)
            ro(k) = deval(psol1, p(k));
        else
            ro(k) = 0;
        end
    end
end
        