% adapted from 
%--------------------------------------------------------------------------
%     Aliasing Artifact Reduction for Spiral Real-Time MRI. MRM, 20.21688
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%   Author:
%       Ye Tian
%       E-mail: phye1988@gmail.com
%
%   Copyright:
%       MREL, 2020
%       https://mrel.usc.edu
%--------------------------------------------------------------------------
% modified by DS GOOLAUB

function [Cost_new,Cost,fNorm,tNorm,sNorm] = Cost_STCR(fUpdate, Image, sWeight, tWeight, Cost_old)

N = numel(Image);

fNorm = sum(abs(fUpdate(:)).^2);

% if tWeight.rt
if tWeight.val ~= 0
    tNorm = mean(tWeight.val(:)) .* abs(diff(Image,1,3));
    tNorm = sum(tNorm(:));
else
    tNorm = 0;
end
% elseif tWeight.cine
%     if tWeight.val ~= 0
%         tNorm = mean(tWeight.val(:)) .* diff(cat(3,Image(:,:,end),Image,Image(:,:,1)),1,3);
%         tNorm = sum(tNorm(:));
%     else
%         tNorm = 0;
%     end
% end

if sWeight ~= 0
    sx_norm = abs(diff(Image,1,2));
    sx_norm(:,end+1,:,:,:)=0;
    sy_norm = abs(diff(Image,1,1));
    sy_norm(end+1,:,:,:,:)=0;
    sNorm = sWeight .* sqrt(abs(sx_norm).^2+abs(sy_norm).^2);
    sNorm = sum(sNorm(:));
else
    sNorm = 0;
end

fNorm = fNorm/N;
tNorm = tNorm/N;
sNorm = sNorm/N;

Cost = sNorm + tNorm + fNorm;

if nargin == 4
    Cost_new = Cost;
    return
end

Cost_new = Cost_old;

if isempty(Cost_old.fidelityNorm)==1
    Cost_new.fidelityNorm = gather(fNorm);
    Cost_new.temporalNorm = gather(tNorm);
    Cost_new.spatialNorm = gather(sNorm);
    Cost_new.totalCost = gather(Cost);
else
    Cost_new.fidelityNorm(end+1) = gather(fNorm);
    Cost_new.temporalNorm(end+1) = gather(tNorm);
    Cost_new.spatialNorm(end+1) = gather(sNorm);
    Cost_new.totalCost(end+1) = gather(Cost);
end

end