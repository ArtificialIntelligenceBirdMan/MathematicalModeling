a = 0;
b = 1.5;
c = 0;
d = 3600*24*14;
h = 0.01;
tau = 30;
Lambda = 2.177;
C = 854;
rho = (2800 + 3300)/2;
alpha = Lambda/(C*rho);
n = (b-a)/h;
m = (d-c)/tau;
T = zeros(m+1,n+1); %初值
T(:,1) = zeros(m+1,1) + 160; %边值
T(:,n+1) = zeros(m+1,1) + 20; %边值
r = alpha*tau/h^2;
for i=1:m
    t_next = zeros(1, n-1);
    for j = 2 : n                                
        t_next(j-1) = r*(T(i, j+1) + T(i, j-1)) + (1 - 2*r)*T(i, j);
    end
    T(i+1,2:n) = t_next;
end
surf(T);
shading interp
