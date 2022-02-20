function y=verified(A)
n=length(A);
for i=1:n
    if A(i)==1
        y(i)=1;
    else
        y(i)=0.5;
    end
end
