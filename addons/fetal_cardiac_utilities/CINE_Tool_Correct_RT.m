% NAME :  
%           CINE_Tool_Correct_RT(imageseries,myTransforms, rotationflag)
% 
% DESCRIPTION:
%           Applies motion correction parameters to image  
% INPUTS:
%           imageseries          input image series  
%           myTransform          transform parameteres 
%           rotationflag         toggle for rotation on or off
%
% OUTPUTS:
%           imageseries          motion corrected images
%           
% NOTES:
%           
%
% Original code Christopher Roy 2018
% modifications by Datta Goolaub 2022

function imageseries = CINE_Tool_Correct_RT(imageseries,myTransforms, rotationflag)

for iSlice=1:size(imageseries,4)
    [Y,X]=meshgrid(linspace(-0.5,0.5,size(imageseries,1)),linspace(-0.5,0.5,size(imageseries,2)));
    k=repmat(X+1i*Y,[1,1,size(imageseries,3)]);
    iTransforms=imresize(myTransforms(:,:,iSlice),[size(imageseries,3),3]);

    NAVx=iTransforms(:,1);NAVy=iTransforms(:,2);
    NAVx=repmat(permute(NAVx,[2,3,1]),[size(imageseries,1),size(imageseries,2),1]);
    NAVy=repmat(permute(NAVy,[2,3,1]),[size(imageseries,1),size(imageseries,2),1]);
    Z=exp(-2*pi*1i*(-NAVy.*real(k)-NAVx.*imag(k)));
    imageseries(:,:,:,iSlice)=ifft2c(Z.*fft2c(imageseries(:,:,:,iSlice)));
    
    if rotationflag
        for nt = 1:size(imageseries(:,:,:,iSlice),3)
            imageseries(:,:,nt,iSlice) = imrotate(imageseries(:,:,nt,iSlice), iTransforms(nt,3),'crop');
        end
    end
    
end