function y=vine(A)
n=length(A);
y=zeros(n,1);
for i=1:n
    if A(i)==1
        y(i)=1;
    else
        y(i)=0.8;
    end
end