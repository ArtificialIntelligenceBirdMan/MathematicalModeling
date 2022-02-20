clear
load XY.mat
mu_x = mean(XY(:,1));
mu_y = mean(XY(:,2));
sigma_x = std(XY(:,1));
sigma_y = std(XY(:,2));
len = size(XY,1);
m = 7;
Cor = zeros(m,2);
for n=1:m
    xy = XY(1:len-n,:);
    xyt = XY(n+1:len,:);
    corx = cov(xy(:,1)-mu_x,xyt(:,1)-mu_x);
    cory = cov(xy(:,2)-mu_y,xyt(:,2)-mu_y);
    Cor(n,1) = corx(1,2)/sigma_x^2;
    Cor(n,2) = cory(1,2)/sigma_y^2;
end
plot(Cor(:,1),'linewidth',1);
hold on
plot(Cor(:,2),'linewidth',1);