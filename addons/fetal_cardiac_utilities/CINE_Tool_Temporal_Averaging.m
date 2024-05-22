function I = CINE_Tool_Temporal_Averaging(I0,nFrames)

if size(I0)==nFrames
    I=I0;
else
    
F=fftc(I0,3);

if size(I0,3)>nFrames
    y = Crop_kdata(size(I0,3),nFrames);
    F=F(:,:,y,:);
else
    while size(F,3)<nFrames
        F=cat(3,F,zeros(size(F(:,:,1,:)),'single'));
    end
end

I=ifftc(F,3);
end

end