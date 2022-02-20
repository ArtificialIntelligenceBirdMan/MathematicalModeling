function Y=move(X)
a=min(X);
b=max(X);
X=X-(a+b)/2;
Y=4*X/(b-a);