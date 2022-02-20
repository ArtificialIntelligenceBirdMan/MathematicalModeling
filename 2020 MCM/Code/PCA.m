function [r,Z]=PCA(A,k)
[n,p]=size(A);
A=A-mean(A);
C=1/(n-1)*(A'*A);
[x,y]=eig(C);
v=sum(y);
r=v/sum(v);
F=x'*A';
Z=0;
for i=1:k
    Z=Z+F(i,:)*r(i);
end
