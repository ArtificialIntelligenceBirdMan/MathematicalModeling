a = 0;
b = 5;
c = 0;
d = 7200*5;
h = 0.005;
tau = 0.25;
Lambda = 0.023;
C = 1005;
rho = 1.18;
alpha = Lambda/(C*rho);
n = (b-a)/h;
m = (d-c)/tau;
T = zeros(m+1,n+1) + 22; %初值
T(:,1) = zeros(m+1,1) + 25.08; %边值
r = alpha*tau/h^2;
for i=1:m
    t_next = zeros(1, n-1);
    % 差分格式
    for j = 2 : n                                   
        t_next(j-1) = r*(T(i, j+1) + T(i, j-1)) + (1 - 2*r)*T(i, j);
    end
    T(i+1,2:n) = t_next;
end
% surf(T);
% shading interp
plot(T(:,11),'linewidth',1)