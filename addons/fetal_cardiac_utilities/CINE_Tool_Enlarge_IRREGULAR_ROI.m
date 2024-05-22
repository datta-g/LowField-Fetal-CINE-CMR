function newMask = CINE_Tool_Enlarge_IRREGULAR_ROI(Mask)

newMask = imresize(Mask,2);

newMask = newMask([round(size(newMask,1)/4+1):round(size(newMask,1)/4+size(Mask,1))], ...
    [round(size(newMask,2)/4+1):round(size(newMask,2)/4+size(Mask,2))]);

newMask(newMask<0.9) = 0;

end