function h = h_t(t)
    % �����뷧���̶�ʱ��ĺ�����ϵ
    t0 = mod(t, 100);
    global hpp;
    if(t0 <= 0.45)
        h = ppval(hpp, t0);
    elseif(t0 <= 2)
        h = 2;
    elseif(t0 <= 2.45)
        h = ppval(hpp, t0);
    else
        h = 0;
    end
end
