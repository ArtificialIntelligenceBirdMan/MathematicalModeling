function L = L_t(t, w)
    global L0;
    global Rpp;
    L = L0 + ppval(Rpp, 0) - ppval(Rpp, mod(w*t, 2*pi));
end
