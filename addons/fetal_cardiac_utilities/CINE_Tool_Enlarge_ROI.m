function [Sy,Sx] = CINE_Tool_Enlarge_ROI(ROIy,ROIx,y,x)
if length(ROIy)>1
    ROIy=round(0.5*(ROIy(1)+ROIy(end)));
end
if length(ROIx)>1
    ROIx=round(0.5*(ROIx(1)+ROIx(end)));
end
    
y=y/2;
x=x/2;
Sy=ROIy(1)-floor(y):ROIy(end)+ceil(y);
Sx=ROIx(1)-floor(x):ROIx(end)+ceil(x);
if min(Sy)<=0
Sy=Sy-min(Sy(:))+1;
end
if min(Sx)<=0
Sx=Sx-min(Sx(:))+1;
end


end