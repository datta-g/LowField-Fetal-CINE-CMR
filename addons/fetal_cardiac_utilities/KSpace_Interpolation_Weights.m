function W = KSpace_Interpolation_Weights(EchoLength,CP,MI,nFrames)
MI=MI./max(abs(MI(:)));
MI=MI.*(MI>(median(MI)-1.5*iqr(MI))); %dsg strict
if isempty(MI) || sum(MI)==0
    MI=ones(length(CP),1);
end
CP=col(CP);
MI=col(MI);
MI=imresize(MI,[length(CP),1]);
MI(MI>1) = 1; MI(MI<0) = 0;


W=zeros(EchoLength,length(CP),nFrames);

CP=[CP-1;CP;CP+1];
% MI=[MI;MI;MI];

% iCP=linspace(0,1,nFrames);
iCP = [1:nFrames]/nFrames;

% S=repmat(mean(diff(iCP))+(linspace(0,8*mean(diff(iCP)),EchoLength/2)).^(8),[length(CP),1])';
% S=ones(size(S))*1*mean(diff(iCP));
% S=[flipud(S);S];

S = ones(EchoLength,length(CP))*mean(diff(iCP));

CP=repmat(CP,[1,EchoLength])';
MI=repmat(MI,[1,EchoLength])';
for iFrame=1:nFrames
    % x=mygaus([1,iCP(iFrame),mean(diff(iCP))],CP);
    x=mygaus(1,iCP(iFrame),S,CP);
    x=(x(:,1:size(MI,2))+x(:,size(MI,2)+1:2*size(MI,2))+x(:,2*size(MI,2)+1:3*size(MI,2))).*MI;
    W(:,:,iFrame)=bsxfun(@times,x,1./sum(x,2));%x./sum(x(:));
    % IMG(:,:,iFrame) = sum(bsxfun(@times,permute(x,[2,3,1]),RT),3)./sum(x(:));
        
    W(:,:,iFrame)=W(:,:,iFrame)/max(max(W(:,:,iFrame))); %dsg

end
end

function f = mygaus(h,c,s,x)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function used with leastsq to fit data to
% SF=height * exp(-(x-centre)^2/(2o^2)))
% param(1) = height
% param(2) = center
% param(3) = sigma
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f= h*exp((-(x-c).^2)./(2*s.^2));
end






% function [IMG,CP0] = ISpace_Interpolation_CP_Input(RT,CP,nFrames)
% CP=col(CP);
% CP0=CP;
% CP=[CP-1;CP;CP+1];RT=cat(3,RT,RT,RT);
% % CP=permute(CP,[2,3,1]);
% % CP=repmat(CP,[size(RT,1),size(RT,2),1]);
% iCP=linspace(0,1,nFrames);
% IMG = zeros([size(RT(:,:,1)),nFrames],'single');
% % tic
% for iFrame=1:nFrames
% x=mygaus([1,iCP(iFrame),mean(diff(iCP))],CP);
% IMG(:,:,iFrame) = sum(repmat(permute(x,[2,3,1]),[size(RT,1),size(RT,2),1]).*RT,3)./sum(x(:));
% % X(:,iFrame)=x;
% end
% % toc
% % pause
% end
%
% function f = mygaus(param,x)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % function used with leastsq to fit data to
% % SF=height * exp(-(x-centre)^2/(2o^2)))
% % param(1) = height
% % param(2) = center
% % param(3) = sigma
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% f= param(1)*exp((-(x-param(2)).^2)/(2*param(3)^2));
% end
%
%
%
%
%
