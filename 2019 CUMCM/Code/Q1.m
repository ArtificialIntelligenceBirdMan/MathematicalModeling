function Q = Q1(t)
    % ��������������ʱ��ĺ�����ϵ
    % t�ĵ�λ��ms
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