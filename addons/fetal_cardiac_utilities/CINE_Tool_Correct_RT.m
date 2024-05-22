function RT = CINE_Tool_Correct_RT(RT,myTransforms, rotationflag)

for iSlice=1:size(RT,4)
    [Y,X]=meshgrid(linspace(-0.5,0.5,size(RT,1)),linspace(-0.5,0.5,size(RT,2)));
    k=repmat(X+1i*Y,[1,1,size(RT,3)]);
    iTransforms=imresize(myTransforms(:,:,iSlice),[size(RT,3),3]);

    NAVx=iTransforms(:,1);NAVy=iTransforms(:,2);
    NAVx=repmat(permute(NAVx,[2,3,1]),[size(RT,1),size(RT,2),1]);
    NAVy=repmat(permute(NAVy,[2,3,1]),[size(RT,1),size(RT,2),1]);
    Z=exp(-2*pi*1i*(-NAVy.*real(k)-NAVx.*imag(k)));
    RT(:,:,:,iSlice)=ifft2c(Z.*fft2c(RT(:,:,:,iSlice)));
    
    if rotationflag
        for nt = 1:size(RT(:,:,:,iSlice),3)
            RT(:,:,nt,iSlice) = imrotate(RT(:,:,nt,iSlice), iTransforms(nt,3),'crop');
        end
    end
    
end