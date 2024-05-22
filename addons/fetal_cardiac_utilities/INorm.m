function I = INorm(I)
I=I./max(abs(I(:)));
I=abs(I);
end