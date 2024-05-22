function x = ifft2c(x)
fctr = size(x,1)*size(x,2);        
x = sqrt(fctr)*fftshift(ifft2(ifftshift(x)));

        


% function x = ifft2c(x)
% fctr = size(x,1)*size(x,2);
% % res=zeros(size(x),'single');
% for n=1:size(x,3)
%     for m=1:size(x,4)
%         x(:,:,n,m) = sqrt(fctr)*fftshift(ifft2(ifftshift(x(:,:,n,m))));
%     end
% end