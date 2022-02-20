function m_in = F_in(t, w, ro)
   theta = mod(t * w, 2 * pi);
   global S1;
   global dR;
   if(theta > pi)   %% ���ﲻӦ����3*pi/2��ʼ����Ӧ����pi�Ϳ�ʼ��
        ro1 = ro_theta(theta);
        if(ro1 > ro)
            m_in = S1 * ro * w * ppval(dR, theta);
        else
            m_in = 0;
        end
   else
        m_in = 0;
   end
end