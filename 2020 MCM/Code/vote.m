function y=vote(A,B)
%AÊÇHelpful vote,BÊÇtotal vote
n=length(A);
k=A./B;
for i=1:n
    if B(i)>5
        if k(i)>0.85
            y(i)=1;
        end
        if k(i)>=0.6 && k(i)<0.85
            y(i)=0.95;
        end
        if k(i)>=0.4 && k(i)<0.6
            y(i)=0.9;
        end
        if k(i)>=0.2 && k(i)<0.4
            y(i)=0.8;
        end
        if k(i)<20
            y(i)=0.7;
        end
    else
        y(i)=0.9;
    end
end