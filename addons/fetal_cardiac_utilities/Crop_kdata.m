function y = Crop_kdata(SZ,sz)

y=(SZ-sz)/2;
y=ceil(y+1:y+sz);

end