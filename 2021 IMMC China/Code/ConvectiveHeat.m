clear;
a = 0;
b = 1.48;
c = 0;
d = 3600*24*14;
h = 0.01;
tau = 0.2;
Lambda = 2.177;
C = 854;
rho = 3050;
rho2 = 1.293;
c2 = 1005;
hd = 0.05;
q = 15;
alpha = Lambda/(C*rho);
n = (b-a)/h;
m = (d-c)/tau;
T = zeros(m+1,n+2) + 22; %初值
T(:,1) = zeros(m+1,1) - 180; %边值
r = alpha*tau/h^2;
for i=1:m
    t_next = zeros(1, n);
    for j = 2 : n-1                                   
        t_next(j-1) = r*(T(i, j+1) + T(i, j-1)) + (1 - 2*r)*T(i, j);
    end
    t_next(n-1) =  T(i,n)*(1 - 2*q*tau/(rho*C*h) - 2*alpha*tau/h^2) + 2*alpha*tau*T(i, n-1)/h^2 + 2*q*tau*T(i, 1 + n)/(rho*C*h);
    t_next(n) = T(i, 1+n) + q*tau*(T(i,n) + T(i, 2+n) - 2*T(i, 1+n))/(hd*rho2*c2);
    T(i+1,2:n+1) = t_next;
end
% surf(T);
% shading interp
