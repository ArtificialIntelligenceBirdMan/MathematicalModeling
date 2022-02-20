function V1 = V1_t(t, w)
    global S1;
    L = L_t(t, w);
    V1 = L * S1;
end