function p = p_ro(ro)
    % 计算压强p随密度的变化关系
    global sol1;
    global sol2;
    p = zeros(size(ro));
    for k = 1:length(ro)
        if(ro(k) > 0.88)
            p(k) = 3665.8 * (ro(k) - 0.88) + deval(sol2, 0.88);
        elseif(ro(k) > 0.85)
%             p(k) = deval(sol2, min(ro(k), 0.9));
            p(k) = deval(sol2, ro(k));
        elseif(ro(k) > 0.8)
%             p(k) = deval(sol1, max(ro(k), 0.78));
            p(k) = deval(sol1, ro(k));
        else
            p(k) = 0;
        end
    end
end