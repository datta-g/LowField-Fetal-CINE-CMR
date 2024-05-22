function x = makerow(x)
if size(x,1)>size(x,2)
    x=x';
end
end